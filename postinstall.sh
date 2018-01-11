#!/bin/bash
# If needed, created the machine-id file used by systemd-journald
if [ ! -e /etc/machine-id ]; then
    systemd-machine-id-setup
fi
# If needed, install a script to allow unprivileged user logins without systemd-logind
if [ ! -e /lib/systemd/systemd-user-sessions ]; then
    install -v -Dm755 "${SHED_CONTRIBDIR}/systemd-user-sessions" "${SHED_FAKEROOT}/lib/systemd/systemd-user-sessions"
fi
