#! /bin/sh

###############################################################################
# Sep 14, 2021
# All of this should run fine under Solaris 8's '/bin/sh'.
#
# NOTES:
#   A bunch of pre-compiled Solaris 8_x86 binaries
#     http://jupiterrise.com/tgcware/
#     ALSO see :: 'https://github.com/tgc/buildpkg'.
#
#   Also, see '/aku/VMs-aku/Html/Solaris Tips & Tricks - VM Back.html'
#   Found it! ==>
#     ftp://ftp.zenez.com/pub/oss/lxrun/lxrun-0.9.6pre1.tar.gz
#
# HACKs :: For quick and (insecure) dirty copy to/from the Solaris 8 VM,
#          add the files '~/.rhosts' with the single entry of '+'.
#          This will allow rcp to function without a lot of hassel, e.g. -->
#             rcp user@192.168.1.104:/var/sadm/install/admin/default .
#          Don't forget to remove it as it's a _huge_ security flaw.
#       :: pkgadd always prompts for package selection (the default is 'all'.
#          The 'echo' forces the default and the rest of the prompts is
#          (hopefully) managed by the provided 'pkgadd-admin' file.
#

ATTR_BOLD="`tput bold`" ; # shelltool has no support for attributes :(.
ATTR_OFF="`tput sgr0`" ;

# on the Solaris VM, man -s4 admin for details...
PKGADD_ADMIN='./pkgadd-admin' ;
PKGADD='/usr/sbin/pkgadd' ;

if [ ! -f "${PKGADD_ADMIN}" ] ; then
    echo "ERROR :: '${PKGADD_ADMIN}' was not found." ;
    exit 2 ;
fi

###############################################################################
# Let's see if 'gcc-4.7.4-2' resolved the issues related to '/lib/libm.so.1'.
#
printf '%s? ' \
   "${ATTR_BOLD}INSTALL${ATTR_OFF}: gcc-4.7.4-2 ..." ;
read ANS ;
if [ "${ANS}" = 'y' ] ; then
    mkdir -p '/usr/tgcware' ; # Have to manually make the directory...
    chmod ugo+rx,go-w,u+w '/usr/tgcware' ;
    chgrp bin '/usr/tgcware' ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-4.7.4-2.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-c++-4.7.4-2.tgc-sunos5.8-i386-tgcware ; #ok

    echo 'DONE...' ;
fi

