#! /bin/sh

###############################################################################
# Oct 29, 2019
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
#
printf '%s? ' \
   "${ATTR_BOLD}INSTALL${ATTR_OFF}: ssh, wget + dependencies ..." ;
read ANS ;
if [ "${ANS}" = 'y' ] ; then
    mkdir -p '/usr/tgcware' ; # Have to manually make the directory...
    chmod ugo+rx,go-w,u+w '/usr/tgcware' ;
    chgrp bin '/usr/tgcware' ;

        echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d perl-5.28.1-1.tgc-sunos5.8-i386-tgcware ;
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d perl-Error-0.17019-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d openssl-1.0.2r-5.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libssh2-1.8.2-1.tgc-sunos5.8-i386-tgcware ;

       echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libssp0-4.7.4-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d openssh-8.1p1-1.tgc-sunos5.8-i386-tgcware ;

       echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libidn2-2.1.1a-1.tgc-sunos5.8-i386-tgcware ;
       echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d pcre-8.42-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d wget-1.20.3-1.tgc-sunos5.8-i386-tgcware ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d sed-4.7-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d grep-2.22-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d rsync-3.1.3-1.tgc-sunos5.8-i386-tgcware ;

      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d curl-cacerts-7.64.1-1.tgc-sunos5.8-i386-tgcware ;
        echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d nghttp2-1.38.0-1.tgc-sunos5.8-i386-tgcware ;
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d curl-7.64.1-1.tgc-sunos5.8-i386-tgcware ;
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d expat-2.2.5-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d git-2.16.5-1.tgc-sunos5.8-i386-tgcware ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d unzip-6.0-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d readline-6.3-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d smartmontools-6.4-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d tcl-8.5.18-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d tk-8.5.18-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d xzutils-5.2.4-1.tgc-sunos5.8-i386-tgcware ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gdb-7.8-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d pkgconf-1.6.0-2.tgc-sunos5.8-i386-tgcware ;

    ###########################################################################
    # Install devel packages, if the user wants.
    printf '%s? ' \
       "${ATTR_BOLD}INSTALL${ATTR_OFF} the devel packages [y]" ;
    read ANS ;
    if [ "${ANS}" != 'n' ] ; then
      for devel_pkg in *devel* ; do
        echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d ${devel_pkg} ;
      done
    fi

    ###########################################################################
    # I don't have a lot of understanding of the layout of the tgcware ssh
    # architecture, but these add some "standard" links in '/etc'...
    #
    # NOTE, sshd is controlled by the '/etc/init.d/tgc_sshd' script.
    #
    # A simple test is to log on to the Solaris 8 VM using ssh -X and try
    # running '/usr/openwin/demo/maze'.  The maze program should appear on
    # the host machine.  CAUTION -- there are some Solaris 8 X programs that
    # will hang the X server on the host when attempting certain operations.
    # You'll have to kill the ssh connection to regain control of the desktop.
    # I use this snippet (executing in another terminal window on the host)
    # when I'm experimenting on the host as a "fail-safe" -->
    #
    #    while true ; do sleep 300 ; pkill ssh ; done ; # Worst is 5 min wait.
    #
    # I don't know why this happens, but considering the age of the software,
    # it's amazing that most things actually still work in this enviornment.
    #
    # NOTE, when ssh'd into the VM, you'll note that the Solaris 8's '/bin/vi'
    # is pretty useless because of the "advanced" TERM=xterm-256color setting;
    # use '/bin/vim' -- that's why you installed it, right?
    ###########################################################################
    #
    printf '%s? ' \
       "${ATTR_BOLD}APPLY SSH HACKS${ATTR_OFF}: apply fixes for 'ssh -X' to work [y]" ;
    read ANS ;
    if [ "${ANS}" != 'n' ] ; then
        cd /etc ; ln -s '/usr/tgcware/etc/ssh' ;

        #######################################################################
        # On a "fresh" install (like we just performed above), sshd_config ==
        # sshd_config.default.  We don't bother making a backup since we're
        # _working_ on the backup.
        #
        cd ssh || { echo "ERROR, can't 'cd /etc/ssh', exiting..." ; exit 3 ; }
        if [ ! -f sshd_config.default ] ; then
           echo "ERROR, 'sshd_config.default' NOT FOUND, exiting..." ; exit 3 ;
        fi
        cat sshd_config.default  \
          | sed -e 's/^#X11Forwarding.*/X11Forwarding yes/'    \
                -e 's/^#X11UseLocalhost.*/X11UseLocalHost no/' \
          > sshd_config ;
        print 'RE-' ;
        /etc/init.d/tgc_sshd restart ;
    fi

    printf '\n%s\n' 'DONE...' ;
fi

