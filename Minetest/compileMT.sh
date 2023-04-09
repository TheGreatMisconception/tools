#!/bin/bash

# Dependencies for Ubuntu/Debian systems as of 5.6.1 and 5.7.0
Dependencies=( g++ make libc6-dev cmake libpng-dev libjpeg-dev libxi-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev libzstd-dev libluajit-5.1-dev )

GITMTsource="https://github.com/minetest/minetest.git"
WGETMTsource="https://github.com/minetest/minetest/archive/master.tar.gz"
WGETMTgame="https://github.com/minetest/minetest_game/archive/master.tar.gz"
GITIrrlichtsource="https://github.com/minetest/irrlicht.git"
WGETIrrlichtsource="https://github.com/minetest/irrlicht/archive/master.tar.gz"

# Default amount of cores/threads to be used to compile minetest
cores="nproc"
# Default cmake options to compile minetest
compileMT="cmake . -DRUN_IN_PLACE=TRUE"


function MThelp() {
    echo "Compile Minetest on Debian based systems"
    echo
    echo "Syntax: $0 [-V|-S|-s|-c|-h]"
    echo "Note: This script needs to be executed as root!"
    echo
    echo "options:"
    echo "-S     Only compile server binary"
    echo "-s     prints the corresponding Github Repository"
    echo "-c     specify the amount of cores to be used for the compilation"
    echo "-h     output this help dialog"
    echo
    echo "Licensed under MIT - TheGreatMisconception 2023"
}


# Parse arguments
while getopts ":SCsc:h" opt; do
    case $opt in 
        S)
            echo "compiling server only"
            compileMT="cmake . -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE -DIRRLICHT_INCLUDE_DIR=minetest*/lib/irrlichtmt/include";;
        s)
            echo "Compile Minetest on Debian based systems"
            echo
            echo "https://github.com/thegreatmisconception/tools" && exit;;
        c)
            cores="$OPTARG";;
        h)
            MThelp
            exit
    esac
done


main() {
    # Check if script is being executed as superuser
    if (( $EUID != 0 )); then
        echo "Please run this script as root"
        echo "Example: sudo $0" && exit
    else
        download
        compile
        clean
    fi
}

# Install a package using the Advanced Package Tool
install_package() {
    echo "installing package: $1"
    # Only redirect stdout to /dev/null - Errors will still be shown
    apt-get install $1 -y -q 1> /dev/null
}

# Correct the permissions of the install directory
clean() {
    cd ../
    chown -R $SUDO_USER:$SUDO_USER minetest*
    echo 
    echo "Done"
}

compile() {
    # install all dependencies
    for Dep in ${Dependencies[@]}; do
        # check if package is already installed
        #
        # "-W/--show"         - prints information about the requested package
        # "-f/ --showformat"  - use alternative format for -W/ --show --> see https://man7.org/linux/man-pages/man1/dpkg-query.1.html
        # "2>"                - redirects the stderr to /dev/null
        # "grep -c"           - print only a count of selected lines per FILE
        # see corresponding man pages for more information
        if [ $(dpkg-query -W -f='${Status}' $Dep 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
            echo "$Dep is already installed, skipping..."
            continue
        fi
        # Assume the package exists in the repos
        install_package $Dep
    done
    # Compile minetest
    $compileMT
    make -j$($cores)
}

download() {
    # Check if wget or git is installed
    if command -v "git" &> /dev/null; then
        echo "Found: git"
        Method="git"
    elif command -v "wget." &> /dev/null; then
        echo "Found: wget"
        Method="wget"
    else
        echo "Not Found: git"
        echo "Not Found: wget"
        echo "Do you want to install git or wget? (git/wget): "
        read Downloadinstall
        Downloadinstall="echo $Downloadinstall | tr '[:upper:]' '[:lower:]'"
        Downloadinstall=$(eval "$Downloadinstall")
        if [ "$Downloadinstall" == "git" ]; then
            install_package "git"
            download
        elif [ "$Downloadinstall" == "wget" ]; then
            install_package "wget"
            download
        else
            echo "Exiting...."
        fi
        exit
    fi

    # Download the source code with wget or git
    case $Method in
        git)
            echo "using git to clone $GITMTsource into `pwd`"
            git clone --depth 1 $GITMTsource &> /dev/null
            cd minetest
            git clone --depth 1 $GITIrrlichtsource lib/irrlichtmt;;
        wget)
            echo "using wget to download $WGETMTsource into `pwd`"
            wget $WGETMTsource && tar xf master.tar.gz
            cd minetest-master/lib
            wget $WGETIrrlichtsource
            cd ../;;
    esac
}

# Main function
main