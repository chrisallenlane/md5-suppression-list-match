#!/usr/bin/ruby

##
# This script will take a CSV file of user data and match it against an
# md5 suppression list. It can be used to generate either whitelists of
# users TO email or blacklists of users TO NOT email.
#
# Chris Lane <chris@chris-allen-lane.com>
##

#################################
#  Dependencies
#################################
require 'rubygems'
require 'csv'
require 'trollop'
require 'digest/md5'


#################################
#  Menu
#################################
opts = Trollop::options do
    opt :email_csv, 'The path to the CSV file containing subscriber email addresses.',
        :short => 'e', :type => String,  :required => true
    
    opt :email_csv_column, 'The column in the subscriber CSV file containing email addresses.',
        :short => 'c', :type => Integer, :default => 1
            
    opt :hash_csv, 'The path to the CSV file of MD5 hashes.',
        :short => 'a', :type => String,  :required => true
    
    opt :output_directory, 'Path to where the output file should be saved.',
        :short => 'o', :type => String,  :default => '.'
    
    opt :test, 'Test the CSV parsing for email addresses.',
        :short => 't', :default => false
end

# strip the trailing slash if specified
opts[:output_directory].chop! if opts[:output_directory].end_with? '/'


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
        if emails_displayed == 20
            break
        end
    end
    
    # exit early on testing
    exit
end


##################################################################
# Perform matching in RAM -
##################################################################
# First, load all of the email addresses and their md5 checksums into a
# (Ruby) hash in RAM
puts 'Calculating email address hashes...'
email_hashes = {}
email_counter = 0
CSV.foreach(opts[:email_csv]) do |row|
    # snag the email address and calculate the hash
    email = row[opts[:email_csv_column] - 1].chomp       # count from zero
    hash  = Digest::MD5.hexdigest(email)
    email_hashes[hash] = email
    email_counter += 1
    
    # show progress
    puts "Calculating: #{email_counter}" if email_counter % 10000 == 0
end    

# Second, iterate over all of the (md5) hashes on disk, matching them
# against the in-memory (Ruby) hash
puts 'Matching against suppression list...'
blacklist_buffer  = ''
blacklist_counter = 0
matching_counter  = 0

# open the suppression list and iterate over the hashes
hash_file = File.new(opts[:hash_csv], 'r')
while (hash = hash_file.gets)
    hash = hash.chomp!
    unless email_hashes[hash].nil?
        blacklist_buffer += email_hashes[hash] + "\n"
        # by deleting the blacklisted addresses, we'll momentarily have
        # a hash containing only whitelisted email addresses
        email_hashes.delete hash
        blacklist_counter += 1
    end
    
    # show progress
    matching_counter += 1
    puts "Matching: #{matching_counter}" if matching_counter % 10000 == 0
end
hash_file.close

# Flush the blacklist to disk
File.open("#{opts[:output_directory]}/blacklist.csv", 'w') {|file|file.write(blacklist_buffer)}
blacklist_buffer = nil
puts "#{blacklist_counter} blacklisted (suppressed) emails written to #{opts[:output_directory]}/blacklist.csv."

# Flush the whitelist to disk
whitelist_counter = email_hashes.size
whitelist_buffer = ''
email_hashes.each do |hash, email|
    whitelist_buffer += "#{email}\n"
end
File.open("#{opts[:output_directory]}/whitelist.csv", 'w') {|file|file.write(whitelist_buffer)}
whitelist_buffer = nil
puts "#{whitelist_counter} whitelisted emails written to #{opts[:output_directory]}/whitelist.csv."
puts 'Complete.'
