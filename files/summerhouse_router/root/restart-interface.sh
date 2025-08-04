#!/bin/ash
# This file is responsible for restarting the network interface.
# Should be run once OFFLINE state is detected.

INTERFACE="eth0.2"

# syslog entry
logger -s "INTERNET KEEP ALIVE SYSTEM: Restarting the LTE interface."

echo "SH RESTART IFACE DOWN"
ifdown $INTERFACE

sleep 2

echo "SH RESTART IFACE UP"
ifup $INTERFACE
