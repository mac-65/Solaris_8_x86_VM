#! /bin/sh

###############################################################################
# Oct 27, 2019
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
# gcc-4.7.4-1 was a bust for some reason realted to '/lib/libm.so.1'.
#
printf '%s? ' \
   "${ATTR_BOLD}INSTALL${ATTR_OFF}: gcc + dependencies, coreutils, findutils, make, tar, top ..." ;
read ANS ;
if [ "${ANS}" = 'y' ] ; then
    mkdir -p '/usr/tgcware' ; # Have to manually make the directory...
    chmod ugo+rx,go-w,u+w '/usr/tgcware' ;
    chgrp bin '/usr/tgcware' ;

      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d zlib-1.2.11-1.tgc-sunos5.8-i386-tgcware ; #ok
        echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d m4-1.4.17-1.tgc-sunos5.8-i386-tgcware ; #ok
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d flex-2.6.4-1.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d binutils-2.32-1.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d findutils-4.4.2-2.tgc-sunos5.8-i386-tgcware ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libgomp1-4.7.4-1.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gmp-6.1.2-1.tgc-sunos5.8-i386-tgcware ; #ok

      # NOTE, some packages ask for 'libgcc_s1-4.7.3-1' (not a problem).
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libppl11-0.12.1-1.tgc-sunos5.8-i386-tgcware ; #ignore

      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libppl_c4-0.12.1-1.tgc-sunos5.8-i386-tgcware ; #ignore
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libcloog0-0.15.11-1.tgc-sunos5.8-i386-tgcware ; #ignore

      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d mpfr-3.1.4-1.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d mpc-1.0.3-1.tgc-sunos5.8-i386-tgcware ; #ok

      #########################################################################
      # gcc-4.7.4-1 is a bust (problem with '/lib/libm.so.1' for some reason.
      # It installs okay, but won't build 'hello_world.c'.
      #
    if false ; then
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-4.7.4-1.tgc-sunos5.8-i386-tgcware ; #ok
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-c++-4.7.4-1.tgc-sunos5.8-i386-tgcware ; #ok
    fi

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-2.95.3-2.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-c++-2.95.3-2.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libstdc++2-2.95.3-2.tgc-sunos5.8-i386-tgcware ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-3.4.6-6.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gcc-c++-3.4.6-6.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libstdc++6-3.4.6-6.tgc-sunos5.8-i386-tgcware ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d coreutils-8.23-1.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d make-3.82-2.tgc-sunos5.8-i386-tgcware ; #ok
      ( cd /bin ; ln /usr/tgcware/bin/gmake ) ; # Nice...
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d tar-1.28-1.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d top-3.8beta1-1.tgc-sunos5.8-i386-tgcware ; #ok
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d screen-4.0.3-3.tgc-sunos5.8-i386-tgcware ; #ok

    echo 'DONE...' ;
fi

