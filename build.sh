#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
# Remove tests broken in chroot
sed '166,$ d' -i src/resolve/meson.build &&
# Apply glibc 2.28 for v239
patch -Np1 -i "${SHED_PKG_PATCH_DIR}/systemd-239-glibc_statx_fix-1.patch" &&
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
# Install default network config file (Eth0, DHCP, systemd-resolved)
install -v -Dm644 "${SHED_PKG_CONTRIB_DIR}/network/10-eth0-dhcp.network" "${SHED_FAKE_ROOT}${SHED_PKG_DEFAULTS_INSTALL_DIR}/etc/systemd/network/10-eth0-dhcp.network" &&
# Install default sysctl config files
install -v -Dm644 "${SHED_PKG_CONTRIB_DIR}/sysctl.d/99-sysctl.conf" "${SHED_FAKE_ROOT}${SHED_PKG_DEFAULTS_INSTALL_DIR}/etc/sysctl.d/99-sysctl.conf" &&
install -v -m644 "${SHED_PKG_CONTRIB_DIR}/sysctl.d/20-quiet-printk.conf" "${SHED_FAKE_ROOT}${SHED_PKG_DEFAULTS_INSTALL_DIR}/etc/sysctl.d" || exit 1
# Optionally install documentation
if [ -n "${SHED_PKG_LOCAL_OPTIONS[docs]}" ]; then
    mv "${SHED_FAKE_ROOT}/usr/share/doc/systemd" "$SHED_PKG_DOCS_INSTALL_DIR" || exit 1
else
    rm -rf "${SHED_FAKE_ROOT}/usr/share/doc"
fi
