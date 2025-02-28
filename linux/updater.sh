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
    unset OS
    unset PKG_MANAGER
    unset -f update_updater
    unset -f full_update_updater
    unset -f reset_updater
    unset -f check_distro
    unset -f show_help_updater
    unset -f cleanup
}

update_updater() {
    case $OS in
        "Ubuntu" | "Debian GNU/Linux" | "Kali GNU/Linux")
            apt-get update -y
            apt-get upgrade -y
            ;;
        *)
            echo -e "${YELLOW_COLOR}NAME: $OS${RESET_COLOR}" # Debug purpose
            echo -e "${RED_COLOR}Unknown distro or currently unsupported.${RESET_COLOR}"
            cleanup
            exit 1

    esac
}

full_update_updater() {
    case $OS in
        "Ubuntu" | "Debian GNU/Linux" | "Kali GNU/Linux")
            apt-get update -y
            apt-get dist-upgrade -y
            ;;
        *)
            echo -e "${YELLOW_COLOR}NAME: $OS${RESET_COLOR}" # Debug purpose
            echo -e "${RED_COLOR}Unknown distro or currently unsupported.${RESET_COLOR}"
            cleanup
            exit 1

    esac
}

reset_updater() {
    case $OS in
        "Ubuntu" | "Debian GNU/Linux" | "Kali GNU/Linux")
            echo -e "${RED_COLOR}WARNING: some files will be removed from the system and package manager.${RESET_COLOR}"
            read -p "Do you wanna start the process? [y/n]: " yes_no
            if [ "$yes_no" = "y" ]; then
                apt-get autoremove -y
                apt-get clean -y
                apt-get autoclean -y
                apt-get install -f -y # Check for broken packages
            fi
            unset yes_no
            ;;
        *)
            echo -e "${YELLOW_COLOR}NAME: $OS${RESET_COLOR}" # Debug purpose
            echo -e "${RED_COLOR}Unknown distro or currently unsupported.${RESET_COLOR}"
            cleanup
            exit 1

    esac
}

check_distro() {
    if ! [ -f /etc/os-release ]; then
        echo -e "${RED_COLOR}Warning /etc/os-release not found!${RESET_COLOR}"
        cleanup
        exit 1
    fi

    OS=$(grep -E "^NAME" /etc/os-release | cut -d'"' -f 2)
}

show_help_updater() {
    echo -e "Updater - @Nerveustech on Github"
    echo -e "Usage $0 [-u -f -r]\n"
    echo "-h, --help         |       Show this help."
    echo "-u, --update       |       Update & upgrade the system."
    echo "-f, --full-upgrade |       Update & FULL upgrade the system."
    echo "-r, --reset        |       Reset & cleanup."
    echo ""
}

if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW_COLOR}Usage: sudo bash $0${RESET_COLOR}"
    exit 1
fi

case "$1" in
        "-h" | "--help")
            show_help_updater
            exit 0;;

        "-u" | "--update")
            check_distro
            update_updater
            echo -e "${GREEN_COLOR}All done.${RESET_COLOR}"
            cleanup
            exit 0;;

        "-f" | "--full-upgrade")
            check_distro
            full_update_updater
            echo -e "${GREEN_COLOR}All done.${RESET_COLOR}"
            cleanup
            exit 0;;

        "-r" | "--reset")
            check_distro
            reset_updater
            echo -e "${GREEN_COLOR}All done.${RESET_COLOR}"
            cleanup
            exit 0;;

        *)
            echo -e "${RED_COLOR}Invalid option${RESET_COLOR}, check the help with: ${YELLOW_COLOR}bash $0 --help${RESET_COLOR}"
            exit 1;;
esac