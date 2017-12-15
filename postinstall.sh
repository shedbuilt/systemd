#!/bin/bash
if ${SHED_ISUPGRADE} ; then
    true
    # This procedure can't be performed without interrupting the script.
    # Disabled for now.
    # systemctl daemon-reload
    # systemctl start multi-user.target
else
    systemd-machine-id-setup
fi
