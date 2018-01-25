#!/bin/bash
# If needed, created the machine-id file used by systemd-journald
if [ ! -e /etc/machine-id ]; then
    systemd-machine-id-setup
fi
