md5-suppression-list-match
=================
Chris Lane  
28 November 2011  
chris@chris-allen-lane.com  
http://chris-allen-lane.com  


What it Does
------------
Affiliate marketers often receive lists of email addresses (from other
affiliate marketers) which they must unsubscribe from their own mailing
lists in order to comply with the US CAN SPAM act. For security reasons,
such a llist (usually called an "MD5 suppression list") is typically
encrypted via MD5 hashing before distribution.

This script matches a CSV file of user data containing email addresses
against an MD5 suppression list.

This script has been can be run in one of two modes: either in-memory or
on-disk. The in-memory mode is dramatically faster than the on-disk mode
(which is the default), but cannot be used to process lists whose length
approaches the limits of your systems RAM. On-disk mode has no such
limitation.



Usage Examples
--------------
###To test CSV parsing:

    ./md5-suppression-list-match --email-csv /path/to/email.csv --email-csv-column 1 --hash-csv /path/to/hash.csv --output-file /path/to/output.csv --test

Note that `--email-csv-column` specifies the column in your CSV file
of user data containing email addresses, and that counting of columns
starts from 1 rather than 0.

The command above will display the first 25 lines of what it believes to be
email addresses.

###To generate a blacklist based off of a small number of email addresses:

    ./md5-suppression-list-match --email-csv /path/to/email.csv --email-csv-column 1 --hash-csv /path/to/hash.csv --output-file /path/to/output.csv --in-memory
    
    
###To generate a blacklist based off of a large number of email addresses:

    ./md5-suppression-list-match --email-csv /path/to/email.csv --email-csv-column 1 --hash-csv /path/to/hash.csv --output-file /path/to/output.csv
    
###To generate a whitelist based off of a small number of email addresses:

    ./md5-suppression-list-match --email-csv /path/to/email.csv --email-csv-column 1 --hash-csv /path/to/hash.csv --output-file /path/to/output.csv --in-memory --invert-matches
    
###To generate a whitelist based off of a large number of email addresses:

    ./md5-suppression-list-match --email-csv /path/to/email.csv --email-csv-column 1 --hash-csv /path/to/hash.csv --output-file /path/to/output.csv --invert-matches

Run `./md5-suppression-list-match --help` for an explanation of all options. Also feel free to play with the provided sample CSV files for practice using the script.


Known Issues
------------
This script has no known issues, but has only been tested on Ubuntu
11.04, and may not work on other platforms.


Contact Me
-------------
If you have questions, concerns, bug reports, feature requests, offers
for discount viagra, whatever, feel free to contact me at chris@chris-allen-lane.com.


License
-------
This product is licensed under the GPL 3 (http://www.gnu.org/copyleft/gpl.html).
It comes with no warranty, expressed or implied.
