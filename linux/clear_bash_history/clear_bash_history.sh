#!/bin/bash

#
# MIT License
#
# Copyright (c) 2024-2025 Andrea Michael M. Molino
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
    unset -f cleanup
}

case $1 in
    "install")
        if grep -wq "cat /dev/null > ~/.bash_history && history -c && exit" ~/.bash_logout; then
            echo -e "${GREEN_COLOR}This function is already set.${RESET_COLOR}"
            cleanup
            exit 1
        fi

        echo -e "${YELLOW_COLOR}Adding clear bash instruction on bash_logout.${RESET_COLOR}"
        echo -e "cat /dev/null > ~/.bash_history && history -c && exit" >> ~/.bash_logout
        echo -e "${GREEN_COLOR}All done.${RESET_COLOR}"
        cleanup
        exit 0;;

    "uninstall" | "remove")
        echo -e "${YELLOW_COLOR}Removing clear bash instruction on bash_logout.${RESET_COLOR}"
        sed -i 's/cat \/dev\/null > ~\/\.bash_history && history -c && exit//g' ~/.bash_logout
        cleanup
        exit 0;;

    * )
        echo -e "${RED_COLOR}Invalid argument.${RESET_COLOR}"
        echo -e "Use $0 [install | uninstall]"
        cleanup
        exit 1;;
esac