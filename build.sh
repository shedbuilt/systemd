#!/bin/bash
# Remove tests broken in chroot
sed '171,$ d' -i src/resolve/meson.build &&
# Apply upstream patches for v238
sed -i '527,565 d' src/basic/missing.h &&
sed -i '24 d' src/core/load-fragment.c &&
sed -i '53 a#include <sys/mount.h>' src/shared/bus-unit-util.c &&
# Remove unneeded render group
sed -i 's/GROUP="render", //' rules/50-udev-default.rules.in &&
# Create separate build directory
mkdir -v build &&
cd build &&
# Configure
LANG=en_US.UTF-8                   \
meson --prefix=/usr                \
      --sysconfdir=/etc            \
      --localstatedir=/var         \
      -Dblkid=true                 \
      -Dbuildtype=release          \
      -Ddefault-dnssec=no          \
      -Dfirstboot=false            \
      -Dinstall-tests=false        \
      -Dkill-path=/bin/kill        \
      -Dkmod-path=/bin/kmod        \
      -Dldconfig=false             \
      -Dmount-path=/bin/mount      \
      -Drootprefix=                \
      -Drootlibdir=/lib            \
      -Dsplit-usr=true             \
      -Dsulogin-path=/sbin/sulogin \
      -Dsysusers=false             \
      -Dumount-path=/bin/umount    \
      -Db_lto=false                \
      -Dman=false                  \
      .. &&
# Build and Install
LANG=en_US.UTF-8 NINJAJOBS=$SHED_NUM_JOBS ninja &&
LANG=en_US.UTF-8 DESTDIR="$SHED_FAKE_ROOT" ninja install &&
rm -rfv "${SHED_FAKE_ROOT}/usr/lib/rpm" &&
# Install an LFS script to allow unprivileged user logins without systemd-logind
install -v -Dm755 "${SHED_PKG_CONTRIB_DIR}/systemd-user-sessions" "${SHED_FAKE_ROOT}/lib/systemd/systemd-user-sessions" &&
# Default network config (Eth0, DHCP, systemd-resolved)
install -v -Dm644 "${SHED_PKG_CONTRIB_DIR}/systemd/network/10-eth0-dhcp.network" "${SHED_FAKE_ROOT}/usr/share/defaults/etc/systemd/network/10-eth0-dhcp.network" &&
# Sysctl config
install -v -Dm644 "${SHED_PKG_CONTRIB_DIR}/sysctl.d/99-sysctl.conf" "${SHED_FAKE_ROOT}/usr/share/defaults/etc/sysctl.d/99-sysctl.conf" &&
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/sysctl.d/20-quiet-printk.conf" "${SHED_FAKE_ROOT}/usr/share/defaults/etc/sysctl.d"
