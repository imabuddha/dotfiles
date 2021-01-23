#! /bin/bash
# This script is for Raspberry pi os (current as of 16 Dec 2020)
# Location for this script: ~/.lightdm-cleanup.sh
#
# Make sure the following user processes are terminated on logout.
# If not terminated cleanly then their services won't operate 
# properly when user logs in again (without rebooting).
#
# shairport-sync: with pulseaudio backend can't run shairport-sync as service
# touchegg: gestures won't work after logout/login unless client is killed on logout
# 

if [ "$DISPLAY" == ":0" ]
then
    pgrep -x shairport-sync | xargs -t kill -1
    pgrep -x touchegg | xargs -t kill -1
fi
