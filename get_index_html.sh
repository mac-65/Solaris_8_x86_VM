#! /bin/bash

###############################################################################
# Nov  6, 2019
#
# http://download.nust.na/pub3/solaris/sunfreeware/pub/freeware/KDE/IA32AMD32/KDE/

BASE_URL='http://download.nust.na/pub3/solaris/sunfreeware/pub/freeware/KDE/IA32AMD32/KDE/'
INDEX='./index.html' ;
WGET_FILES='./wget_files_list.txt' ;

APP_NAME="`basename \"$0\"`" ;
ORIGINAL_CMD="$0 $@" ;
LOG_FILE='./README-cmd.txt' ;
WAIT_TIME=20 ; # default to 20 seconds between each wget
MODULO_VAL=0 ; # a modulo, if greater than 1, to add to WAIT_TIME
FUZZY_VAL=0 ;
BUILD_LIST_ONLY=0 ;

REGX_SUFFIX_LIST='[.]bz2"|[.]md5"|[.]zip"|[.]gz"|[.]tgz"|[.]rar"' ;

###############################################################################
# Nothing fancy...
usage () {

if [ $# -ne 0 ] ; then
cat << HERE_DOC
`tput setaf 1; tput bold`ERROR -- `tput setaf 3`$@`tput sgr0`.

HERE_DOC
fi

cat << HERE_DOC
`tput bold`${APP_NAME}`tput sgr0`: usage --
   ${APP_NAME} -h              # Show this help message
 or
   ${APP_NAME} [-q] [-t seconds] [--limit-rate=value] base_url

Get all of the files that are at the location specified by the URL.
The files that are retrieved are file that have the following suffixes:
    `tput bold`.bz2   .md5   .zip   .gz   .tgz   .rar`tput sgr0`

 +suffix     add an additional suffix to the search list, can be specified
             multiple times as needed.  Note, `tput smul`the '.' is added by the script.`tput rmul`

 -q          show the wget commands that will be build against the index file
 -B          build the wget files list (get index.html if needed) and exit.
 -t seconds  minimum # of seconds to wait between each wget, `tput smul`default = ${WAIT_TIME}`tput rmul`
             a value of zero disable the wait between each wget
 -r int > 1  adds a random value modulo this integer to the -t option
 -reckless   assume if the file's there and its timestamp is less than the
             timestamp of 'index.html', then it's "already fully retrieved"

`tput smso`The files/packages are retrieved in the current directory.`tput rmso`

Lines beginning with '#' in `tput bold`${WGET_FILES}`tput sgr0` are ignored.
HERE_DOC

   exit 1 ;
}


###############################################################################
#
if [ $# -eq 0 -o \( $# -eq 1 -a "$1" = '-h' \) ] ; then
  usage ;
fi

PKG_CNT=0 ;
PKG_IDX=0 ;
LIMIT_RATE='' ;
SHOW_CMDS='';
BASE_URL='' ;
RECKLESS=0 ;

###############################################################################
#
A_TEMP_FILE=$(mktemp temp-XXXXXXX) ;
trap "/bin/rm -f \"${A_TEMP_FILE}\"; echo ; exit ;" 0 2 3 15 ;


###############################################################################
#
while [ $# -ne 0 ] ; do
    ARG="$1" ; shift ;

    case "${ARG}" in
       --limit-rate=[1-9]*)
          LIMIT_RATE="${ARG}" ;
        ;;
       -q)
          SHOW_CMDS='echo' ;
        ;;
       -reckless)
          RECKLESS=1 ;
        ;;
       -B)
          BUILD_LIST_ONLY=1 ;
        ;;
       http*)
          if [ "${BASE_URL}" != '' ] ; then
             usage 'URL was already specified' ;
          fi
          BASE_URL="${ARG}" ;
        ;;
       -r)
          [ $# -eq 0 ] && usage '-r requires an integer greater than 1' ;

          ARG="$1" ; shift ;
          if [ "${ARG}" -eq "${ARG}" -a "${ARG}" -gt 1 ] 2>/dev/null
          then
             MODULO_VAL="${ARG}" ;
          else
             usage "'${ARG}' format, -r requires an integer greater than 1" ;
          fi
        ;;
       -t)
          [ $# -eq 0 ] && usage '-t requires the number of seconds to sleep' ;

          ARG="$1" ; shift ;
          if [ "${ARG}" -eq "${ARG}" -a "${ARG}" -ge 0 ] 2>/dev/null
          then
             WAIT_TIME="${ARG}" ;
          else
             usage "'${ARG}' format, -t requires a non-ZERO positive integer" ;
          fi
        ;;
       +*)
          SUFFIX="${ARG}" ; # We don't care about differences between byte and char lengths.
          SUFFIX_LEN=${#SUFFIX} ;
          [ $SUFFIX_LEN -lt 2 ] && usage "'+' needs one or more characters as a suffix identifier" ;
          REGX_SUFFIX_LIST="${REGX_SUFFIX_LIST}|[.]${SUFFIX:1}\"" ;
        ;;
       -h*) usage ;
        ;;
       *) usage "invalid/unknown arg, '${ARG}'";
        ;;
    esac
