#! /bin/bash

###############################################################################
# Simple script, emphasis on simple, to download the packages from
#  http://jupiterrise.com/tgcware/sunos5.8_x86/stable/
#
APP_NAME="`basename \"${0}\"`" ;
GET_URL_BASE='http://jupiterrise.com/tgcware/sunos5.8_x86/stable/' ;

WGET="`which --skip-alias --skip-functions wget 2>/dev/null` -c" ;
if [ $? -ne 0 ] ; then
  
    printf '%s\n' 'ERROR - wget was not found in $PATH.' ;
    exit 2 ;
fi


###############################################################################
# Nothing fancy...
usage () {

cat << HERE_DOC
`tput bold`${APP_NAME}`tput sgr0`: usage --
   ${APP_NAME} -h              # Show this help message
 or
   ${APP_NAME} shell_script [ shell_script .. ]

The packages are retrieved in the current directory.

HERE_DOC

   exit 1 ;
}


if [ $# -eq 0 -o \( $# -eq 1 -a "$1" = '-h' \) ] ; then
  usage ;
fi

###############################################################################
#
while [ $# -ne 0 ] ; do

    SH_SCRIPT="$1" ; shift ;
    if [ ! -s "${SH_SCRIPT}" ] ; then
       printf '%s\n' "ERROR - '${SH_SCRIPT}' is empty." ;
       usage ;
    fi

    ###########################################################################
    # The lines in each script are formatted to make this regexp easier.
    for PACKAGE in `cat "${SH_SCRIPT}"                  \
                        | grep -ho '[^ ][^ ]*tgcware ;' \
                        | sed -e 's/ ;//'` ; do
        if [ "${PACKAGE}" != 'gzip-1.6-1.tgc-sunos5.8-i386-tgcware' ] ; then
            PACKAGE="${PACKAGE}.gz" ;
        fi
        PACKAGE="${GET_URL_BASE}${PACKAGE}" ;
        ${WGET} "${PACKAGE}" ;
    done
done

