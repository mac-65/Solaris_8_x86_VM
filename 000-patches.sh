#! /bin/sh

###############################################################################
# Nov 22, 2019
# All of this should run fine under Solaris 8's '/bin/sh'.
#
# For the life of me, I could _not_ get './install_cluster' to work!
# The complaint was that each directory was invalid.  The 'net offered nothing!
# So, I had to write this to use '/usr/sbin/pkgadd' - I think it'll be okay...
#

ATTR_OFF="`tput sgr0`" ;
ATTR_BOLD="${ATTR_OFF}`tput bold`" ; # shelltool has no support for attributes :(.
ATTR_RED_BOLD="${ATTR_OFF}`tput setaf 1; tput bold`" ;
ATTR_RED="${ATTR_OFF}`tput setaf 1`" ;
ATTR_GREEN="${ATTR_OFF}`tput setaf 2`" ;
ATTR_GREEN_BOLD="${ATTR_OFF}`tput setaf 2; tput bold`" ;
ATTR_YELLOW="${ATTR_OFF}`tput setaf 3`" ;
ATTR_BLUE_BOLD="${ATTR_OFF}`tput setaf 4; tput bold`" ;
ATTR_CYAN_BOLD="${ATTR_OFF}`tput setaf 6; tput bold`" ;

# on the Solaris VM, man -s4 admin for details...
PKGADD_ADMIN='/root/pkgadd-admin' ;
PKGADD='/usr/sbin/pkgadd' ;
GREP='/usr/xpg4/bin/grep' ;

###############################################################################
# Skip running the 'prepatch' script if it's there (seems to go better).
#
SKIP_PREPATCH=1 ;

###############################################################################
# I have absolutely no idea where this is *supposed* to be set, but the patches
# need it in particular for the 'postpatch' scripts (there aren't many, but
# 112439 runs a 'postpatch' script and the '/dev/random' and '/dev/urandom'
# will NOT be built correctly (after rebooting) if it is not run).
#
ROOTDIR='/' ;
export ROOTDIR ;

