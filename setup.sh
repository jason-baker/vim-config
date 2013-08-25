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
    cd $oldDir
    echo "$1" >&2
    exit $2 || -1
}

##
# Make a directory at the given path.
# $1    [IN]        The directory
# Will raise critical errors on:
#   1. Something other than a directory already exists at the path.
#   2. Error creating the directory.
function makeDirectory() {
    local rv
    if [ -n "$1" ] ; then
        if [ -e "$1" ] ; then
            if [ -d "$1" ] ; then
                return 0
            else
                critError "Trying to make directory at '$1' but something else exists there."
            fi
        fi
        mkdir "$1"
        rv=$?
        if [ "0" -ne "$rv" ] ; then
            critError "Failed to make directory" $rv
        fi
    else
        critError "Directory isn't a string."
    fi

    return 0
}

##
# Create a symlink between the two arguments.
# $1    [IN]        Target of the link
# $2    [IN]        File to link.
# Will raise critical errors on:
#   1. The item to link to does not exist.
#   2. The item to link from already exists and isn't a symlink to the item to link to.
function createLink() {
    if [ -z $1 || ! -e $1 ] ; then
        critError "The item to link '$1' to doesn't exist."
    fi

    if [ -e $2 ] ; then
        if [ -h $2 ] ; then
        fi
    fi
}

# Validate that we have been checked out to $HOME/.vim/ and have a git directory setup.
# Will raise critical errors on:
#   1. Failure to find ~/.vim
#   2. Failure to perform git check on ~/.vim
function validateCheckout() {
    if [ ! -d $VIM_DIR ] ; then
        critError "The user Vim folder '$VIM_DIR' doesn't exist."
    else
        cd $VIM_DIR
        local rv
        git status > /dev/null 2>&1
        rv=$?
        if [ "0" -ne "$?" ] ; then
            critError "Failed to get status on the user Vim folder '$VIM_DIR'"
        fi
    fi
}

# Validate the checkout
echo "Validating checkout..."
validateCheckout

# Perform the git submodule operations
echo "Initializing submodules..."
git submodule init
if [ "0" -ne "$?" ] ; then
    critError "Failed to get status on the user Vim folder '$VIM_DIR'"
fi

echo "Updating submodules..."
git submodule update
if [ "0" -ne "$?" ] ; then
    critError "Failed to get status on the user Vim folder '$VIM_DIR'"
fi

# Make all of the expected directories for the vimrc
echo "Making necessary directories..."
makeDirectory $TMP_PATH
makeDirectory $SWP_PATH
makeDirectory $BAK_PATH

# Create symlinks for .vimrc/.gvimrc
echo "Create the symlinks"

cd $oldDir
