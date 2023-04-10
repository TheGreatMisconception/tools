#!/bin/bash

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