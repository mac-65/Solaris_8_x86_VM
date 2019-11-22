#! /bin/sh

###############################################################################
# Nov 22, 2019
# All of this should run fine under Solaris 8's '/bin/sh'.
#
# For the life of me, I could _not_ get './install_cluster' to work!
# The complaint was that each directory was invalid.  The 'net offered nothing!
# So, I had to write this to use '/usr/sbin/pkgadd' - I think it'll be okay...
#
# So, the patch cluster addresses the main issue of '/dev/random' which is
# needed for openssl, et. al.  Hopefully, these patches will really work!
#

ATTR_OFF="`tput sgr0`" ;
ATTR_BOLD="${ATTR_OFF}`tput bold`" ; # shelltool has no support for attributes :(.
ATTR_RED_BOLD="${ATTR_OFF}`tput setaf 1; tput bold`" ;
ATTR_GREEN_BOLD="${ATTR_OFF}`tput setaf 2; tput bold`" ;
ATTR_YELLOW="${ATTR_OFF}`tput setaf 3`" ;
ATTR_BLUE_BOLD="${ATTR_OFF}`tput setaf 4; tput bold`" ;
ATTR_CYAN_BOLD="${ATTR_OFF}`tput setaf 6; tput bold`" ;

# on the Solaris VM, man -s4 admin for details...
PKGADD_ADMIN='/root/pkgadd-admin' ;
PKGADD='/usr/sbin/pkgadd' ;
GREP='/usr/xpg4/bin/grep' ;

PKG_LOG_FILE="/root/`basename $0 .sh`-log.txt" ;
PKG_DELAY='' ;
PKG_TALLY=0 ;
PKG_ERRS=0 ;

PART=1;
PART_MSG="`tput setaf 2`START`tput sgr0`" ;
if [ "`/bin/pwd`" = '/root' ] ; then
    PART=2 ;
    PART_MSG="`tput setaf 5`CONTINUE`tput sgr0`" ;
fi

###############################################################################
#
printf '%s? ' \
   "${ATTR_BOLD}${PART_MSG} INSTALL: Recommended patches..." ;
read ANS ;
if [ "${ANS}" = 'y' ] ; then # {

  cat << HERE_DOC
 ##############################################################
 # `tput smso`This _same_ script will run in TWO parts:`tput sgr0`                  #
 #                                                            #
 # The first part will:                                       #
 # - mkdir -p /root/bin                                       #
 # - copy scripts and package directories to /root            #
 # - enter maintenance mode using 'init S'                    #
 #                                                            #
 # The 2nd part will add the patches using '`tput setaf 3`/usr/sbin/pkgadd`tput sgr0`' #
 #                                                            #
 # After logging in again, cd /root and run ./000-patches.sh  #
 # to complete the installation of the recommended patches.   #
 #                                                            #
 # If 112439 was added (showrev -p), the links will be built  #
 # for '/dev/random' and '/dev/urandom'.                      #
 #                                                            #
 # ${ATTR_RED_BOLD}A REBOOT SHOULD BE DONE TO ENSURE THE PATCHES TAKE EFFECT.`tput sgr0` #
 ##############################################################
