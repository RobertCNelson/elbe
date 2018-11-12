## ELBE - Debian Based Embedded Rootfilesystem Builder
## Copyright (c) 2014-2016 Torben Hohn <torben.hohn@linutronix.de>
## Copyright (c) 2014, 2017 Manuel Traut <manut@linutronix.de>
## Copyright (c) 2016 John Ogness <john.ogness@linutronix.de>
##
## SPDX-License-Identifier: GPL-3.0-or-later
##
#! /bin/sh
<%
elbe_exe = 'elbe'

if opt.devel:
    elbe_exe = '/var/cache/elbe/devel/elbe'
%>

# First unset the variables which are set by the debian-installer
unset DEBCONF_REDIR DEBCONF_OLD_FD_BASE MENU
unset DEBIAN_FRONTEND DEBIAN_HAS_FRONTEND debconf_priority
unset TERM_TYPE

# stop confusion /target is buildenv in this context
ln -s /target /buildenv

mkdir -p /buildenv/var/cache/elbe
cp source.xml /buildenv/var/cache/elbe/
cp /etc/apt/apt.conf /buildenv/etc/apt/apt.conf.d/50elbe


% if prj.text('suite') == 'jessie':
ln -s /lib/systemd/system/serial-getty@.service /buildenv/etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service
% endif

mkdir /buildenv/var/cache/elbe/installer
cp initrd-cdrom.gz /buildenv/var/cache/elbe/installer
cp vmlinuz /buildenv/var/cache/elbe/installer

% if opt.devel:
   mkdir /buildenv/var/cache/elbe/devel
   tar xj -f elbe-devel.tar.bz2 -C /buildenv/var/cache/elbe/devel
   echo "export PATH=/var/cache/elbe/devel:\$PATH" > /buildenv/etc/profile.d/elbe-devel-path.sh
   sed -i s%/usr/bin/elbe%/var/cache/elbe/devel/elbe% /buildenv/etc/init.d/elbe-daemon
   sed -i s%/usr/bin/elbe%/var/cache/elbe/devel/elbe% /buildenv/lib/systemd/system/elbe-daemon.service
% endif

# since elbe fetch_initvm_pkgs generates repo keys,
# we need entropy in the target

in-target haveged

% if prj.has("mirror/cdrom"):
  in-target ${elbe_exe} fetch_initvm_pkgs --cdrom-device /dev/sr0 --cdrom-mount-path /media/cdrom0 /var/cache/elbe/source.xml
% else:
  in-target ${elbe_exe} fetch_initvm_pkgs /var/cache/elbe/source.xml
% endif

exit 0
