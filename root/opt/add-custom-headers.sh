#!/bin/sh

# Simple shell-based filter. It is meant to be invoked as follows:
#       /path/to/script -f sender recipients...

# Localize these. The -G option does nothing before Postfix 2.3.
TMP_DIR=/var/spool/filter
SENDMAIL="/usr/sbin/sendmail -G -i" # NEVER NEVER NEVER use "-t" here.

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

# clean up when done or when aborting.
trap "rm -f in.$$" 0 1 2 3 15

# change directory to our temporary directory.
cd $TMP_DIR || {
    echo $TMP_DIR does not exist; exit $EX_TEMPFAIL; }

# accept stdin email() and save it to a file named in.pid.
cat >in.$$ || {
    echo Cannot save mail to file; exit $EX_TEMPFAIL; }

########### Add SES Headers to email. ###########
sed -i'' -e "/Date: /r /etc/postfix/custom-headers.txt" in.$$

# pass the email back to postfix using the sendmail command.
$SENDMAIL "$@" <in.$$

# exit with error code from sending to sendmail, run trap cleanup.
exit $?