HERE_DOC

  if [ ${PART} -eq 1 ] ; then # {
    printf '\n%s? ' \
       "${ATTR_BOLD}Enter 'y' to ${PART_MSG}...${ATTR_OFF}" ;
    read ANS ;
    if [ "${ANS}" != 'y' ] ; then # {
       echo 'ABORTED BY USER' ;
       exit 3;
    fi # }
  else # }{
    printf '\n%s? ' \
       "${ATTR_BOLD}Enter delay (seconds to sleep between packages)${ATTR_OFF}" ;
    read PKG_DELAY ;
  fi # }

  /bin/rm -f "${PKG_LOG_FILE}" ;

  if [ "${PART}" -eq 1 ] ; then # {

    ###########################################################################
    # We copy things because we lose the mount point for the ISO in 'S' mode.
    # It does not seem like many actually apply in '8_x86_Recommended', but
    # 'J2SE_Solaris_8_x86_Recommended' has 112439 which is needed for ssl/ssh.
    #
    printf "${ATTR_BOLD}%s${ATTR_OFF}.." 'Copying files' ;
    mkdir -p /root/bin ;
    printf '%s\n' '.' ;
    for pkg in 8_x86_Recommended              \
               J2SE_Solaris_8_x86_Recommended \
               000-patches.sh                 \
               pkgadd-admin                   ; do
      printf "${ATTR_CYAN_BOLD}%s${ATTR_OFF} .." "${pkg}" ;
        tar cf - "${pkg}" | ( cd /root && tar xf - ) ;
      printf "\r${ATTR_GREEN_BOLD}%s${ATTR_OFF} ...\n" "${pkg}" ;
    done

    echo "${ATTR_BLUE_BOLD}ENTERING SINGLE USER MODE" ;
    echo "${ATTR_BLUE_BOLD}ENTERING SINGLE USER MODE" ; sleep 2 ;
    echo "${ATTR_OFF}${ATTR_BOLD}" ;
    init S ;

  else # }{

   for recommended in 8_x86_Recommended J2SE_Solaris_8_x86_Recommended ; do # {
    cd "/root/${recommended}" || exit 2 ;

    ###########################################################################
    # For some reason, 'install_cluster' does NOT work even with the addition
    # of '-M'.  This part was trial and error, and even though it appears to
    # work, I don't know if it's correct.  But things DO seem to work "better"
    # after the patches are installed, so I guess that's SUCCESSFUL indicator.
    #
    for patch_dir in `cat patch_order` ; do
       patch_dev="/root/${recommended}/${patch_dir}" ;
       cd "${patch_dev}" ;
       for patch in `ls -d S*` ; do

         PKG_TALLY=`expr ${PKG_TALLY} + 1` ;

         { echo ; echo ;
         echo '###########################################################' ;
         echo '###########################################################' ; } \
           >> "${PKG_LOG_FILE}" ;

         { /usr/sbin/pkgadd -a /root/pkgadd-admin -d "${patch_dev}" ${patch} ;
           RC=$? ; echo ${RC} > /root/RC$$ ; } 2>&1 | tee -a "${PKG_LOG_FILE}" ;
         SLEEP_TIME=${PKG_DELAY} ;
         RC=`cat /root/RC$$` ;
         echo "RC = ${RC}" >> "${PKG_LOG_FILE}" ;
         case $RC in
           0) printf "${ATTR_GREEN_BOLD}%s - ${ATTR_BLUE_BOLD}%s${ATTR_OFF}\n" \
                'SUCCESS' "${patch_dir}/${patch}" ;
              ;;
           ####################################################################
           # We'll see 4 if the package was already installed (so it seems).
           4) printf "${RC}, ${ATTR_YELLOW}%s - ${ATTR_BLUE_BOLD}%s${ATTR_OFF}\n" \
                'ALREADY INSTALLED' "${patch_dir}/${patch}" ;
              PKG_ERRS=`expr ${PKG_ERRS} + 1` ;
              ;;
           6) printf "${RC}, ${ATTR_YELLOW}%s - ${ATTR_BLUE_BOLD}%s${ATTR_OFF}\n" \
                'OBSOLETE' "${patch_dir}/${patch}" ;
              PKG_ERRS=`expr ${PKG_ERRS} + 1` ;
              ;;
           8) printf "${RC}, ${ATTR_YELLOW}%s - ${ATTR_CYAN_BOLD}%s${ATTR_OFF}\n" \
                'NOT INSTALLED' "${patch_dir}/${patch}" ;
              PKG_ERRS=`expr ${PKG_ERRS} + 1` ;
              ;;
           13) printf "${RC}, ${ATTR_YELLOW}%s - ${ATTR_CYAN_BOLD}%s${ATTR_OFF}\n" \
                'SYMBOLIC LINK?' "${patch_dir}/${patch}" ;
              PKG_ERRS=`expr ${PKG_ERRS} + 1` ;
              ;;
           18) printf "${RC}, ${ATTR_RED_BOLD}%s - ${ATTR_BOLD}%s${ATTR_OFF}\n" \
                'NO DISK SPACE' "${patch_dir}/${patch}" ;
              PKG_ERRS=`expr ${PKG_ERRS} + 1` ;
              ;;
           25) printf "${RC}, ${ATTR_CYAN_BOLD}%s - ${ATTR_CYAN_BOLD}%s${ATTR_OFF}\n" \
                'MISSING DEPENDENCY' "${patch_dir}/${patch}" ;
              PKG_ERRS=`expr ${PKG_ERRS} + 1` ;
              ;;
           *) printf "${RC}, ${ATTR_RED_BOLD}%s - ${ATTR_BOLD}%s${ATTR_OFF}\n" \
                'ERROR' "${patch_dir}/${patch}" ;
              SLEEP_TIME=5 ;
              PKG_ERRS=`expr ${PKG_ERRS} + 1` ;
              ;;
         esac
         if [ "${SLEEP_TIME}" != '' ] ; then sleep "${SLEEP_TIME}" ; fi
       done
    done
   done # }

   ############################################################################
   #
  cat << HERE_DOC
`tput smso; tput bold`/************************************\\
**************************************
**  ALL PATCHES HAVE BEEN APPLIED.  **
**  `printf '%3d' ${PKG_TALLY}` packages were processed,    **
**  `printf '%3d' ${PKG_ERRS}` had a non-zero status.      **
**************************************
\************************************/`tput sgr0`

(See '${PKG_LOG_FILE}' for details.)

You should change root's home directory to '/root' in '/etc/passwd', REBOOT.

HERE_DOC

  fi # }
fi # }