PKG_LOG_FILE="/root/`basename $0 .sh`-log.txt" ;
PKG_DELAY='' ;
PKG_TALLY=0 ;
PKG_NONZERO=0 ;
PKG_FATALS=0 ;

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
 # - copy required scripts and package directories to /root   #
 # - enter maintenance mode using 'init S'                    #
 #                                                            #
 # The 2nd part will add the patches using '`tput setaf 3`/usr/sbin/pkgadd`tput sgr0`' #
 #                                                            #
 # After logging in again, cd /root and run ./000-patches.sh  #
 # to complete the installation of the recommended patches.   #
 #                                                            #
 # If 112439 was added (showrev -p), the links will be built  #
 # for '/dev/random' & '/dev/urandom' since the installation  #
 # of 112439 does NOT do it (at least in the VM).             #
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
       "${ATTR_BOLD}Enter delay (seconds to sleep between packages), RETURN for none${ATTR_OFF}" ;
    read PKG_DELAY ;
  fi # }

  /bin/rm -f "${PKG_LOG_FILE}" ;

  if [ "${PART}" -eq 1 ] ; then # {

    ###########################################################################
    # We copy things because we lose the mount point for the ISO in 'S' mode.
    # 'J2SE_Solaris_8_x86_Recommended' has 112439 which is needed for ssl/ssh.
    #
    printf "${ATTR_BOLD}%s${ATTR_OFF}.." 'Copying files' ;
    mkdir -p /root/bin ;
    printf '%s\n' '.' ;
    for pkg in 8_x86_Recommended              \
               J2SE_Solaris_8_x86_Recommended \
               000-patches.sh                 \
               pkgadd-admin                   \
        ; do
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
    # after the patches are applied, so I guess that's a SUCCESSFUL indicator.
    #
    # Everything in 'patch_order' is guaranteed to be a directory...
    #
    for patch_dir in `cat patch_order` ; do # {

       ########################################################################
       # There aren't many pre/post scripts and should be run for completeness.
       #
       patch_dev="/root/${recommended}/${patch_dir}" ;
       cd "${patch_dev}" ; # in patch directory, check and run './prepatch'...
       {
          echo ;
          echo '###########################################################' ;
          echo '###########################################################' ;
          printf "IN '%s'\n" "`/bin/pwd`" ;
          if [ ${SKIP_PREPATCH} -eq 0 -a -x ./prepatch ] ; then

             echo "RUNNING './prepatch'..." ;
             ./prepatch ;
             if [ $? -ne 0 ] ; then
                echo "SKIPPING '${patch_dev}' -- './prepatch' returned NON-ZERO" ;
                continue ;
             fi ;
          fi ;
       } 2>&1 | tee -a "${PKG_LOG_FILE}" \
              | sed -e "s/^RUNNING/${ATTR_YELLOW}RUNNING${ATTR_OFF}/" \
                    -e "s#^SKIPPING#${ATTR_RED}SKIPPING${ATTR_OFF}#" ;

       for patch in `ls -d S*` ; do # {
         [ ! -d "${patch}" ] && continue ; # it's NOT a directory, then skip it

         PKG_TALLY=`expr ${PKG_TALLY} + 1` ;

         { echo ; echo ;
         echo '#############################################' ; } \
           >> "${PKG_LOG_FILE}" ;

         { ${PKGADD} -a ${PKGADD_ADMIN} -d "${patch_dev}" ${patch} ;
           RC=$? ; echo ${RC} > /tmp/RC$$ ;
         } 2>&1 | tee -a "${PKG_LOG_FILE}" ;

         SLEEP_TIME=${PKG_DELAY} ;

         RC=`cat /tmp/RC$$` ;
         printf "${RC}, " ;

         case $RC in
           0) printf "${ATTR_GREEN}%s - ${ATTR_BLUE_BOLD}%s${ATTR_OFF}\n" \
                'SUCCESS' "${patch_dir}/${patch}" ;
              ;;
           ####################################################################
           # We'll see '4' if the package was already installed (so it seems).
           [24]) printf "${ATTR_YELLOW}%s - ${ATTR_BLUE_BOLD}%s${ATTR_OFF}\n" \
                'ALREADY INSTALLED' "${patch_dir}/${patch}" ;
              PKG_NONZERO=`expr ${PKG_NONZERO} + 1` ;
              ;;
           6) printf "${ATTR_YELLOW}%s - ${ATTR_BLUE_BOLD}%s${ATTR_OFF}\n" \
                'OBSOLETE' "${patch_dir}/${patch}" ;
              PKG_NONZERO=`expr ${PKG_NONZERO} + 1` ;
              ;;
           8) printf "${ATTR_YELLOW}%s - ${ATTR_CYAN_BOLD}%s${ATTR_OFF}\n" \
                'NOT INSTALLED' "${patch_dir}/${patch}" ;
              PKG_NONZERO=`expr ${PKG_NONZERO} + 1` ;
              ;;
           13) printf "${ATTR_YELLOW}%s - ${ATTR_CYAN_BOLD}%s${ATTR_OFF}\n" \
                'SYMBOLIC LINK?' "${patch_dir}/${patch}" ;
              PKG_NONZERO=`expr ${PKG_NONZERO} + 1` ;
              ;;
           18) printf "${ATTR_RED_BOLD}%s - ${ATTR_BOLD}%s${ATTR_OFF}\n" \
                'NO DISK SPACE' "${patch_dir}/${patch}" ;
              PKG_NONZERO=`expr ${PKG_NONZERO} + 1` ;
              ;;
           25) printf "${ATTR_CYAN_BOLD}%s - ${ATTR_CYAN_BOLD}%s${ATTR_OFF}\n" \
                'MISSING DEPENDENCY' "${patch_dir}/${patch}" ;
              PKG_NONZERO=`expr ${PKG_NONZERO} + 1` ;
              ;;
           *) printf "FATAL -- "  >> "${PKG_LOG_FILE}" ;
              printf "${ATTR_RED_BOLD}%s - ${ATTR_BOLD}%s${ATTR_OFF}\n" \
                'ERROR' "${patch_dir}/${patch}" ;
              SLEEP_TIME=3 ;
              PKG_FATALS=`expr ${PKG_FATALS} + 1` ;
              ;;
         esac

         echo "RC = ${RC}" >> "${PKG_LOG_FILE}" ;

         if [ "${SLEEP_TIME}" != '' ] ; then sleep "${SLEEP_TIME}" ; fi
       done # }

       ########################################################################
       # Run the 'postpatch' script if it's there.
       # This _should_ properly setup the /dev/random links I was missing...
       #
       {  if [ -x postpatch ] ; then

          echo "RUNNING './postpatch'..." ;
          ./postpatch ;
       fi ; } 2>&1 | tee -a "${PKG_LOG_FILE}" \
                   | sed -e "s/^RUNNING/${ATTR_BLUE_BOLD}RUNNING${ATTR_OFF}/" ;

    done # }
   done # }

   ############################################################################
   ############################################################################
   #
  cat << HERE_DOC
`tput smso; tput bold`/************************************\\
**************************************
**  ALL PATCHES HAVE BEEN APPLIED.  **
**  `printf '%3d' ${PKG_TALLY}` packages were processed:    **
**  `printf '%3d' ${PKG_NONZERO}` had a non-zero status,      **
**  `printf '%3d' ${PKG_FATALS}` had a fatal error status.   **
**************************************
\************************************/`tput sgr0`

(See '${PKG_LOG_FILE}' for details.)

You should change root's home directory to '/root' in '/etc/passwd', ${ATTR_BOLD}REBOOT!${ATTR_OFF}.

HERE_DOC

  fi # }
fi # }

