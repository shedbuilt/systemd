#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
# Append to the system-session file installed by pam earlier in bootstrap
if [ -n "${SHED_PKG_LOCAL_OPTIONS[bootstrap]}" ]; then
    echo "session    required    pam_loginuid.so" >> /etc/pam.d/system-session &&
    echo "session    optional    pam_systemd.so" >> /etc/pam.d/system-session || exit 1
fi
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