done

if [ "${BASE_URL}" = '' ] ; then
    usage 'a base URL was not provided' ;
fi


###############################################################################
# Not everyone may have 'wget'...
#
WGET="`which --skip-alias --skip-functions wget 2>/dev/null` -c" ;
if [ $? -ne 0 ] ; then
  
    printf '%s\n' 'ERROR - wget was not found in $PATH.' ;
    exit 2 ;
fi


###############################################################################
###############################################################################
# START by:
#  - saving the command line, and
#  - getting/building the 'index.html' file from the site.
#  - build the (editable) list of files to pass to the wget loop.
#
{ NOW=`date` ;
  printf '# %s\n' "${NOW}" ;
  printf '#   %s\n\n' "${ORIGINAL_CMD}" ;
} >> "${LOG_FILE}" ;

if [ ! -f "${INDEX}" ] ; then
    ${WGET} "${BASE_URL}" ;
fi

if [ ! -f "${WGET_FILES}" ] ; then
    cat "${INDEX}"                        \
        | egrep "${REGX_SUFFIX_LIST}"     \
        | grep -ho 'href="[^"]*"'         \
        | sed -e 's/href="//' -e 's/"//'  \
    > "${WGET_FILES}" ;
fi

if [ "${BUILD_LIST_ONLY}" -eq 1 ] ; then
   echo "`tput setaf 2; tput bold`SUCCESS`tput sgr0` - list is built" ;
   exit 0 ;
fi


###############################################################################
# Get the files that we're interested in from the index.html file, brute force.
#
if [ -f "${INDEX}" ] ; then
    PKG_CNT=`cat "${WGET_FILES}" | egrep -v '^#' | wc -l` ;

    for FILENAME in `cat "${WGET_FILES}" | egrep -v '^#'` ; do

        (( PKG_IDX += 1 ));

        if [ "${SHOW_CMDS}" = '' ] ; then
           t_width=60;
           t_color_on="`tput setaf 6; tput bold`" ;
           t_color_off="`tput sgr0`" ;

           t_cnt_width=`echo -n ${PKG_CNT} | wc -c` ;
           t_pad='###############################################################';
           t_pad_len=`echo -n "${t_pad}" | wc -c` ;
           t_status="`printf '## %*d/%d files ##' $t_cnt_width $PKG_IDX $PKG_CNT`" ;
           t_status_len=`echo -n "${t_status}" | wc -c` ;
           (( t_len = t_width - t_status_len ));

           printf '%s%s%*.*s%s\n' "${t_color_on}" "${t_status}" $t_len $t_len "${t_pad}" "${t_color_off}" ;
           echo "`tput bold`${WGET} ${LIMIT_RATE} '${BASE_URL}`tput setaf 2`${FILENAME}'`tput sgr0`" ;
        fi

        #######################################################################
        # Tricky.  We want to know if a file was "already fully retrieved" and
        # if so, skip the sleep after the wget.  Also, wget always sets the
        # timestamp of the file to match the file's timestamp on the server
        # (spec'd like this? <> I might be relying on undocumented behavior).
        #
        # Of course, the notable exception is wget's 'index.html' file.
        #
        NO_WAIT_FLAG=0;
        if [ -f "${FILENAME}" -a "${FILENAME}" -ot "${INDEX}" ] ; then
           [ ${RECKLESS} -ne 0 ] && continue ;
           NO_WAIT_FLAG=1;
        fi
        [ "${SHOW_CMDS}" = '' ] && echo ;

        ${SHOW_CMDS}        ${WGET} ${LIMIT_RATE} "${BASE_URL}${FILENAME}" ;

        [ ${PKG_IDX} -eq ${PKG_CNT} ] && break ;

        if [ ${WAIT_TIME} -gt 0 -a ${NO_WAIT_FLAG} -eq 0 -a "${SHOW_CMDS}" = '' ] ; then
           # A slightly fancy countdown timer...
           FUZZY_VAL=$MODULO_VAL ;
           [ $MODULO_VAL -ne 0 ] && (( FUZZY_VAL = RANDOM % MODULO_VAL )) ;
           (( IDX = WAIT_TIME + FUZZY_VAL )) ;
           while [ ${IDX} -gt 0 ] ; do
              printf '%s%.3d' '.' "${IDX}" ; sleep 1; printf '' ;
              (( IDX-- ));
           done
           echo '    ';
        fi
    done

    printf "`tput setaf 2; tput bold`FILES DOWNLOADED:`tput sgr0` %d\n" $PKG_IDX ;

else
    echo 'ERROR -- FAILED TO GET "index.html" from' ;
    echo "         '${BASE_URL}'" ; echo ;
    exit 3;
fi

