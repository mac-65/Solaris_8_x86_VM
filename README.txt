
exit 0;

# A bunch of pre-compiled Solaris 8_x86 binaries
#   http://jupiterrise.com/tgcware/
#   (https://github.com/tgc/buildpkg)
#
# Packages referenced by the install scripts ==>
#   grep -ho '[^ ][^ ]*tgcware ;' uncompressed/0* | sort | uniq -c | wc -l
#
# Also, see '/aku/VMs-aku/Html/Solaris Tips & Tricks - VM Back.html'
# Found it! ==>
#   ftp://ftp.zenez.com/pub/oss/lxrun/lxrun-0.9.6pre1.tar.gz
#
# groupadd -g 1001 loginid
# useradd -d /export/home/loginid -u 1000 -m -c "Stephen" -g loginid -s /bin/sh loginid
# passwd loginid
# chown -R loginid /export/home/loginid
#
# Solaris 8 after package installation ==> gdf -h /
#    Filesystem       Size  Used Avail Use% Mounted on
#    /dev/dsk/c0d0s0  7.7G  1.4G  6.3G  18% /
#
###############################################################################
# Got really, really stuck w/network.  So I decided to build an ISO of the
# packages and just mount the ISO through VirtualBox (YEAH, it worked)...
#
# After installing the '000-gzip.sh' script, I also made some hard links
# for vim from '/usr/tgcware/bin/'; ping and ifconfig from '/usr/sbin/...'
#
###############################################################################
# For internet:
# - create / add an entry in '/etc/defaultrouter' pointing to 192.168.1.1
# - build '/etc/resolv.conf' ==>
#     domain solaris8.nj
#     nameserver 75.75.75.75
#     nameserver 75.75.75.76
#     search hsd1.nj.comcast.net hsd1.nj.comcast.net. nj
# - /etc/hostname.pcn0 should contain 'solaris8'.
#
# Dunno why I couldn't get this w/sys-unconfig (been too long?)
# The network adapter in VirtualBox is NOT "NAT", but 'Bridged Adapter'.
# I think those were the only things...
#
###############################################################################
# firefox ::
# https://stackoverflow.com/questions/39484702/latest-firefox-package-for-solaris-10
#   https://ftp.mozilla.org/pub/firefox/releases/52.0.2esr/contrib/solaris_pkgadd/firefox-52.0.2esr.en-US.opensolaris-i386-pkg.bz2
#

###############################################################################
###############################################################################
# https://www.virtualbox.org/manual/ch04.html#additions-solaris
# http://download.virtualbox.org/virtualbox/4.0.2/
#
# kdmconfig
#
# X server installation steps located in
#  file:///aku/VMs-aku/Html/VMware%20SVGA%20driver%20for%20Solaris%20-%20VM%20Back.html
#
#  pkgadd -d `pwd` SUNWxf86u SUNWxf86r
#

    ###########################################################################
    # For internet:
    # - create / add an entry in '/etc/defaultrouter' pointing to 192.168.1.1
    # - build '/etc/resolv.conf' ==>
    #     domain solaris8.nj
    #     nameserver 75.75.75.75
    #     nameserver 75.75.75.76
    #     search hsd1.nj.comcast.net hsd1.nj.comcast.net. nj
    # - /etc/hostname.pcn0 should contain 'solaris8'.
    #
    # Dunno why I couldn't get this w/sys-unconfig (been too long?)
    # The network adapter in VirtualBox is NOT "NAT", but 'Bridged Adapter'.
    # I think those were the only things I had to manually hack / change...
    #
    # Didn't have any luck w/Sun's DHCP.
    #


###############################################################################
###############################################################################
# ln -s '/devives/pseudo/random@0:random' random
# ln -s '/devives/pseudo/random@0:urandom' urandom
###############################################################################
###############################################################################
# https://www.opencsw.org/mantis/print_bug_page.php?bug_id=2685
#
 Summary:   0002685: solaris 8 112438-03 /dev/random is a pipe, openssl_rt cannot be installed
Description:    openssl_rt (and BIND with it - that\'s how I noticed) got
uninstalled during a pkg-get -U due to the fact that /dev/random was not a link as usual, but a pipe.

pkg-get -i openssl_rt failed saying there was no /dev/random
(although there existed a pipe named /dev/random). Installer
advised to install patch 112438 although 112438-03 was already installed.

I managed to get openssl_rt and named installed and working again as follows:

reinstall 112438-03
rem_drv random
rm /dev/*random
add_drv -m \'* 644 root sys\' random
drvconfig

Now I had /dev/*random both as links.

pkg-get install bind ... OK (installs openssl_rt too)
reboot

Now named has been started correctly, but /dev/random became
a pipe again:

prw-r--r-- 1 root root 9216 Nov 27 15:48 /dev/random|
lrwxrwxrwx 1 root other 34 Nov 27 15:41 /dev/urandom -> ../devices/pseudo/random@0:urandom

name_to_major has 215, agrees with

c-w----r-T 1 root sys 215, 0 Nov 27 15:41 /devices/pseudo/random@0:random
c-w----r-T 1 root sys 215, 1 Nov 27 15:41 /devices/pseudo/random@0:urandom

This is my only Solaris 8 machine with such behavior, the rest have the usual links for /dev/*random.

named is apparently working OK now.
I don\'t know if named (and openssl_rt) will still work after a reboot.

Steps To Reproduce:
Additional Information:     Machine is Netra-X1

SunOS <hostname> 5.8 Generic_117350-25 sun4u sparc SUNW,UltraAX-i2

This might not be a blastwave bug. The machine is otherwise
stable to the point of boredom. I didn\'t try to reproduce
the bug because \"I never reboot\" but it looks completely
reproducible.

If the pipe is OK by itself then the test of /dev/random existence should probably be modified. Patch warning is OK,
it gives correct warning and it makes no sense to try to actually detect the patch.
Relationships
Attached Files:

