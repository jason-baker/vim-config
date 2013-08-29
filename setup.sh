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
            critError "Failed to make directory: mkdir '$1'" $rv
        fi
    else
        critError "Directory isn't a string."
    fi

    return 0
}

##
# Create a symlink between the two arguments.
# $1    [IN]        Target of the link
# $2    [IN]        File to create link at.
# Will raise critical errors on:
#   1. The item to link to does not exist.
#   2. The item to link from already exists and isn't a symlink to the item to link to.
function createLink() {
    local rv
    if [ -z "$1" ] ; then
        critError "The provided item to link to is empty."
    elif [ ! -e "$1" ] ; then
        critError "The item to link '$1' to doesn't exist."
    fi

    if [ -h "$2" ] ; then
        local canonicalLink=`readlink -ez $2`
        local canonicalTarget=`readlink -fz $1`

        if [ "$canonicalTarget" != "$canonicalLink" ] ; then
            critError "Link exists but points to wrong target: '$canonicalLink' != '$canonicalTarget'"
        fi
    elif [ -e "$2" ] ; then
        critError "non-symbolic link already exists at '$2'"
    else
        # Create the link if nothing exists.
        ln -s "$1" "$2"
        rv=$?
        if [ "0" -ne "$rv" ] ; then
            critError "Failed to create link: ln -s '$1' '$2'" $rv
        fi
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
        local rv

        cd "$VIM_DIR"
        rv=$?
        if [ "0" -ne "$rv" ] ; then
            critError "Failed to change directory to the vim checkout '$VIM_DIR'" $rv
        fi

        git status > /dev/null 2>&1
        rv=$?
        if [ "0" -ne "$?" ] ; then
            critError "Failed to run git status on the user Vim folder '$VIM_DIR'"
        fi
    fi

    return 0
}

# Validate that we have the necessary submodules that should be with this git repository.
# Will raise critical errors on:
#   1. Failure to get git submodules
function ensureSubmodules() {
    local rv

    cd "$VIM_DIR"
    rv=$?
    if [ "0" -ne "$rv" ] ; then
        critError "Failed to change directory to the vim checkout '$VIM_DIR'" $rv
    fi

    # Only initialize if the submodules aren't initialized.
    if [ ! -f "$VIM_DIR\.gitmodules" ] ; then
        echo "Initializing submodules..."
        git submodule init > /dev/null 2>&1
        rv=$?
        if [ "0" -ne "$rv" ] ; then
            critError "Failed to initialize submodules for '$VIM_DIR': git submodule init" $rv
        fi
    fi

    # Get any missing submodules from the project.
    echo "Retrieving new submodules..."
    git submodule update > /dev/null 2>&1
    rv=$?
    if [ "0" -ne "$rv" ] ; then
        critError "Failed to update submodules for '$VIM_DIR': git submodule update" $rv
    fi

    # Update all submodules
    echo "Updating all existing submodules..."
    git submodule foreach git pull origin master > /dev/null 2>&1
    rv=$?
    if [ "0" -ne "$rv" ] ; then
        critError "Failed to update all submodules for '$VIM_DIR': git submodule foreach git pull origin master" $rv
    fi

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
