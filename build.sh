#!/bin/bash
./configure --prefix=/usr            \
            --sysconfdir=/etc        \
            --localstatedir=/var     \
            --with-rootprefix=       \
            --with-rootlibdir=/lib   \
            --enable-split-usr       \
            --disable-firstboot      \
            --disable-ldconfig       \
            --disable-sysusers       \
            --disable-manpages       \
            --with-default-dnssec=no \
            --docdir=/usr/share/doc/systemd-234
make -j $SHED_NUMJOBS
make DESTDIR=${SHED_FAKEROOT} install
rm -rfv ${SHED_FAKEROOT}/usr/lib/rpm
mkdir -v ${SHED_FAKEROOT}/sbin
for tool in runlevel reboot shutdown poweroff halt telinit; do
    ln -sfv ../bin/systemctl ${SHED_FAKEROOT}/sbin/${tool}
done
ln -sfv ../lib/systemd/systemd ${SHED_FAKEROOT}/sbin/init
