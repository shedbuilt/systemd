#!/bin/bash
# Remove unneeded render group
sed -i 's/GROUP="render", //' rules/50-udev-default.rules.in || exit 1
# Remove tests broken in chroot (REMOVE FOR LATER THAN v237)
sed '178,222d' -i src/resolve/meson.build || exit 1
# Patch include issue with util-linux 2.32  (REMOVE FOR LATER THAN v238)
patch -Np1 -i "${SHED_PKG_PATCH_DIR}/systemd-v237_util-linux-2.32.part1.patch" &&
patch -Np1 -i "${SHED_PKG_PATCH_DIR}/systemd-v237_util-linux-2.32.part2.patch" &&
patch -Np1 -i "${SHED_PKG_PATCH_DIR}/systemd-v237_util-linux-2.32.part3.patch" || exit 1
# Build in a separate directory
mkdir -v build &&
cd build &&
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
LANG=en_US.UTF-8 NINJAJOBS=$SHED_NUM_JOBS ninja &&
LANG=en_US.UTF-8 DESTDIR="$SHED_FAKE_ROOT" ninja install &&
rm -rfv "${SHED_FAKE_ROOT}/usr/lib/rpm" &&
mkdir -v "${SHED_FAKE_ROOT}/sbin" || exit 1
for SHEDPKG_TOOL in runlevel reboot shutdown poweroff halt telinit; do
    ln -sfv ../bin/systemctl "${SHED_FAKE_ROOT}/sbin/${SHEDPKG_TOOL}" || exit 1
done
ln -sfv ../lib/systemd/systemd "${SHED_FAKE_ROOT}/sbin/init" &&
# Install an LFS script to allow unprivileged user logins without systemd-logind
install -v -Dm755 "${SHED_PKG_CONTRIB_DIR}/systemd-user-sessions" "${SHED_FAKE_ROOT}/lib/systemd/systemd-user-sessions" &&
# Default network config (Eth0, DHCP, systemd-resolved)
install -v -Dm644 "${SHED_PKG_CONTRIB_DIR}/systemd/network/10-eth0-dhcp.network" "${SHED_FAKE_ROOT}/usr/share/defaults/etc/systemd/network/10-eth0-dhcp.network" &&
# Sysctl config
install -v -Dm644 "${SHED_PKG_CONTRIB_DIR}/sysctl.d/99-sysctl.conf" "${SHED_FAKE_ROOT}/usr/share/defaults/etc/sysctl.d/99-sysctl.conf" &&
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/sysctl.d/20-quiet-printk.conf" "${SHED_FAKE_ROOT}/usr/share/defaults/etc/sysctl.d"
