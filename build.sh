#!/bin/bash
# Remove tests incompatible with chroot
sed '179,223d' -i src/resolve/meson.build
# Remove unneeded render group
sed -i 's/GROUP="render", //' rules/50-udev-default.rules.in
# Build in a separate directory
mkdir -v build
cd build
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
      .. && \
LANG=en_US.UTF-8 NINJAJOBS=$SHED_NUMJOBS ninja && \
LANG=en_US.UTF-8 DESTDIR="$SHED_FAKEROOT" ninja install || exit 1
rm -rfv ${SHED_FAKEROOT}/usr/lib/rpm
mkdir -v ${SHED_FAKEROOT}/sbin
for SHEDPKG_TOOL in runlevel reboot shutdown poweroff halt telinit; do
    ln -sfv ../bin/systemctl "${SHED_FAKEROOT}/sbin/${SHEDPKG_TOOL}"
done
ln -sfv ../lib/systemd/systemd "${SHED_FAKEROOT}/sbin/init"
# Install an LFS script to allow unprivileged user logins without systemd-logind
install -v -Dm755 "${SHED_CONTRIBDIR}/systemd-user-sessions" "${SHED_FAKEROOT}/lib/systemd/systemd-user-sessions"
