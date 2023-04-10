#!/bin/bash

function welcome() {
  if [ "$(whoami)" != "root" ]; then
    echo
    figlet -w 500 -f slant "Welcome ${USER}"
    echo
  else
    RED='\033[0;31m'
    NO_COLOR='\033[0m'
    echo "----------------------------------------------------------------"
    echo -e " ${RED}Please try to prevent the login of root. Use \"sudo\" instead. ${NO_COLOR}"
    echo "----------------------------------------------------------------"
  fi
}


# Check if figlet is installed
if command -v "figlet" &> /dev/null; then
  welcome
else
  echo "Can not display Welcome-Message beacuse 'figlet' is not installed. Consider installing the necessary package(s) or removing this script:"
  echo $0
fi