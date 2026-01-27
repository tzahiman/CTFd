#!/bin/bash

set -e

# 1. Create dedicated non-root user
USER_NAME="ctf"
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME" && echo "User $USER_NAME created."
fi

# 2. Configure sudoers for 'find' privesc
SUDOERS_FILE="/etc/sudoers.d/ctf-find"
echo "$USER_NAME ALL=(root) NOPASSWD: /usr/bin/find" > "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"

# 3. Verification Step
echo "--- Verification ---"
sudo -U "$USER_NAME" -l | grep '/usr/bin/find' && echo "Sudo rule verified."

# Test execution (non-destructive)
sudo -u "$USER_NAME" sudo /usr/bin/find . -maxdepth 0 -exec whoami \; | grep 'root' && \
    echo "Privilege escalation capability confirmed: 'find' can execute as root."