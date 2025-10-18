# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.


# USAGE: 
# s bookmarkname - saves the curr dir as bookmarkname
# g bookmarkname - jumps to the that bookmark
# g b[TAB] - tab completion is available
# p bookmarkname - prints the bookmark
# p b[TAB] - tab completion is available
# d bookmarkname - deletes the bookmark
# d [TAB] - tab completion is available
# lb - list all bookmarks
#
# FILE OPERATIONS:
# f bookmarkname filename - create file in bookmarked directory
# c bookmarkname files... - copy files to bookmarked directory  
# m bookmarkname files... - move files to bookmarked directory
# e bookmarkname filename - edit file in bookmarked directory
# lf bookmarkname - list files in bookmarked directory
#
# ADVANCED OPERATIONS:
# b bookmarkname - backup current directory to bookmark
# r oldname newname - rename bookmark
# t bookmarkname [name] - create timestamped file/dir in bookmark
# sync bookmarkname - sync current dir to bookmarked directory

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch "$SDIRS"

RED="0;31m"
GREEN="0;32m"
YELLOW="0;33m"
BLUE="0;34m"
PURPLE="0;35m"
CYAN="0;36m"

function s {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
        echo "export DIR_$1=\"$CURDIR\"" >> $SDIRS
        echo -e "\033[${GREEN}Bookmark '$1' saved: $CURDIR\033[00m"
    fi
}

function g {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        cd "$target"
        echo -e "\033[${GREEN}Jumped to: $target\033[00m"
        ls -la
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
    fi
}

