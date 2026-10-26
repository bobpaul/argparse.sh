#!/bin/bash

source "${0%/*}/../argparse.sh"

ARG_DAEMON='serviced'
ARG_CONFIG="/etc/default/${ARG_DAEMON}.conf"

arg_help       "[Example using subcommands]"
arg_positional "[command]                [command to run: start, stop, or reload]"
# Global arguments
arg_boolean    "[verbose]            []  [Do verbose output]"
arg_boolean    "                     [f] [Some flag]"
arg_boolean    "[version]            [v] [Show version information.]"
arg_boolean    "[init]               [i] [Use arg_init for subparsers.]"
arg_boolean    "[permute-sub]        [s] [Allow sub commands to permute arguments (default)]"
arg_boolean    "[no-permute-sub]     [S] [Don't Allow sub commands to permute arguments]"
arg_optional   "[config]             [c] [alternate configuration file path]"
PERMUTING=0
parse_args

view_global_args(){
  echo "Global Arguments/Options"
  cat << EOT
  ARG_COMMAND:            $ARG_COMMAND
  ARG_VERBOSE:            $ARG_VERBOSE
  ARG_F:                  $ARG_F
  ARG_VERSION:            $ARG_VERSION
  ARG_INIT:               $ARG_INIT
  ARG_PERMUTE_SUB:        $ARG_PERMUTE_SUB
  ARG_NO_PERMUTE_SUB:     $ARG_NO_PERMUTE_SUB
  ARG_CONFIG:             $ARG_CONFIG
  UNPARSED:               ${UNPARSED[@]}
  Script '${__FILE__##*/}' is in '$__DIR__'
EOT
}

start(){
  #[[ -n $ARG_INIT  ]] && arg_init "$@" || source "${0%/*}/../argparse.sh"
  #source "${0%/*}/../argparse.sh"
  arg_init "$@"
  arg_help       "[start] [Start the daemon]"
  arg_positional "[daemon]               [(optional) daemon to start (default: $ARG_DAEMON)]"
  arg_boolean    "[sudo]             [s] [use sudo]"
  arg_boolean    "[wait]             [w] [wait for service to start]"
  arg_boolean    "[verbose]              [Do verbose output]"
  arg_optional   "[machine]          [m] [start on remote machine]"
  echo "ARG_ARR in script: ${ARG_ARR[@]}"
  [[ -n $ARG_PERMUTE_SUB ]] && PERMUTING=1
  parse_args
}

view_start_args(){
  echo "SubCommand Arguments/Options"
  cat << EOT
  ARG_VERBOSE:            $ARG_VERBOSE
  ARG_DAEMON:             $ARG_DAEMON
  ARG_SUDO:               $ARG_VERBOSE
  ARG_WAIT:               $ARG_WAIT
  ARG_MACHINE:            $ARG_MACHINE
EOT
}

reload(){
  [[ -n $ARG_INIT  ]] && arg_init "$@" || source "${0%/*}/../argparse.sh"
  arg_help       "[reload] [Reload the daemon configuration without restarting]"
  arg_positional "[daemon][(optional) daemon to reload (default: $ARG_DAEMON)]"
  arg_boolean    "[verbose]        [v] [Do verbose output]"
  arg_boolean    "[restart]        [r] [Restart anyway]"
  parse_args
}

view_reload_args(){
  echo "SubCommand Arguments/Options"
  cat << EOT
  ARG_RESTART:            $ARG_RESTART
  ARG_VERBOSE:            $ARG_VERBOSE
  UNPARSED:               ${UNPARSED[@]}
EOT
}


# Main script logic

view_global_args

[[ -z $ARG_NO_PERMUTE_SUB || -n $ARG_PERMUTE_SUB ]] && PERMUTING=1
case $ARG_COMMAND in
  reload) 
    reload "${UNPARSED[@]}"
    view_reload_args
    ;;
  start) 
    start "${UNPARSED[@]}"
    view_start_args
    ;;
  stop) 
    # functions are not required for subcommands
    arg_init "${UNPARSED[@]}"
    arg_help       "[stop] [Stop the daemon]"
    arg_positional "[daemon][(optional) daemon to stop (default: $ARG_DAEMON)]"
    arg_boolean    "[verbose]        [V] [Do verbose output]"
    arg_optional   "[message]        [m] [reason for stopping]"
    arg_optional   "[force]          [f] [use SIGKILL]"
    parse_args

    echo "SubCommand Arguments/Options"
    cat << EOT
    ARG_VERBOSE:            $ARG_VERBOSE
    ARG_DAEMON:             $ARG_DAEMON
    ARG_MESSAGE:            $ARG_MESSAGE
    ARG_FORCE:              $ARG_FORCE
    UNPARSED:               ${UNPARSED[@]}
EOT
    ;;
  '')
    print_help
    cprint 1 "\nMissing "; cprint 49 "Command\n\n"
    exit 1
    ;;
  *)
    print_help
    cprint 1 "\nUnrecognized command:"; cprint 49 "$ARG_COMMAND\n"
    exit 1
esac


[[ $ARG_VERBOSE == true ]] && {
  echo -e "\nGlobal Arguments/Options after parsing subcommands"
  echo "Note collisions are possible"
  view_global_args
}
