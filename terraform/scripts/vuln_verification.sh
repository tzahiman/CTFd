#!/bin/bash
# Exits 0 if vulnerable, 1 if not.
if sudo -u ctf sudo -n /usr/bin/find . -exec whoami \; 2>/dev/null | grep -q "root"; then
    exit 0 # Vulnerable
else
    exit 1 # Not vulnerable 
fi