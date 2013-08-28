@ECHO OFF
REM Variable for error handling
SET RC=0
SETLOCAL
REM #################################################
REM Setup a clean checkout of the configuration.    #
REM #################################################

SET OLD_DIR=%CD%
SET HOME=%HOMEDRIVE%%HOMEPATH%
SET VIM_DIR=%HOME%\.vim
SET TMP_PATH=%VIM_DIR%\tmp
SET SWP_PATH=%TMP_PATH%\swp
SET BAK_PATH=%TMP_PATH%\bak

goto start

REM ################################################
REM  Helper functions                              #
REM ################################################

REM  Critical error has occurred stop processing.
REM  %~1    [IN]        The message for the critical error.
REM  %~2    [IN/OPT]    The error code to return -1 IF not provided.
:critError
    echo "%~1" >&2
    if [%~2] EQU [] EXIT /B -1
    EXIT /B %~2
goto:eof

REM  Make a directory at the given path.
REM  %~1    [IN]        The directory
REM  Will raise critical errors on:
REM    1. Something other than a directory already exists at the path.
REM    2. Error creating the directory.
:makeDirectory
    IF EXIST "%~1" (
        IF NOT EXIST "%~1\" (
            CALL:critError "Trying to make directory at '%~1' but something else exists there."
        )
        goto:eof
    )

    CALL mkdir "%~1"
    IF %errorlevel% neq 0 CALL:critError "Failed to make directory: mkdir '%~1'" %errorlevel%
goto:eof

REM  Create a symlink between the two arguments.
REM  %~1    [IN]        Target of the link
REM  %~2    [IN]        File to create link at.
REM  Will raise critical errors on:
REM    1. The item to link to does not exist.
REM    2. The item to link from already exists and isn't a symlink to the item to link to.
:createFileLink
    IF NOT EXIST "%~1" (
        CALL:critError "The item to link '%~1' to doesn't exist."
        goto:eof
    )

    IF EXIST "%~2" (
        SETLOCAL enableextensions enabledelayedexpansion
        SET symlink=
        FOR /F "tokens=6*" %%i in ('dir "%~dp2" 2^> nul ^| find "<SYMLINK>" 2^> nul ^| find "%~nx2" 2^> nul ') do (
            SET symlink=%%i
            if [%%j] NEQ [] (
                SET symlink=!symlink! %%j
            )
        )
        SET symlink=!symlink:~1,-1!
        echo "symlink: !symlink!"
        IF [!symlink!] EQU [] (
            ENDLOCAL
            CALL:critError "non-symbolic link already exists at '%~2'"
            goto:eof
        ) ELSE (
            IF "%~f1" NEQ "!symlink!" (
                IF "%~f1" NEQ "%~dp2!symlink!" (
                    CALL:critError "Link exists but points to wrong target: '!symlink!' != '%~f1'"
                    ENDLOCAL
                    goto:eof
                )
            )
        )
        ENDLOCAL
    ) ELSE (
        mklink "%~2" "%~1" > nul 2>&1
        IF %errorlevel% neq 0 CALL:critError "Failed to create link: mklink '%~2' '%~1'" %errorlevel%
    )
goto:eof

REM  Validate that we have been checked out to %HOME%/.vim/ and have a git directory setup.
REM  Will raise critical errors on:
REM    1. Failure to find ~/.vim
REM    2. Failure to perform git check on ~/.vim
:validateCheckout
    IF NOT EXIST "%VIM_DIR%\" (
        CALL:critError "The user Vim folder '%VIM_DIR%' doesn't exist."
    ) ELSE (
        CALL cd "%VIM_DIR%\"
        IF %errorlevel% neq 0 (
            CALL:critError "Failed to change to directory to '%VIM_DIR%'" %errorlevel%
            goto:eof
        )

        CALL git status > nul 2>&1
        IF %errorlevel% neq 0 CALL:critError "Failed to run git status on the user Vim folder '%VIM_DIR%'"
    )
goto:eof

REM  Validate that we have the necessary submodules that should be with this git repository.
REM  Will raise critical errors on:
REM    1. Failure to get git submodules
:ensureSubmodules
    CALL cd "%VIM_DIR%"
    IF %errorlevel% neq 0 (
        CALL:critError "Failed to change to directory to '%VIM_DIR%'" %errorlevel%
        goto:eof
    )

    CALL git submodule init > nul 2>&1
    IF %errorlevel% neq 0 (
        CALL:critError "Failed to initialize submodules for '%VIM_DIR%': git submodule init" %errorlevel%
        goto:eof
    )

    CALL git submodule update > nul 2>&1
    IF %errorlevel% neq 0 CALL:critError "Failed to update submodules for '%VIM_DIR%': git submodule update" %errorlevel%
goto:eof

:start
REM ################################################
REM  Main Logic                                    #
REM ################################################

REM  Validate the checkout
echo "Validating checkout..."
CALL:validateCheckout
IF %errorlevel% neq 0 goto :exitError

REM  Perform the git submodule operations
echo "Ensuring submodules..."
CALL:ensureSubmodules
IF %errorlevel% neq 0 goto :exitError

REM  Make all of the expected directories for the vimrc
echo "Making necessary directories..."
CALL:makeDirectory "%TMP_PATH%"
IF %errorlevel% neq 0 goto :exitError
CALL:makeDirectory "%SWP_PATH%"
IF %errorlevel% neq 0 goto :exitError
CALL:makeDirectory "%BAK_PATH%"
IF %errorlevel% neq 0 goto :exitError

REM  Create symlinks for .vimrc/.gvimrc
echo "Creating all necessary symlinks..."
CALL:createFileLink "%VIM_DIR%\vimrc"     "%HOME%\_vimrc"
IF %errorlevel% neq 0 goto :exitError
CALL:createFileLink "%VIM_DIR%\gvimrc"    "%HOME%\_gvimrc"
IF %errorlevel% neq 0 goto :exitError

REM  All done
echo "Finished!"
CALL cd "%OLD_DIR%"
ENDLOCAL
EXIT /B 0
goto:eof

:exitError
set err=%errorlevel%
cd "%OLD_DIR%"
ENDLOCAL & set RC=%err%
EXIT /B %RC%
goto:eof
