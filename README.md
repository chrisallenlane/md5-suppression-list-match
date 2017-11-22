DEPRECATION NOTICE
==================
This software has been **DEPRECATED**. Please use `slm` instead:

https://github.com/chrisallenlane/slm

It serves the same purpose as this application, but is orders of magnitudes
faster.


md5-suppression-list-match
=================
Chris Lane  
3 Dec 2011  
chris@chris-allen-lane.com  
http://chris-allen-lane.com  
http://twitter.com/#!/chrisallenlane


What it Does
------------
Affiliate marketers often receive lists of email addresses (from other
affiliate marketers) which they must unsubscribe from their own mailing
lists in order to comply with the US CAN SPAM act. For security reasons,
such a list (usually called an "MD5 suppression list") is typically
encrypted via MD5 hashing before distribution.

This script matches a CSV file of user data containing email addresses
against an MD5 suppression list.


Installation
------------
This script requires `ruby` and `rubygems` to be installed on
your system. It also requires that the `trollop` gem be installed. The
script itself requires no installation, and can either be run directly
or placed somewhere on your system PATH for convenience.


Usage Examples
--------------
The script requires that you pass it two files: a CSV file of user data
containing email addresses (which you will likely be able to export via
your list management software), and the MD5 suppression list.

When passing in the path to your CSV export of user data, you may also
specify which column in the CSV file contains user email addresses. (Note
that column counting starts from 1 rather than 0.)

To test that the script is reading the appropriate column for email addresses,
you may pass it the `--test` option, as in:

    ./md5-suppression-list-match --email-csv /path/to/email.csv --email-column 1 --hash-csv /path/to/hashes.csv --output-directory /home/username/Desktop --test

The script will output a sample of the data it's interpreting to be email
addresses. If it's parsing the CSV correctly, you start the suppression
list matching simply by removing the `--test`option.

    ./md5-suppression-list-match --email-csv /path/to/email.csv --email-column 1 --hash-csv /path/to/hashes.csv --output-directory /home/username/Desktop
    
More succinctly (using short options):

    ./md5-suppression-list-match -e /path/to/email.csv -c 1 -a /path/to/hashes.csv -o /home/username/Desktop


Performance
-----------
In hindsight, this script would have likely been better written in a language
other than Ruby, which is proving somewhat slow for the task. Large lists
may take a "long time" to process. (On my Intel i5-based laptop, for example,
it takes about 22 minutes to match a 200,000 email list against a 62
million line suppression list.)

With that said, it may be helpful to run this script via the `nohup` and
`nice` commands, as in:

    nohup nice ./md5-suppression-list-match -e /path/to/email.csv -c 1 -a /path/to/hashes.csv -o /home/username/Desktop
    
`nohup` (no hangup) allows you to close the terminal that started the script
without killing its process. `nice` will assign the script's execution
a lower priority, allowing your computer to stay more responsive while
the script is running essentially in the background.

Know that `nice`-ing a process will likely make it take longer to complete,
however.


Known Issues
------------
This script has no known issues, but has only been tested on Ubuntu
11.04, and may not work on other platforms.


Contact Me
-------------
If you have questions, concerns, bug reports, feature requests, etc, feel free
to contact me at chris@chris-allen-lane.com.


License
-------
This product is licensed under the GPL 3 (http://www.gnu.org/copyleft/gpl.html).
It comes with no warranty, expressed or implied.
