# Copyright (C) 2023 TheGreatMisconception
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
##########################################################
#!/bin/bash

# Update Script for Debian based systems

shopt -s expand_aliases
alias logger="logger -t scripted-update"


logger "running scripted system update"

get-updates() {
	local $Packages
	# update package-list
	`apt-get update > /dev/null 2> /dev/null`
	# get names of upgradable packages
	Packages=$(apt list --upgradable 2> /dev/null | cut -d/ -f1 -s)
	logger "${#Packages} need to be upgraded"
	echo $Packages

}

install-updates() {
  # Loop through every upgradable package and update them one by one
	for pkg in $(get-updates); do
		logger "updating $pkg now"
		apt-get install -y $pkg 2>&1 | logger
		if [ $? -eq 0 ]; then
			logger "$pkg install: successful"
		else
			logger "$pkg install: failed"
		fi
	done
}

main() {
	# Check if script is executed as root
	if [ $EUID != 0 ]; then
		logger "script runs in unprivileged mode"
		exit 1
	fi
	# Check for debian-system
	source /etc/os-release
	if [[ $ID != "debian" && $ID != "Debian" ]]; then
		logger "script is only compatible with debian"
		exit 1
	fi

	install-updates
	
  #  reboot the system in 5 min if a reboot is required
	if [ -f /var/run/reboot-required ]; then
		logger 'reboot required'
		wall "System is going down for a reboot in 5 min. To ensure that no data gets lost, save your work and disconnect."
		sleep 5m
		wall "System is going down for a reboot now."
		logger "rebooting to apply updates and patches"
		systemctl reboot
	else
		logger "No reboot required"
	fi

}


main
