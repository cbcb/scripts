### Strings for color formatting
reset="\e[0m"
bold="\e[01m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
cyan="\e[96m"

countdown(){
    start=$1
    if [[ -n $2 ]]; then step=$2; else step=1; fi
    for ((i=start; i>0; i=i - step))
    do
        echo -n "$i "
        if [[ $step -lt $i ]]
        then
            sleep $step
        else
            sleep $i
        fi
    done
    echo "0."
}

_run(){
    echo -e " ${bold}${green}*${reset} ${bold}$*${reset}"
    ("$@")
}

e_star(){
    echo -en " ${bold}${1}*${reset} "
    shift
    echo -e "$bold $*"
}

e_ok() {
    echo -e "${reset}[${bold}${green} OK ${reset}] $*${reset}"
}

e_error() {
    (>&2 echo -e "${reset}[${bold}${red}FAIL${reset}] $*${reset}")
}

e_info() {
    echo -e "${reset}[${bold}${cyan}INFO${reset}] $*${reset}"
}

e_start() {
    e_info "Starting ${bold}$*${reset}..."
    ("$@")
}

take_a_break(){
    echo -e "\nPress Enter to continue"
    read -r
}
