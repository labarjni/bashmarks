### Bashmarks is a shell script that allows you to save and jump to commonly used directories. Now supports tab completion.

## Install

1. `git clone https://github.com/huyng/bashmarks.git`
2. `cd bashmarks`
3. `make install`
4. source **~/.local/bin/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file
5. you can now remove the downloaded `bashmarks` folder which is no longer needed

## Shell Commands

### Basic Bookmark Commands
- `s <bookmark_name>` - Saves the current directory as "bookmark_name"
- `g <bookmark_name>` - Goes (cd) to the directory associated with "bookmark_name"
- `p <bookmark_name>` - Prints the directory associated with "bookmark_name"
- `d <bookmark_name>` - Deletes the bookmark
- `lb` - Enhanced list with directory info

### File Operations
- `f <bookmark> <file>` - Create file in bookmarked directory
- `c <bookmark> <files...>` - Copy files to bookmarked directory
- `m <bookmark> <files...>` - Move files to bookmarked directory
- `e <bookmark> <file>` - Edit file in bookmarked directory
- `lf <bookmark>` - List files in bookmarked directory

### Advanced Operations
- `b <bookmark>` - Backup current directory to bookmark
- `r <old_name> <new_name>` - Rename bookmark
- `t <bookmark> [name]` - Create timestamped file/dir in bookmark
- `sync <bookmark>` - Sync current directory to bookmarked directory

## Tab Completion
- `g b[TAB]` - Tab completion available for bookmarks
- `p b[TAB]` - Tab completion available for bookmarks
- `d [TAB]` - Tab completion available for bookmarks

## Example Usage

```bash
$ cd /var/www/
$ s webfolder
$ cd /usr/local/lib/
$ s locallib
$ l
$ g web<tab>
$ g webfolder

# File operations examples
$ f webfolder index.html
$ c webfolder style.css script.js
$ sync webfolder
$ b locallib
## Where Bashmarks are stored
    
All of your directory bookmarks are saved in a file called ".sdirs" in your HOME directory.


## Creators 

* [Huy Nguyen](https://github.com/huyng)
* [Karthick Gururaj](https://github.com/karthick-gururaj)
