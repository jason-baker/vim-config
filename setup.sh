#!/bin/bash
#################################################
# Setup a clean checkout of the configuration.  #
#################################################

oldDir=`pwd`
VIM_DIR="$HOME/.vim"
TMP_PATH="$VIM_DIR/tmp"
SWP_PATH="$TMP_PATH/swp"
BAK_PATH="$TMP_PATH/bak"

#################################################
# Helper functions                              #
#################################################

##
# Critical error has occurred stop processing.
# $1    [IN]        The message for the critical error.
# $2    [IN/OPT]    The error code to return -1 if not provided.
function critError() {
    cd "$oldDir"
    echo "$1" >&2
    exit $2 || -1
}

##
# Run a command with all checks being applied.
# Will raise critical errors on:
#   1. Any status code other than 0.
function runSafeCmd() {
    local rv
    "$@" 2> /dev/null
    rv=$?
    if [ 0 -ne $rv ] ; then
        critError "Failed to run command '$@'" $rv
    fi

    return $rv
}

##
# Run a command with all checks being applied but with no stderr or stdout.
# Will raise critical errors on:
#   1. Any status code other than 0.
function runQuietSafeCmd() {
    local rv
    "$@" > /dev/null 2>&1
    rv=$?
    if [ 0 -ne $rv ] ; then
        critError "Failed to run command '$@'" $rv
    fi

    return $rv
}

#Find the operating system we are on because non-linux machines are problematic
OS=`uname -s`

##
# Make a directory at the given path.
# $1    [IN]        The directory
# Will raise critical errors on:
#   1. Something other than a directory already exists at the path.
#   2. Error creating the directory.
function makeDirectory() {
    if [ -n "$1" ] ; then
        if [ -e "$1" ] ; then
            if [ -d "$1" ] ; then
                return 0
            else
                critError "Trying to make directory at '$1' but something else exists there."
            fi
        fi
        runQuietSafeCmd mkdir "$1"
    else
        critError "Directory isn't a string."
    fi

    return 0
}

##
# Read a symlink and echo the canonical path.
# $1    [IN]        The path to the symlink
# Will raise critical errors on:
#   1. The link to follow does not exist.
#   2. There is an error following a symlink
function canonicalReadlink() {
    if [ ! -e "$1" ] ; then
        critError "Target does not exist '$1'"
    elif [ ! -h "$1" ] ; then
        echo `dirname "$1"`/`basename "$1"`
    else
        local link
        local rv
        if [ "$OS" == "Linux" ] ; then
            link=$(runSafeCmd readlink "-z" "$1" 2> /dev/null)
        else
            link=$(runSafeCmd readlink "-n" "$1" 2> /dev/null)
        fi

        canonicalReadlink "$link"
    fi

    return $?
}

##
# Create a symlink between the two arguments.
# $1    [IN]        Target of the link
# $2    [IN]        File to create link at.
# Will raise critical errors on:
#   1. The item to link to does not exist.
#   2. The item to link from already exists and isn't a symlink to the item to link to.
function createLink() {
    if [ -z "$1" ] ; then
        critError "The provided item to link to is empty."
    elif [ ! -e "$1" ] ; then
        critError "The item to link '$1' to doesn't exist."
    fi

    if [ -h "$2" ] ; then
        local canonicalLink=$(canonicalReadlink "$2")
        if [ 0 -ne $? ] ; then
            critError "Failed to canonicalize link path at '$2'"
        fi
        local canonicalTarget=$(canonicalReadlink "$1")
        if [ 0 -ne $? ] ; then
            critError "Failed to get canonical path of '$1'"
        fi

        if [ "$canonicalTarget" != "$canonicalLink" ] ; then
            critError "Link exists but points to wrong target: '$canonicalLink' != '$canonicalTarget'"
        fi
    elif [ -e "$2" ] ; then
        critError "non-symbolic link already exists at '$2'"
    else
        # Create the link if nothing exists.
        runQuietSafeCmd ln -s "$1" "$2"
    fi

    return 0
}

# Validate that we have been checked out to $HOME/.vim/ and have a git directory setup.
# Will raise critical errors on:
#   1. Failure to find ~/.vim
#   2. Failure to perform git check on ~/.vim
function validateCheckout() {
    echo "Validating checkout..."
    if [ ! -d "$VIM_DIR" ] ; then
        critError "The user Vim folder '$VIM_DIR' doesn't exist."
    else
        runQuietSafeCmd cd "$VIM_DIR"
        runQuietSafeCmd git status
    fi

    return 0
}

# Validate that we have the necessary submodules that should be with this git repository.
# Will raise critical errors on:
#   1. Failure to get git submodules
function ensureSubmodules() {
    runQuietSafeCmd cd "$VIM_DIR"

    # Only initialize if the submodules aren't initialized.
    if [ ! -f "$VIM_DIR\.gitmodules" ] ; then
        echo "Initializing submodules..."
        runQuietSafeCmd git submodule init
    fi

    # Get any missing submodules from the project.
    echo "Retrieving new submodules..."
    runQuietSafeCmd git submodule update

    # Update all submodules
    echo "Updating all existing submodules..."
    runQuietSafeCmd git submodule foreach git pull origin master

    return 0
}


validateCheckout
ensureSubmodules

# Make all of the expected directories for the vimrc
echo "Making necessary directories..."
makeDirectory "$TMP_PATH"
makeDirectory "$SWP_PATH"
makeDirectory "$BAK_PATH"

# Create symlinks for .vimrc/.gvimrc
echo "Creating all necessary symlinks..."
createLink "$VIM_DIR/vimrc"     "$HOME/.vimrc"
createLink "$VIM_DIR/gvimrc"    "$HOME/.gvimrc"

# All done
echo "Finished!"
cd "$oldDir"
exit 0
