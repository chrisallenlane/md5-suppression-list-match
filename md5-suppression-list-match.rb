#!/usr/bin/ruby

##
# This script will take a CSV file of email information and a CSV file
# of hashes and will match the hashes to the email addresses.
#
# Chris Lane <chris@chris-allen-lane.com>
##

#################################
#  Dependencies
#################################
require 'rubygems'
require 'sqlite3'
require 'csv'
require 'trollop'
require 'digest/md5'


#################################
#  Menu
#################################
opts = Trollop::options do
    opt :email_csv, 'The path to the CSV file containing subscriber email addresses',
        :short => 'c', :type => String,  :required => true
    
    opt :email_csv_column, 'The column in the subscriber CSV file containing email addresses',
        :short => 'e', :type => Integer, :default => 1
    
    opt :database_file, 'Full path to the temporary database',
        :short => 'd', :type => String,  :default => '/tmp/md5-suppression-list.db'
    
    opt :hash_csv, 'The path to the CSV file of MD5 hashes',
        :short => 'f', :type => String,  :required => true
    
    opt :invert_matches, 'Return email addresses which are NOT in the suppression list.',
        :short => 'i', :default => false
    
    opt :output_file, 'Path to where the output file should be saved',
        :short => 'o', :type => String,  :required => true
    
    opt :preserve_database, 'If specified, will not delete the database after use.',
        :short => 'p', :default => true
    
    opt :test, 'Test the CSV parsing for email addresses.',
        :short => 't', :default => false
end


#################################
#  Test
#################################
# If a test is requested, display what is being interpreted as the first
# fifty email addresses in the CSV file.
if opts[:test_given]
    emails_displayed = 0
    CSV.foreach(opts[:email_csv]) do |row|
        email = row[opts[:email_csv_column] - 1]       # count from zero
        puts email
        
        # track the number of email addresses displayed
        emails_displayed += 1
        if emails_displayed == 50
            break
        end
    end
    
    # exit early on testing
    exit
end


#################################
#  Prepare the database
#################################
# establish a database connection
database_already_exists = true if File::exists?(opts[:database_file])
database = SQLite3::Database.new(opts[:database_file])

# don't attempt to recreate these tables if they already exist
unless database_already_exists
    # first, initialize the database
    database.execute("
        CREATE TABLE emails_and_hashes (
            `email` TEXT,
            `hash` TEXT
        )"
    )
    database.execute("
        CREATE TABLE hashes (
            `hash` TEXT
        )"
    )
end


#################################
# First, insert your email addresses and their hashes into emails_and_hashes
#################################
# don't import anything if the database already exists
unless database_already_exists
    # start a database transaction to speed up SQLite3
    database.transaction
    stmt = database.prepare("
        INSERT INTO emails_and_hashes(email, hash)
        VALUES(:email, :hash)"
    )

    # load the email addresses and calculated hashes into the database
    imported_emails = 0
    CSV.foreach(opts[:email_csv]) do |row|
        # snag the email address and calculate the hash
        email = row[opts[:email_csv_column] - 1].chomp       # count from zero
        hash  = Digest::MD5.hexdigest(email)
        
        # insert the email address and hash into the database
        stmt.execute email, hash
        
        # display progress
        imported_emails += 1
        if imported_emails % 100 === 0
            puts "Importing emails addresses: #{imported_emails}"
        end
    end

    # close the transaction and statement
    database.commit
    stmt.close
end


#################################
# Second, load the hashes into table hashes
#################################
# don't import anything if the database already exists
unless database_already_exists
    # start a database transaction to speed up SQLite3
    database.transaction
    stmt = database.prepare("
        INSERT INTO hashes(hash)
        VALUES(:hash)"
    )

    # load hashes into the database
    imported_hashes = 0
    CSV.foreach(opts[:hash_csv]) do |hash|
        stmt.execute hash
        
        # display progress
        imported_hashes += 1
        if imported_hashes % 100 === 0
            puts "Importing hashes: #{imported_hashes}"
        end
    end

    # close the transaction and statement
    database.commit
    stmt.close
end


#################################
# Third, build indeces to expedite the JOINs
#################################
# build our database indexes if they have not yet been created
unless database_already_exists
    database.execute("CREATE INDEX index_em_hash ON emails_and_hashes(hash)")
    database.execute("CREATE INDEX index_hash ON hashes(hash)")
end


#################################
# Fourth, JOIN the tables and output the results
#################################
# notify the user and create an output buffer
puts "Databases loaded. Finding matches..."
output_buffer = ''

# return emails addresses which are in the suppression list
unless opts[:invert_matches_given]
    database.execute("
        SELECT email
        FROM emails_and_hashes
        INNER JOIN hashes
        ON emails_and_hashes.hash = hashes.hash
    ") do | row |
        output_buffer += row[0] + "\n"
    end

# return email address which are NOT in the suppression list
else
    # SQLite3 doesn't support RIGHT OUTER JOINs, so we'll use a subquery
    database.execute("
        SELECT emails_and_hashes.email
        FROM emails_and_hashes
        WHERE emails_and_hashes.hash NOT IN (
            SELECT hashes.hash FROM hashes
        )
    ") do | row |
        output_buffer += row[0] + "\n"
    end
end

# flush the output buffer to disk
File.open(opts[:output_file], 'w') { | file | file.write(output_buffer) }


#################################
# Clean-up and end
#################################
# remember to delete the database file at the end
unless opts[:preserve_database_given]
    File.delete(opts[:database_file])
end
puts "Complete. Matches written to #{opts[:output_file]}."
