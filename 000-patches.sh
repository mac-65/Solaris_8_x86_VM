#! /bin/sh

###############################################################################
# Oct 30, 2019
# All of this should run fine under Solaris 8's '/bin/sh'.
#
# For the life of me, I could _not_ get './install_cluster' to work!
# The complaint was that each directory was invalid.  The 'net offered nothing!
# So, I had to write this to use '/usr/sbin/pkgadd' - I think it'll be okay...
#
# So, the patch cluster addresses the main issue of '/dev/random' which is
# needed for openssl, et. al.  Hopefully, these patches will really work!
#

ATTR_BOLD="`tput bold`" ; # shelltool has no support for attributes :(.
ATTR_OFF="`tput sgr0`" ;

# on the Solaris VM, man -s4 admin for details...
PKGADD_ADMIN='/root/pkgadd-admin' ;
PKGADD='/usr/sbin/pkgadd' ;

PART=1;
PART_MSG="`tput setaf 2`START`tput sgr0`" ;
if [ "`/bin/pwd`" = '/root' ] ; then
    PART=2 ;
    PART_MSG="`tput setaf 5`CONTINUE`tput sgr0`" ;
fi

###############################################################################
#
printf '%s? ' \
   "${ATTR_BOLD}${PART_MSG} INSTALL: J2SE_Solaris_8_x86_Recommended ..." ;
read ANS ;
if [ "${ANS}" = 'y' ] ; then # {

  cat << HERE_DOC
 ##############################################################
 # `tput smso`This _same_ script will run in TWO parts:`tput sgr0`                  #
 #                                                            #
 # The first part will:                                       #
 # - mkdir /root &&                                           #
 #    tar cf - J2SE* 000-patches.sh pkgadd-admin  \           #
 #        | ( cd /root && tar xf - )                          #
 # - init S                                                   #
 #                                                            #
 # The 2nd part will add the patches using '`tput setaf 3`/usr/sbin/pkgadd`tput sgr0`' #
 # (because I could `tput setaf 1; tput bold`NOT`tput sgr0` get './install_cluster' to work).     #
 #                                                            #
 # After logging in again, cd /root and run ./000-patches.sh  #
 # to complete the installation of the recommended patches.   #
 #                                                            #
 # A REBOOT WILL BE DONE TO ENSURE THE PATCHES TAKE EFFECT.   #
 ##############################################################
HERE_DOC

  printf '\n%s? ' \
     "${ATTR_BOLD}Enter 'y' to ${PART_MSG}...${ATTR_OFF}" ;
  read ANS ;
  if [ "${ANS}" != 'y' ] ; then # {
     echo 'ABORTED BY USER' ;
     exit 3;
  fi # }

  if [ "${PART}" -eq 1 ] ; then # {

    ###########################################################################
    # We copy things because we lose the mount point for the cdrom in 'S' mode.
    printf '%s' 'Copying files..' ;
    mkdir -p /root ;
    printf '%s\n' '.' ;
    tar cf - J2SE* 000-patches.sh pkgadd-admin  \
         | ( cd /root && tar xf - ) ;

    echo "Going to SINGLE USER MODE" ; sleep 2 ;
    init S ;

  else # }{

    cd '/root/J2SE_Solaris_8_x86_Recommended' || exit 2 ;

    for patch in `cat patch_order` ; do
       echo | ${PKGADD} -n -a "${PKGADD_ADMIN}" -d "${patch}" ;
    done

    ###########################################################################
    #
    echo 'DONE...' ;
  fi # }
fi # }