function p {
    check_help $1
    source $SDIRS
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

function d {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        unset "DIR_$1"
        echo -e "\033[${GREEN}Bookmark '$1' deleted\033[00m"
    fi
}

function f {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        shift
        if [ $# -eq 0 ]; then
            echo "Usage: f bookmarkname filename"
            return 1
        fi
        for file in "$@"; do
            touch "$target/$file"
            echo -e "\033[${GREEN}Created file: $target/$file\033[00m"
        done
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function c {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        shift
        if [ $# -eq 0 ]; then
            echo "Usage: c bookmarkname file1 file2 ..."
            return 1
        fi
        cp -r "$@" "$target/"
        echo -e "\033[${GREEN}Copied $# item(s) to: $target\033[00m"
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function m {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        shift
        if [ $# -eq 0 ]; then
            echo "Usage: m bookmarkname file1 file2 ..."
            return 1
        fi
        mv "$@" "$target/"
        echo -e "\033[${GREEN}Moved $# item(s) to: $target\033[00m"
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function b {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_dir="$target/backup_${timestamp}"
        mkdir -p "$backup_dir"
        cp -r ./* "$backup_dir/" 2>/dev/null
        echo -e "\033[${GREEN}Backup created: $backup_dir\033[00m"
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function r {
    check_help $1
    if [ $# -ne 2 ]; then
        echo "Usage: r old_bookmarkname new_bookmarkname"
        return 1
    fi
    source $SDIRS
    old_target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -n "$old_target" ]; then
        s "$2" "$old_target"
        d "$1"
        echo -e "\033[${GREEN}Bookmark renamed from '$1' to '$2'\033[00m"
    else
        echo -e "\033[${RED}Bookmark '$1' not found\033[00m"
    fi
}

function e {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        shift
        if [ $# -eq 0 ]; then
            echo "Usage: e bookmarkname filename"
            return 1
        fi
        file_path="$target/$1"
        if [ -f "$file_path" ]; then
            ${EDITOR:-vim} "$file_path"
        else
            echo -e "\033[${YELLOW}File not found, creating new: $file_path\033[00m"
            ${EDITOR:-vim} "$file_path"
        fi
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function t {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        shift
        timestamp=$(date +%Y%m%d_%H%M%S)
        if [ $# -eq 0 ]; then
            new_dir="$target/temp_${timestamp}"
            mkdir -p "$new_dir"
            echo -e "\033[${GREEN}Created directory: $new_dir\033[00m"
        else
            for name in "$@"; do
                new_file="$target/${name}_${timestamp}"
                touch "$new_file"
                echo -e "\033[${GREEN}Created file: $new_file\033[00m"
            done
        fi
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function sync {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        echo -e "\033[${YELLOW}Syncing to: $target\033[00m"
        echo -e "\033[${CYAN}From: $PWD\033[00m"
        
        if command -v rsync >/dev/null 2>&1; then
            rsync -av --progress ./* "$target/" 
        else
            echo "Using cp -r"
            cp -r ./* "$target/" 2>/dev/null
        fi
        
        echo -e "\033[${GREEN}Sync completed\033[00m"
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function lf {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        echo -e "\033[${CYAN}Files in: $target\033[00m"
        ls -la "$target"
    else
        echo -e "\033[${RED}Bookmark '$1' not found or invalid\033[00m"
    fi
}

function lb {
    check_help $1
    source $SDIRS
    
    echo -e "\033[${PURPLE}Available bookmarks:\033[00m"
    echo -e "\033[${CYAN}====================\033[00m"
    
    declare -A bookmarks
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^export\ DIR_([^=]+)=\"(.*)\"$ ]]; then
            bookmarks[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
        fi
    done < "$SDIRS"
    
    for bookmark in $(printf '%s\n' "${!bookmarks[@]}" | sort); do
        path="${bookmarks[$bookmark]}"
        expanded_path=$(eval echo "$path")
        
        if [ -d "$expanded_path" ]; then
            file_count=$(ls -1 "$expanded_path" 2>/dev/null | wc -l)
            printf "\033[${GREEN}%-20s\033[0m \033[${YELLOW}%-40s\033[0m \033[${BLUE}[%d items]\033[0m\n" \
                   "$bookmark" "$path" "$file_count"
        else
            printf "\033[${GREEN}%-20s\033[0m \033[${YELLOW}%-40s\033[0m \033[${RED}[MISSING]\033[0m\n" "$bookmark" "$path"
        fi
    done
}

function check_help {
    if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
        echo ''
        echo 's <bookmark_name> - Saves the current directory'
        echo 'g <bookmark_name> - Goes to the directory'
        echo 'p <bookmark_name> - Prints the directory'
        echo 'd <bookmark_name> - Deletes the bookmark'
        echo 'lb - Lists all bookmarks'
        echo 'lb-fast - Fast listing'
        echo 'f <bookmark> <file> - Create file'
        echo 'c <bookmark> <files> - Copy files'
        echo 'm <bookmark> <files> - Move files'
        echo 'e <bookmark> <file> - Edit file'
        echo 't <bookmark> [name] - Create timestamped file/dir'
        echo 'b <bookmark> - Backup current directory'
        echo 'r <old> <new> - Rename bookmark'
        echo 'sync <bookmark> - Sync current dir with bookmark'
        echo 'lf <bookmark> - List files in bookmarked directory'
        kill -SIGINT $$
    fi
}

function _l {
    source $SDIRS
    env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "=" 
}

function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="bookmark name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        echo $exit_message
    fi
}

function _comp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_l`' -- $curw))
    return 0
}

function _compzsh {
    reply=($(_l))
}

function _purge_line {
    if [ -s "$1" ]; then
        t=$(mktemp -t bashmarks.XXXXXX) || exit 1
        trap "/bin/rm -f -- '$t'" EXIT
        sed "/$2/d" "$1" > "$t"
        /bin/mv "$t" "$1"
        /bin/rm -f -- "$t"
        trap - EXIT
    fi
}

if [ $ZSH_VERSION ]; then
    compctl -K _compzsh g
    compctl -K _compzsh p
    compctl -K _compzsh d
    compctl -K _compzsh f
    compctl -K _compzsh c
    compctl -K _compzsh m
    compctl -K _compzsh b
    compctl -K _compzsh r
    compctl -K _compzsh e
    compctl -K _compzsh t
    compctl -K _compzsh sync
    compctl -K _compzsh lf
else
    shopt -s progcomp
    complete -F _comp g
    complete -F _comp p
    complete -F _comp d
    complete -F _comp f
    complete -F _comp c
    complete -F _comp m
    complete -F _comp b
    complete -F _comp r
    complete -F _comp e
    complete -F _comp t
    complete -F _comp sync
    complete -F _comp lf
fi
