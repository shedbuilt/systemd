#!/bin/bash
# If needed, created the machine-id file used by systemd-journald
if [ ! -e /etc/machine-id ]; then
    systemd-machine-id-setup || exit 1
fi
# If needed, create resolv.conf symlink
if [ ! -e /etc/resolv.conf ]; then
    ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf || exit 1
fi
# If needed, create symlink to default network config
if [ ! -e /etc/systemd/network/10-eth0-dhcp.network ]; then
    ln -sfv /usr/share/defaults/etc/systemd/network/10-eth0-dhcp.network /etc/systemd/network/10-eth0-dhcp.network || exit 1
fi
# If needed, create symlink to default sysctl configs
if [ ! -e /etc/sysctl.d/99-sysctl.conf ]; then
    ln -sfv /usr/share/defaults/etc/sysctl.d/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf || exit 1
fi
if [ ! -e /etc/sysctl.d/99-sysctl.conf ]; then
    ln -sfv /usr/share/defaults/etc/sysctl.d/20-quiet-printk.conf /etc/sysctl.d/20-quiet-printk.conf || exit 1
fi
