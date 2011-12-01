md5-suppression-list-match
=================
Chris Lane  
1 Dec 2011  
chris@chris-allen-lane.com  
http://chris-allen-lane.com  
http://twitter.com/#!/chrisallenlane


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


Installation
------------
This script requires `ruby`, `rubygems` to be installed on
your system. It also requires that the `trollop` gem be installed. The
script itself requires no installation, and can either be run directly
or placed somewhere on your system PATH for convenience.


Usage Examples
--------------
These are coming soon. A major re-write on the project has necessitated a re-write on the documentation, which I hope to get to within a few days.


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
