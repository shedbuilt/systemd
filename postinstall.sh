#!/bin/bash
# If needed, create the machine-id file used by systemd-journald
if [ ! -e /etc/machine-id ]; then
    systemd-machine-id-setup || exit 1
fi
# If needed, create resolv.conf symlink
if [ ! -e /etc/resolv.conf ]; then
    ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf || exit 1
fi
# Enable time-wait-sync on boards without a RTC
systemctl is-enabled systemd-time-wait-sync.service > /dev/null 2>&1
if [ $? -ne 0 ]; then
    systemctl enable systemd-time-wait-sync.service
fi
