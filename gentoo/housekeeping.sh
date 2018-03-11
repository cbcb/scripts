#!/bin/bash
VERSION="0.0.1"
set -eu

# TODO #
# quiet mode
# better error handling than set -e

####### SETTINGS ###############################################################
#                                                                              #
# Sync after how many hours have passed?                                       #
HOURS=12                                                                       #
#                                                                              #
################################################################################

## Errors
SUCCESS=0
E_INVALID_ARG=1
E_NOT_ROOT=127

################################################################################
main(){
extended=""
force_sync=""
### Parse args
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    "-f"|"--force-sync")
        force_sync="true"
        ;;
    "-h"|"--help")
        print_help
        exit $SUCCESS
        ;;
    "-x"|"--extended")
        extended="true"
        ;;
    "-V"|"--version")
        echo "Version $VERSION"
        exit $SUCCESS
        ;;
    *)
        echo -e "$0: Unrecognized argument ${bold}$key${reset}."
        echo -e "Try ${bold}$0 --help${reset}."
        exit $E_INVALID_ARG
        ;;
esac
shift # over args
done

### Fun starts here
if [[ $UID -ne 0 ]]
  then
    e_error "We aren't root. Try ${bold}sudo $0${reset}"
    exit $E_NOT_ROOT
fi

##### Syncing #####
# only if last sync is more than $HOURS hours away

lastSync=$(grep -e "Sync completed" /var/log/emerge.log | tail -1 \
                                                | grep -o -E "[0-9]+")
now=$(date +%s)

if [[ $((lastSync + 60*60*HOURS )) -lt now || -n $force_sync ]]
  then
    e_start "eix-sync"
    take_a_break
  else
    e_info "Last sync was less then $HOURS hours ago, skipping..."
fi

#### Check for news items

count=$(eselect news count)
if [ "$count" -gt 0 ] ; then
    e_info "There are unread news items."
    echo -n "Read news now? [y/N] "
    read -r answer
    if [ "$answer" == "y" ] ; then
    eselect news read
    take_a_break
    fi
fi



e_start "emerge -avuDN @world"
take_a_break

e_start "emerge --depclean -a"
take_a_break

if [[ -n "$extended" ]]
  then
      e_start "revdep-rebuild -- -av"
      take_a_break

      e_start "python-updater -- -av"
      take_a_break
fi

e_start "eclean-dist"
e_ok "All done. Have a cookie."
} # END MAIN ###################################################################



##### print_help ###############################################################
print_help(){
    echo "A script that helps with portage housekeeping work"
    echo -e """
${bold}Usage:${reset}
 ${bold}${cyan}$0 ${yellow}[option]${reset}

Available ${bold}${yellow}options${reset}:
${bold}${yellow}-f, --force-sync ${reset}- run eix-sync even when the last sync was less then $HOURS hours ago.
${bold}${yellow}-h, --help       ${reset}- display this help and exit.
${bold}${yellow}-V, --version    ${reset}- display version number and exit.
${bold}${yellow}-x, --extended   ${reset}- run through the usually unnecessary steps."""
} # end print_help #############################################################

### Strings for color formatting
reset="\e[0m"
bold="\e[01m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
cyan="\e[96m"

e_ok() {
    echo -e "${reset}[${bold}${green} OK ${reset}] $1"
}

e_error() {
    (>&2 echo -e "${reset}[${bold}${red}FAIL${reset}] $1")
}

e_info() {
    echo -e "${reset}[${bold}${cyan}INFO${reset}] $1"
}

e_start() {
    e_info "Starting ${bold}$1${reset}..."
    ($1)
}

take_a_break(){
    echo -e "\nPress Enter to continue"
    read -r
}

main "$@"
