#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
if [ -n "${SHED_PKG_LOCAL_OPTIONS[bootstrap]}" ]; then
    # Create temporary symlinks for util-linux libraries
    for SHED_PKG_LOCAL_UTILLINUX_LIB in /tools/lib/lib{blkid,mount,uuid}*; do
        ln -sf $SHED_PKG_LOCAL_UTILLINUX_LIB /usr/lib/
    done
fi
