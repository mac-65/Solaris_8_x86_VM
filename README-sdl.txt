
exit 0;

###############################################################################
# Dec 14, 2019
# Trying to install F21 version of yum since it seems to handle dependencies
# much better for trying to install Fedora 21's KDE...
#
# INSTALL the rpms in:
#    000-F24-kernel  001-F24-updates
#
# Ensure that vim is installed (see '000-F24-kernel')
# Clean up some things:
#   yum erase bash-completion PackageKit
#
# INSTALL the rpms in (python 2.7 is needed by Fedora 21's yum)
#    cd /root/RPMs/002-F24-yum/COMPLETED-000 && rpm -ivh *.rpm
#
# INSTALL the F21 version of rpm by
#    cd /root/RPMs/002-F24-yum/COMPLETED-001 && rpm -ivh --nodeps --force --oldpackage --replacefiles --replacepkgs *.rpm ; rpm --version
# RPM version 4.12.0.1
#
# SHAPSHOT
#
# Next,
#    yum -y install --allowerasing --downloadonly  yum-3.4.3-153.fc21.noarch.rpm ;
#    yum erase dnf-yum ;
#    cd /root/RPMs/002-F24-yum/COMPLETED-002 && rpm -ivh *.rpm ;
#
# Now, Fedora 21's yum should be installed...
#
# EXTRA -- install 'yumex'
#    cd /root/RPMs/002-F24-yum/COMPLETED-003 && rpm -ivh *.rpm ;
#
# yumex looks pretty good and seems to work just fine.
#
# SHAPSHOT
#
###############################################################################
# yum erase rpm-python3 ; # This removes 'dnf' and some dependencies.
# MAY NOT BE A GOOD IDEA...
# Okay, seems like removing 'rpm-python3' prevented me from logging in after reboot.
# Reverting to previous snapshot and rebooting verified the issue.
# Doesn't seem like keeping dnf is going to hurt anything.
#
Removed:
  rpm-python3.x86_64 0:4.13.0.1-1.fc24                                                                                                                                                            

Dependency Removed:
  abrt.x86_64 0:2.8.2-1.fc24                  abrt-addon-ccpp.x86_64 0:2.8.2-1.fc24     abrt-addon-kerneloops.x86_64 0:2.8.2-1.fc24    abrt-addon-pstoreoops.x86_64 0:2.8.2-1.fc24       
  abrt-addon-python3.x86_64 0:2.8.2-1.fc24    abrt-addon-vmcore.x86_64 0:2.8.2-1.fc24   abrt-addon-xorg.x86_64 0:2.8.2-1.fc24          abrt-cli.x86_64 0:2.8.2-1.fc24                    
  abrt-dbus.x86_64 0:2.8.2-1.fc24             abrt-desktop.x86_64 0:2.8.2-1.fc24        abrt-gui.x86_64 0:2.8.2-1.fc24                 abrt-java-connector.x86_64 0:1.1.0-8.fc24         
  abrt-plugin-bodhi.x86_64 0:2.8.2-1.fc24     abrt-python3.x86_64 0:2.8.2-1.fc24        abrt-retrace-client.x86_64 0:2.8.2-1.fc24      abrt-tui.x86_64 0:2.8.2-1.fc24                    
  anaconda.x86_64 0:24.13.7-1.fc24            anaconda-core.x86_64 0:24.13.7-1.fc24     anaconda-gui.x86_64 0:24.13.7-1.fc24           anaconda-tui.x86_64 0:24.13.7-1.fc24              
  dnf.noarch 0:1.1.10-4.fc24                  dnf-langpacks.noarch 0:0.15.1-4.fc24      dnf-plugins-core.noarch 0:0.1.21-5.fc24        gnome-abrt.x86_64 0:1.2.4-3.fc24                  
  libreport-python3.x86_64 0:2.7.2-1.fc24     python3-dnf.noarch 0:1.1.10-4.fc24        python3-dnf-langpacks.noarch 0:0.15.1-4.fc24   python3-dnf-plugins-core.noarch 0:0.1.21-5.fc24   
  python3-meh.noarch 0:0.44-1.fc24            python3-meh-gui.noarch 0:0.44-1.fc24      setroubleshoot.x86_64 0:3.3.11-1.fc24          setroubleshoot-plugins.noarch 0:3.3.6-1.fc24      
  setroubleshoot-server.x86_64 0:3.3.11-1.fc24
