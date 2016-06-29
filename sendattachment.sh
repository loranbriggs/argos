#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Illegal number of prameters"
  echo "usage: ./sendattachment.sh attachment"
  exit 1
fi

source ~/email_address.txt	# contains EMAIL variable

if [ -n "$EMAIL" ]; then
  echo "Motion detected" | mutt -s "Motion Detected" -a $1 -- $EMAIL
  exit 0
else
  echo "no email address set in email_address.txt"
  exit 1
fi

