#!/bin/bash
# If needed, created the machine-id file used by systemd-journald
if [ ! -e /etc/machine-id ]; then
    systemd-machine-id-setup || exit 1
fi
# If needed, create resolv.conf symlink
if [ ! -e /etc/resolv.conf ]; then
    ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf || exit 1
fi