###############################################################################
# 
# 100-F24-KDE_f21]# yum -y install --downloadonly --downloaddir=. kde-workspace-4.11.18-3.fc21.x86_64.rpm
# STOPPING HERE.
#
# Looks like I can now get the missing packages from the F21 repo as Fedora 21's yum has identified ...



###############################################################################
###############################################################################
###############################################################################
# These are performed on F21 to get the packages for F24.

# yum  reinstall --downloadonly --downloaddir=. pygpgme pyliblzma pycairo rpm-python python-requests python-kitchen urlgrabber python-iniparse pyxattr yum-metadata-parser pyxdg langtable-python langtable-data langtable python-xpyb python-six python-chardet python-urllib3 python-backports-ssl_match_hostname python-ndg_httpsclient python-pyasn1 python-pycurl pyOpenSSL dbus-python python-backports python-pexpect pygtk2 pygobject2

# yum  reinstall --downloadonly --downloaddir=. pygpgme pyliblzma pycairo rpm-python python-requests python-kitchen urlgrabber python-iniparse pyxattr yum-metadata-parser pyxdg langtable-python langtable-data langtable python-xpyb python-six python-chardet python-urllib3 python-backports-ssl_match_hostname python-ndg_httpsclient python-pyasn1 python-pycurl pyOpenSSL dbus-python python-backports python-pexpect pygtk2 pygobject2 rpm-build-libs

# Slowly get rid of some unnecessary packages -->
#
#   yum -y erase bash-completion PackageKit (Not _really_ necessary ...)
# cd RPM-001 && rpm -ivh --nodeps --force --oldpackage --replacefiles --replacepkgs *.rpm



#   yum -y erase anaconda-core langtable-python3 lua-socket lua-json lua-lpeg

