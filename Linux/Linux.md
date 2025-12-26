# Linux

A collection of scripts i wrote to simplify my Linux-Journey.

## Kezchron-udev-Rule

This UDev rule is designed to grant non-root users permission to access a specific Keychron 2.4 GHz Dongle. Without this rule, low-level access to the device (required for software like VIA, QMK, or Keychron Launcher) would usually be restricted to the root user.

| *Argument* | *Type* | *Match* |
| ------- | ------------ | ------- |
| KERNEL=="hidraw*" | Match | Matches any device using the HIDRAW (Human Interface Device Raw) driver. This driver allows applications to talk directly to the hardware. |
| SUBSYSTEM=="hidraw" | Match | Ensures the rule specifically targets the hidraw subsystem of the Linux kernel. |
| ATTRS{idVendor}=="3434" | Match | Filters by the Vendor ID. 3434 is the official registered ID for Keychron. |
| ATTRS{idProduct}=="f123" | Match | Filters by the Product ID. f123 (`PLACEHOLDER`) identifies this specific 2.4 GHz Link-KM dongle. |
| MODE="0666" | Assignment | Sets the file permissions of the device node to read and write for everyone (Owner, Group, and Others). |
| TAG+="uaccess" | Assignment | This is the modern systemd way to grant the currently logged-in local user permission to use the device. |
| TAG+="udev-acl" | Assignment | An older method (used for backward compatibility) to apply Access Control Lists, ensuring the desktop user can access the hardware without sudo. |

## Basic Scripted Update

This shell script automates the update process for Debian-based systems by identifying upgradable packages and installing them individually while logging all activities to the system log. It also performs environment checks for root privileges and schedules a notified system reboot if a restart is required to apply the updates.

## Welcome.sh

A simple 'Welcome' script. For optimal use, copy that script into /etc/profile.d/ and make it executable (E.g `chmod +x welcome.sh`)
Note: This script requires figlet to be installed.

# License

All scripts are licensed under MIT - TheGreatMisconception 2023
See LICENSE file for more information.