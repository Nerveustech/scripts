#!/bin/bash

#
# MIT License
#
# Copyright (c) 2025 Andrea Michael M. Molino
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

RED_COLOR="\033[0;31m"
YELLOW_COLOR="\033[0;33m"
GREEN_COLOR="\033[0;32m"
RESET_COLOR="\033[0m"

cleanup() {
    unset RED_COLOR
    unset YELLOW_COLOR
    unset GREEN_COLOR
    unset RESET_COLOR
    unset OS_NAME
    unset yes_no
    unset -f update_updater
    unset -f full_update_updater
    unset -f reset_updater
    unset -f check_distro
    unset -f show_help_updater
    unset -f cleanup
}

update_updater() {
    case $OS_NAME in
        "Ubuntu" | "Debian GNU/Linux" | "Kali GNU/Linux")
            apt-get update -y
            apt-get upgrade -y
            ;;
        
        "MacOS")
            yes | brew update
            yes | brew upgrade
            ;;

        *)
            echo -e "${RED_COLOR}Unknown distribution, or the operating system is currently unsupported.${RESET_COLOR}"
            echo -e "${YELLOW_COLOR}NAME: $OS_NAME${RESET_COLOR}" # Debug purpose
            cleanup
            exit 1

    esac
}

full_update_updater() {
    case $OS_NAME in
        "Ubuntu" | "Debian GNU/Linux" | "Kali GNU/Linux")
            apt-get update -y
            apt-get dist-upgrade -y
            ;;
        
        "MacOS")
            yes | brew update
            yes | brew upgrade
            sudo softwareupdate --install --all # here we need sudo for make this work
            ;;

        *)
            echo -e "${RED_COLOR}Unknown distribution, or the operating system is currently unsupported.${RESET_COLOR}"
            echo -e "${YELLOW_COLOR}NAME: $OS_NAME${RESET_COLOR}" # Debug purpose
            cleanup
            exit 1

    esac
}

reset_updater() {
    case $OS_NAME in
        "Ubuntu" | "Debian GNU/Linux" | "Kali GNU/Linux")
            apt-get autoremove -y
            apt-get clean -y
            apt-get autoclean -y
            apt-get install -f -y # Check for broken packages
            ;;
        
        "MacOS")
            yes | brew autoremove
            yes | brew cleanup
            yes | brew cleanup -s
            rm -rf "$(brew --cache)"
            ;;

        *)
            echo -e "${RED_COLOR}Unknown distribution, or the operating system is currently unsupported.${RESET_COLOR}"        
            echo -e "${YELLOW_COLOR}NAME: $OS_NAME${RESET_COLOR}" # Debug purpose
            cleanup
            exit 1

    esac
}

check_distro() {
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep -E "^NAME" /etc/os-release | cut -d'"' -f 2)
        return 0
    fi

    if [[ "$OSTYPE" == "darwin" ]]; then
        OS_NAME="MacOS"
        return 0
    fi

    echo -e "${RED_COLOR}Unknown distribution, or the operating system is currently unsupported.${RESET_COLOR}"
    cleanup
    exit 1
}

show_help_updater() {
    echo -e "Updater - @Nerveustech on Github"
    echo -e "Usage $0 [-u -f -r]\n"
    echo "-h, --help          |       Show this help."
    echo "-u, --update        |       Update & upgrade the system."
    echo "-f, --full-upgrade  |       Update & FULL upgrade the system."
    echo "-r, --reset         |       Reset & cleanup."
    echo ""
}

if [ "$EUID" -ne 0 ] && [[ "$OSTYPE" == "darwin" ]]; then # MacOS does not require sudo https://docs.brew.sh/FAQ#why-does-homebrew-say-sudo-is-bad
    echo -e "${YELLOW_COLOR}Usage: bash $0 --help${RESET_COLOR}"
    exit 1
elif [ "$EUID" -ne 0 ] && ! [[ "$OSTYPE" == "darwin" ]]; then
    echo -e "${YELLOW_COLOR}Usage: sudo bash $0 --help${RESET_COLOR}"
    exit 1
fi

case "$1" in
        "-h" | "--help")
            show_help_updater
            exit 0;;

        "-u" | "--update")
            check_distro
            echo -e "${YELLOW_COLOR}Please note that the update may take some time.${RESET_COLOR}"
            update_updater
            echo -e "${GREEN_COLOR}All done.${RESET_COLOR}"
            cleanup
            exit 0;;

        "-f" | "--full-upgrade")
            check_distro
            echo -e "${YELLOW_COLOR}Please note that the update may take some time.${RESET_COLOR}"
            full_update_updater
            echo -e "${GREEN_COLOR}All done.${RESET_COLOR}"
            cleanup
            exit 0;;

        "-r" | "--reset")
            check_distro
            echo -e "${RED_COLOR}WARNING: Certain files will be removed from both the system and the package manager.${RESET_COLOR}"
            read -p "Do you wanna start the process? [y/n]: " yes_no
            if [[ "$yes_no" == "y" ]] || [[ "$yes_no" == "yes" ]]; then
                reset_updater
            fi
            echo -e "${GREEN_COLOR}All done.${RESET_COLOR}"
            cleanup
            exit 0;;

        *)
            echo -e "${RED_COLOR}Invalid option${RESET_COLOR}, check the help with: ${YELLOW_COLOR}sudo bash $0 --help${RESET_COLOR}"
            exit 1;;
esac