# yum erase lua-socket lua-json lua-lpeg
#
# Removed:
#   brasero-libs.x86_64 3.12.1-4.fc24                                  clutter-gst2.x86_64 2.0.18-1.fc24                              control-center.x86_64 1:3.20.2-1.fc24g
#   enca.x86_64 1.18-1.fc24                                            evince-nautilus.x86_64 3.20.1-3.fc24                           gdm.x86_64 1:3.20.1-3.fc24g
#   genisoimage.x86_64 1.1.11-31.fc24                                  giflib.x86_64 4.1.6-15.fc24                                    gmime.x86_64 2.6.20-6.fc24g
#   gnome-boxes.x86_64 3.20.4-2.fc24                                   gnome-classic-session.noarch 3.20.1-1.fc24                     gnome-documents.x86_64 3.20.2-1.fc24g
#   gnome-documents-libs.x86_64 3.20.2-1.fc24                          gnome-initial-setup.x86_64 3.20.1-1.fc24                       gnome-menus.x86_64 3.13.3-5.fc24g
#   gnome-online-miners.x86_64 3.20.1-1.fc24                           gnome-shell.x86_64 3.20.4-3.fc24                               gnome-shell-extension-alternate-tab.noarch 3.20.1-1.fc24g
#   gnome-shell-extension-apps-menu.noarch 3.20.1-1.fc24               gnome-shell-extension-background-logo.noarch 3.20.0-1.fc24     gnome-shell-extension-common.noarch 3.20.1-1.fc24g
#   gnome-shell-extension-launch-new-instance.noarch 3.20.1-1.fc24     gnome-shell-extension-places-menu.noarch 3.20.1-1.fc24         gnome-shell-extension-window-list.noarch 3.20.1-1.fc24g
#   gom.x86_64 0.3.2-2.fc24                                            grilo.x86_64 0.3.2-1.fc24                                      grilo-plugins.x86_64 0.3.3-1.fc24g
#   libcue.x86_64 2.0.1-2.fc24                                         libgnomekbd.x86_64 3.6.0-9.fc24                                libgovirt.x86_64 0.3.4-1.fc24g
#   libgrss.x86_64 0.7.0-2.fc24                                        libgsystem.x86_64 2015.2-2.fc24                                libiptcdata.x86_64 1.0.4-14.fc24g
#   libmx.x86_64 1.4.7-17.fc24                                         libosinfo.x86_64 0.3.0-2.fc24                                  libquvi.x86_64 0.9.4-8.fc24g
#   libquvi-scripts.noarch 0.9.20131130-6.fc24                         libusal.x86_64 1.1.11-31.fc24                                  libvirt-gconfig.x86_64 0.2.3-2.fc24g
#   libvirt-glib.x86_64 0.2.3-2.fc24                                   libvirt-gobject.x86_64 0.2.3-2.fc24                            libzapojit.x86_64 0.0.3-8.fc24g
#   lua-expat.x86_64 1.3.0-7.fc24                                      lua-json.noarch 1.3.2-6.fc24                                   lua-lpeg.x86_64 0.12.2-2.fc24g
#   lua-socket.x86_64 3.0-0.12.rc1.fc24                                media-player-info.noarch 22-2.fc24                             nautilus.x86_64 3.20.4-1.fc24g
#   pulseaudio-gdm-hooks.x86_64 8.0-6.fc24                             python3-beaker.noarch 1.5.4-13.fc24                            python3-mako.noarch 1.0.3-2.fc24g
#   python3-markupsafe.x86_64 0.23-9.fc24                              redhat-menus.noarch 12.0.2-10.fc24                             rhythmbox.x86_64 3.4.1-1.fc24g
#   telepathy-logger.x86_64 0.8.2-3.fc24                               totem.x86_64 1:3.20.1-1.fc24                                   totem-nautilus.x86_64 1:3.20.1-1.fc24g
#   totem-pl-parser.x86_64 3.10.6-2.fc24                               tracker.x86_64 1.8.3-1.fc24                                    vino.x86_64 3.20.2-1.fc24g
#
# Complete!


# DO THIS LAST!!!
# ...as dnf is needed to remove other "rpms" that are not needed.
#
# Get rid of dnf by unprotecting it, edit --
#  vi /etc/dnf/protected.d/dnf.conf
# then --
#  yum erase rpm-python3 ; # This removes 'dnf' and dependencies.

# Now, the tricky part of downgrading RPM...
yum  reinstall --downloadonly --downloaddir=. pygpgme pyliblzma pycairo rpm-python python-requests python-kitchen urlgrabber python-iniparse pyxattr yum-metadata-parser pyxdg langtable-python langtable-data langtable python-xpyb python-six python-chardet python-urllib3 python-backports-ssl_match_hostname python-ndg_httpsclient python-pyasn1 python-pycurl pyOpenSSL dbus-python python-backports python-pexpect pygtk2 pygobject2 rpm-build-libs rpm-libs
yum  reinstall --downloadonly --downloaddir=. pygpgme pyliblzma pycairo rpm-python python-requests python-kitchen urlgrabber python-iniparse pyxattr yum-metadata-parser pyxdg langtable-python langtable-data langtable python-xpyb python-six python-chardet python-urllib3 python-backports-ssl_match_hostname python-ndg_httpsclient python-pyasn1 python-pycurl pyOpenSSL dbus-python python-backports python-pexpect pygtk2 pygobject2 rpm-build-libs rpm-libs rpm
yum  reinstall --downloadonly --downloaddir=. pygpgme pyliblzma pycairo rpm-python python-requests python-kitchen urlgrabber python-iniparse pyxattr yum-metadata-parser pyxdg langtable-python langtable-data langtable python-xpyb python-six python-chardet python-urllib3 python-backports-ssl_match_hostname python-ndg_httpsclient python-pyasn1 python-pycurl pyOpenSSL dbus-python python-backports python-pexpect pygtk2 pygobject2 rpm-build-libs rpm-libs rpm lua
