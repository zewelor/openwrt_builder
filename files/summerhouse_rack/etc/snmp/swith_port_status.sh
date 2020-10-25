#!/bin/sh

if [ ${#} -ne 1 ]; then
  echo "Usage: $0 <port_nr>"
  exit 0
fi

/sbin/swconfig dev switch0 port ${1} get link|cut -f 2 -d ' '|cut -f 2 -d ':'
exit 0
