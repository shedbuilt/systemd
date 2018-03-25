#!/bin/bash
# Remove unneeded render group
sed -i 's/GROUP="render", //' rules/50-udev-default.rules.in || exit 1
# Remove tests broken in chroot (REMOVE FOR LATER THAN v237)
sed '178,222d' -i src/resolve/meson.build || exit 1
# Patch include issue with util-linux 2.32  (REMOVE FOR LATER THAN v238)
patch -Np1 -i "${SHED_PATCHDIR}/systemd-v237_util-linux-2.32.part1.patch" &&
patch -Np1 -i "${SHED_PATCHDIR}/systemd-v237_util-linux-2.32.part2.patch" &&
patch -Np1 -i "${SHED_PATCHDIR}/systemd-v237_util-linux-2.32.part3.patch" || exit 1
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
LANG=en_US.UTF-8 NINJAJOBS=$SHED_NUMJOBS ninja &&
LANG=en_US.UTF-8 DESTDIR="$SHED_FAKEROOT" ninja install || exit 1
rm -rfv "${SHED_FAKEROOT}/usr/lib/rpm" &&
mkdir -v "${SHED_FAKEROOT}/sbin" || exit 1
for SHEDPKG_TOOL in runlevel reboot shutdown poweroff halt telinit; do
    ln -sfv ../bin/systemctl "${SHED_FAKEROOT}/sbin/${SHEDPKG_TOOL}" || exit 1
done
ln -sfv ../lib/systemd/systemd "${SHED_FAKEROOT}/sbin/init" || exit 1
# Install an LFS script to allow unprivileged user logins without systemd-logind
install -v -Dm755 "${SHED_CONTRIBDIR}/systemd-user-sessions" "${SHED_FAKEROOT}/lib/systemd/systemd-user-sessions" || exit 1
