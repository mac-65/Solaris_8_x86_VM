#! /bin/bash

###############################################################################
# Oct 24, 2019   Oct 26, 2019
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
###############################################################################
# VIRTUALBOX SETTINGS:
# - System  :: Processor :: 2
#              Motherboard :: Enable I/O APIC
#              1 Gig system memory (s/b okay for this)
# - Display :: Video Memory :: 80M
#              Enable 3D Acceleration
# - Storage :: mount the 'sol-8-u7-ia-v1.iso' CD
#              (disk size 20G from initial setup.)
# - Audio   :: PulseAudio
#              SoundBlaster 16, this does work!
# - Network :: Attached to :: Bridged Adapter  << IMPORTANT >>
#              select correct _real_ interface on host machine,
#              Adapter Type :: PCnet-PCI II (Am79C970A) seems to work
#              NOTE, docs talk about NAT and using 10.0.2.15, but there's
#              nothing obvious in any of the VirtualBox menus that the
#              10.0.2.X network should be used for NAT (maybe this has been
#              my problem).
#
# Condensed from -->
#              https://forums.virtualbox.org/viewtopic.php?f=20&t=41921
#
# After setting the devices (especially the VGA display setting), it'll
# boot to a desktop (don't worry about enabling DMA right now) to identify
# the system for installation.
# - click Continue
# - select radio button Networked: 'Yes', CONTINUE
# - select radio button Use DHCP: 'No', CONTINUE
# - enter hostname 'solaris8.nj', CONTINUE
# - enter IP address '192.168.1.111'
# - 'Yes' to part of subnet, set the Netmask for the subnet (255.255.255.0)
# - 'No' IPV6
#   ...wait for 'Confirm Information' and press 'Continue'
# - 'No' Kerberos Security
# - 'Name Service' and select 'None', CONTINUE
# - set the time by Geographic region, etc.
# <> everything's pretty normal (disk formatting, software selection, etc.)
#    up until step #56.  MAKE SURE TO MAKE '/' LARGE ENOUGH!  This is needed
#    for things like firefox and other large things...
#    - add a partition for '/usr/openwin' (no special reason).
#      / 8000, /usr/openwin 1024, swap 1024, /export/home 14524
#    - full dist + OEM support
# <> START INSTALLATION (auto reboot is okay)
# ----------------------------------------------------------------------------
# - After the reboot, enable DMA (see below)
# <> then continue to boot from the disk (NOT the CD)
# - on the <<< Current Boot Parameters >>> screen, boot into single user
#   mode using 'b -s'.  There's no root password yet, so just hit 'RETURN'.
# - EDIT '/etc/init.d/webstart' and look for the 'CUI=' line and change it to
#   'CUI=yes'.  Write, quit, and
# <> exit to continue with normal startup.
# - set the root password
# - the Web Start Launcher will start in command-line mode.
# ----------------------------------------------------------------------------
# <> Enter '1' for CD media, the system will 'eject' "sol-8-u7-ia-v1.iso" and
#   mount "sol-8-u7-ia-v2.iso" through VirtualBox.  Then press ENTER in window.
#   Installation will continue (does seem a lot faster w/DMA enabled).
# - The rest of the installation is pretty normal.  "sol-8-u7-lang-ia.iso" is
#   the final CD to install from.
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# <> MAKE A SNAPSHOT AFTER THE INSTALL AND BEFORE PRESSING RETURN TO REBOOT <>
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
###############################################################################
# file:///aku/VMs-aku/Html/Solaris Tips & Tricks - VM Back.html
# 'Solaris 8-037-enable DMA.png' ==> 'Solaris 8-040-enable DMA.png'.
#
#   Enabling DMA for Hard Disk Drives (Solaris 8)
#   Without DMA enabled, disk access in the virtual machine is extra-slow.
#   Enabling DMA does not make it lightning-fast, it makes things tolerable.
#   DMA is disabled by default on Solaris 8 so you have to manually enable it.
#
#   Boot the VM.
#   On "SunOS Secondary Boot" screen, press <ESC> key when prompted.
#   On "Solaris Device Configuration Assistant" screen, press <F2> to proceed.
#   On "Identified Devices" screen, press <F2> to proceed.
#   On "Boot Solaris" screen, press <F4> to start "Boot Tasks".
#   On "Boot Tasks" screen, choose "View/Edit Property Settings" and press <F2> to proceed.
#   On "View/Edit Property Settings" screen, search an item named "ata-dma-enabled" and change its value to "1".
#   Press <F2> then <F3> to go back to "Boot Solaris" screen.
#   Choose "DISK" then press <F2> to continue booting the operating system.

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
printf '%s? ' "${ATTR_BOLD}INSTALL${ATTR_OFF}: gzip, bzip2, bash, and vim" ;
read ANS ;
if [ "${ANS}" = 'y' ] ; then
    mkdir -p '/usr/tgcware' ; # Have to manually make the directory...
    chmod ugo+rx,go-w,u+w '/usr/tgcware' ;
    chgrp bin '/usr/tgcware' ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gzip-1.6-1.tgc-sunos5.8-i386-tgcware ;

      #########################################################################
      # Trial and error to get the dependencies correct...
      # NOTE, some packages ask for 'libgcc_s1-4.7.3-1' (not a problem).
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libgcc_s1-4.7.4-1.tgc-sunos5.8-i386-tgcware ;
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libstdc++6-4.7.4-1.tgc-sunos5.8-i386-tgcware ;

      #########################################################################
      # The next 2 have circular dependencies...
      # You'll just get a WARNING that you'll have to okay, but other than
      # that, installation will work normally.
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d gettext-0.19.8.1-1.tgc-sunos5.8-i386-tgcware ;
      echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d libiconv-1.15-1.tgc-sunos5.8-i386-tgcware ;

    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d bash-4.4.23-1.tgc-sunos5.8-i386-tgcware ;
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d vim-8.0.1733-1.tgc-sunos5.8-i386-tgcware ;
      #########################################################################
      # This wants the earlier version libgcc_s1-4.7.3-1, s/b okay.
    echo | ${PKGADD} -a "${PKGADD_ADMIN}" -d bzip2-1.0.6-2.tgc-sunos5.8-i386-tgcware ;

    ###########################################################################
    # These will make Solaris 8 a little more linux-like.  We _only_ make vim
    # available as '/bin/vim'.
    #
    # The PATH variable should be modified to include '/usr/tgcware/bin' as
    # linking the/any tgcware binaries in '/bin' may break existing Solaris 8
    # scripts, etc.
    #
    # NOTE, Solaris 8 comes with bash verison 2.03 installed as '/bin/bash'.
    # NOTE, unlike linux, '/bin/vi' will be a different editor than '/bin/vim'.
    echo "Some common network utility programs are not visible in '/usr/bin'..." ;
    printf '%s? ' "${ATTR_BOLD}ADD HARD LINKs${ATTR_OFF}" ; read ANS ;
    if [ "${ANS}" = 'y' ] ; then
        set -x ;
        (
          cd /bin ;
          ln /usr/sbin/ping . ;
          ln /usr/sbin/ifconfig . ;
          ln /usr/sbin/nslookup . ;
          ln /usr/tgcware/bin/vim . ;
        )
    fi

    mkdir -p /root/bin ;
    chmod -R u+rwx,go-rwx /root ;
    chgrp -R root /root ;

    ###########################################################################
    # Simple section to add a single user.
    # NOTE, the error checking is not very robust...
    #
    { set +x ; } >/dev/null 2>&1 ; # Sun's old /bin/sh won't work with {}s
    printf '%s? ' "${ATTR_BOLD}ADD NEW USER${ATTR_OFF}" ; read ANS ;
    if [ "${ANS}" = 'y' ] ; then
        while [ "${ANS}" = 'y' ] ; do
          printf '%s? ' "User's FULL name"  ; read USER_FULLNAME ;
          printf '%s? ' "User's LOGIN name" ; read USER_NAME ;
          printf '%s? ' "User's ID"         ; read USER_ID ;
          printf '%s? ' "User's GROUP ID"   ; read USER_GROUP_ID ;

          USER_BASHRC='' ;
          USER_SHELL='' ;
          while [ "${USER_SHELL}" = '' ] ; do
            echo 'SHELL SELECTION:' ;
            echo '  1) /bin/sh' ;
            echo '  2) /bin/bash (2.03, Solaris 8 default)' ;
            echo '  3) /usr/tgcware/bin/bash (4.4.23-1)' ;
            echo '     Also installs a BASIC .bashrc script in "${HOME}", and' ;
            echo "     makes '.profile' a link to '.bashrc' (for ssh logins)." ;
            printf '%s? ' "Please enter shell [3]" ; read USER_SHELL ;
               [ "${USER_SHELL}" = '' ] && USER_SHELL=3 ; # SELECT default

            case "${USER_SHELL}" in
             1) USER_SHELL='/bin/sh' ;
                ;;
             2) USER_SHELL='/bin/bash' ;
                ;;
             3) USER_SHELL='/usr/tgcware/bin/bash' ;
                USER_BASHRC='bashrc' ; # *ONLY* for the latest bash version.
                ;;
             *) USER_SHELL='' ; # Ring the bell, too!
                printf '%s' 'ERROR - invalid selection' ;
                sleep 1 ; echo ', please try again.' ;
                ;;
            esac
          done

          printf '%s? ' "Any changes to the above [n]" ; read ANS ;
        done
        set -x ;
        groupadd -g "${USER_GROUP_ID}" "${USER_NAME}" ;
        useradd -u "${USER_ID}"                \
                -g "${USER_GROUP_ID}"          \
                -d "/export/home/${USER_NAME}" \
                -m -c "${USER_FULLNAME}"       \
                -s "${USER_SHELL}" "${USER_NAME}" ;

        #######################################################################
        # Install my *special* '.vimrc' file that I've used, like forever!
        { set +x ; } >/dev/null 2>&1 ;
        printf '%s? ' "Include a version of a .vimrc [y]" ; read ANS ;
        [ "${ANS}" != 'n' ] && cp vimrc "/export/home/${USER_NAME}/.vimrc" ;

        #######################################################################
        # Ensure the permissions are "tight."
        # Make a few useful sub-directories for the user as well.
        # If we're adding '.bashrc', its permissions will be set correctly.
        set -x ;
        if [ "${USER_BASHRC}" != '' ] ; then
            /bin/cp bashrc "/export/home/${USER_NAME}/.bashrc" ;
            pushd "/export/home/${USER_NAME}" ;
            /bin/rm -f .profile ;
            ln -s .bashrc .profile ;
            popd ;
            for USER_DIR in bin Downloads Documents ; do
               mkdir -p "/export/home/${USER_NAME}/${USER_DIR}" ;
            done
        fi
        chown -R "${USER_NAME}" "/export/home/${USER_NAME}" ;
        chgrp -R "${USER_NAME}" "/export/home/${USER_NAME}" ;
        chmod -R u+rwx,go-rwx   "/export/home/${USER_NAME}" ;

        { set +x ; } >/dev/null 2>&1 ;
        passwd "${USER_NAME}" ;
    fi

    cat << HERE_DOC

###########################################################################
# You may want to "fine-tune" the .vimrc and .bashrc files now...         #
#                                                                         #
# `tput smso`!!! ALSO !!!`tput sgr0`,                                                           #
# - manually edit '/etc/passwd' and set root's home directory to '/root'. #
# - add '/usr/tgcware/bin' and '/usr/tgcware/gnu' to any future users'    #
#   PATH enviornment.                                                     #
###########################################################################

HERE_DOC

fi

