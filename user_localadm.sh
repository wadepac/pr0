#!/bin/bash
addgroup localadmins
usermod -aG localadmins localadmin
echo "localadmin  ALL=(root)NOPASSWD:/usr/bin/id,/usr/bin/find,/bin/cat" >> /etc/sudoers