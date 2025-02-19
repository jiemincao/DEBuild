#!/bin/bash

# DEBuild means "Develop Environment Build"
# I created it for automatically build up my linux develop enviroment.

ERROR (){
    printf "\e[37;41m"
        echo -n "ERROR!" 
    printf "\e[0m"
}

install_yn () {
    read answer
    case $answer in
        [Yy] | [Yy][Ee][Ss] )
            echo "Start install... "
            ;;
        [Nn] | [Nn][Oo] )
            echo "End !"
            exit -1
            ;;
        * )
            ERROR
            echo    " Sorry, answer not recognized"
            echo -n "Please answer again... [Y/n]: "
            install_yn
            ;;
    esac
}

platform_select () {
    case $selection in
        1 )
            PKG_MANAGER=apt-get
            echo "PKG_MANAGER=apt-get" > src/settings.conf
            ;;
        2 )
            PKG_MANAGER=yum
            echo "PKG_MANAGER=yum" >> src/settings.conf
            ;;
        * )
            ERROR
            echo -n " 1 or 2 only, please select again [1/2]: "
            input_pselect
            ;;
    esac
}

input_pselect () {
    read selection
    platform_select
}

platform () {
    echo    "Which Linux platform you are using now?    "
    echo    "   1. Debian-based (Debian, Ubuntu, ...etc)"
    echo    "   2. Fedora-based (Fedora, CentOS, ...etc)"
    echo -n "Please select the option as above [1/2]: "
    input_pselect
}


# DEBuild's tool packages & superuser privileges error detect
printf "\e[31m"
if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
elif [ ! -f config ]; then
    ERROR
    echo ' "config" setting file lost !!'
    exit 1
fi
printf "\e[0m"

# Show logo and DEBuild version
printf "\e[32m"
    cat src/logo
printf "\e[0m"

# Ask user if start install following packages or not
# and also do "config" error detect.
echo    "Do you want to install following packages?   "
    source src/pkg_tables.sh
echo -n "Answer [Y/n]: "

install_yn

# Choose the linux platform 
echo "Detect platform Name..."

if [ -f /etc/\*-release ]; then
    echo "Platform detect FAIL!!!"
    platform
else
    # String processing
    platform_value=`cat /etc/*-release | grep 'ID_LIKE=' | cut -d"=" -f 2`
    ## echo $platform_value
    case $platform_value in
        debian )
            printf "\e[37;42m"
                echo -n "PASS" 
            printf "\e[0m"
            echo " Oh~ you are Debian-based user huh.."
            selection=1
            platform_select
            ;;
        Fedora )
            printf "\e[37;42m"
                echo -n "PASS" 
            printf "\e[0m"
            echo " Oh~ you are Fedora-based user huh.."
            selection=2
            platform_select
            ;;
        * )
            echo "Platform detect FAIL!!!"
            platform
            ;;
    esac
fi

# Include several package settings
source src/pkg_settings.sh

# Install "make" command
if [ $selection = "1" ]; then
    $PKG_MANAGER update
    $PKG_MANAGER install -y make
else
    echo "Fedora-based not available yet.... Please wait for next version update!!"
    exit -1
fi

# Start install environment
pushd src/ || exit -1
    make -f install.mk
popd