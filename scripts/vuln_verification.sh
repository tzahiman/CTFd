#!/bin/bash
# Exits 0 if vulnerable, 1 if not.
if sudo -u ctf sudo -l | grep -q "(root) NOPASSWD: /usr/bin/find"; then
    exit 0 # Vulnerable
else
    exit 1 # Not vulnerable 
fi