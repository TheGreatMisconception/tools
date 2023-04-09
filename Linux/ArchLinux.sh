#!/bin/bash

# This script works after a preset of hardcoded commands and is therefore very specifc. Use archinstall for a more customizable installation.
# refer to "https://wiki.archlinux.org/title/Archinstall" for more information

KEYBOARD_LAYOUT="de-latin1"
TIMEZONE="Europe/Berlin"




function ArchHelp() {
	echo "Install ArchLinux on EFI compatible devices with a preset configuration"
	echo
	echo "Syntax: $0 [-b|-g|-s|-h]"
	echo "Note: This script needs to be executed as root"
	echo
	echo "Options:"
	echo "-b	basic installation only"
	echo "-g	graphical installation (gnome-desktop)"
	echo "-s	outputs the github repository"
	echo "-h	outputs this help dialog"
	echo
	echo
	echo "Licensed under MIT - TheGreatMisconception 2023"
}

while getopts ":bgsh" opt; do
	case $opt in
		b)
			exit;;
		g)
			exit;;
		s)
			echo "https://github.com/thegreatmisconception/tools" && exit;;
		h)
			ArchHelp
			exit;;

	esac
done

function internet() {
	wget -q --spider http://google.com
	
	if [ $? -eq 0 ]; then
    	echo "Online"
	else
    	echo "Offline"
	fi
}


function main() {
	ArchInstall


}




function ArchInstall(){
	# Set Keyboard-Layout
	loadkeys $KEYBOARD_LAYOUT
	
	# Check for an active internet connection
	local online=$(internet)
	if [ $online = "Online" ]; then
		echo "Found the Internet"
	fi

	# Set the correct time
	timedatectl set-timezone $TIMEZONE

}



main