@ECHO OFF
REM Variable for error handling
SET RC=0
SETLOCAL EnableDelayedExpansion EnableExtensions
REM #################################################
REM Setup a clean checkout of the configuration.    #
REM #################################################

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
    echo %~1 >&2
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

    echo  *Creating directory: %~1
    mkdir "%~1"
    IF !errorlevel! NEQ 0 (
        CALL:critError "Failed to make directory: mkdir '%~1'" !errorlevel!
    )
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
        FOR /F "tokens=6*" %%i in ('dir "%~dp2" 2^> nul ^| find "<SYMLINK>" 2^> nul ^| find "%~nx2" 2^> nul ') do (
            SET symlink=%%i
            if [%%j] NEQ [] (
                SET symlink=!symlink! %%j
            )
        )

        REM If the file isn't a sym link we should probably delete it.
        IF [!symlink!] EQU [] (
            echo  *non-symbolic link already exists at '%~2'
            SET /P resp="Delete file? [y/N]"
            IF [!resp!] NEQ [y] IF [!resp!] NEQ [Y] (
                CALL:critError "link location already present aborting..."
                goto:eof
            )

            del "%~2"
            IF !errorlevel! NEQ 0 (
                CALL:critError "Failed to delete file..."
                goto:eof
            )
        ) else (
            SET symlink=!symlink:~1,-1!
            IF "%~f1" NEQ "!symlink!" (
                IF "%~f1" NEQ "%~dp2!symlink!" (
                    echo Link exists but points to wrong target: '!symlink!' != '%~f1'
                    SET /P resp="Delete link? [y/N]"
                    IF [!resp!] NEQ [y] IF [!resp!] NEQ [Y] (
                        CALL:critError "link location already present aborting..."
                        goto:eof
                    )

                    del "%~2"
                    IF !errorlevel! NEQ 0 (
                        CALL:critError "Failed to delete link..."
                        goto:eof
                    )
                ) ELSE (
                    goto:eof
                )
            ) ELSE (
                goto:eof
            )
        )
    )

    mklink "%~2" "%~1" > nul 2>&1
    IF !errorlevel! NEQ 0 (
        echo "Failed to create link: mklink '%~2' '%~1'"
        SET /P resp="Copy file instead? [y/N]"
        IF [!resp!] NEQ [y] IF [!resp!] NEQ [Y] (
            CALL:critError "failed to create link aborting..."
            goto:eof
        )

        copy "%~1" "%~2" > nul 2>&1
        IF !errorlevel! NEQ 0 (
            CALL:critError "Failed to copy file..."
            goto:eof
        )
    )
goto:eof

REM  Validate that we have been checked out to %HOME%/.vim/ and have a git directory setup.
REM  Will raise critical errors on:
REM    1. Failure to find ~/.vim
REM    2. Failure to perform git check on ~/.vim
:validateCheckout
    echo Validating checkout...
    IF NOT EXIST "%VIM_DIR%\" (
        CALL:critError "The user Vim folder '%VIM_DIR%' doesn't exist."
        goto:eof
    ) ELSE (
        cd "%VIM_DIR%\"
        IF !errorlevel! NEQ 0 (
            CALL:critError "Failed to change to directory to '%VIM_DIR%'" !errorlevel!
            goto:eof
        )

        git status > nul 2>&1
        IF !errorlevel! NEQ 0 (
            CALL:critError "Failed to run git status on the user Vim folder '%VIM_DIR%'" !errorlevel!
            goto:eof
        )
    )
goto:eof

REM  Validate that we have the necessary submodules that should be with this git repository.
REM  Will raise critical errors on:
REM    1. Failure to get git submodules
:ensureSubmodules
    echo Ensuring submodules...
    cd "%VIM_DIR%"
    IF !errorlevel! NEQ 0 (
        CALL:critError "Failed to change to directory to '%VIM_DIR%'" !errorlevel!
        goto:eof
    )

    git submodule init > nul 2>&1
    IF !errorlevel! NEQ 0 (
        CALL:critError "Failed to initialize submodules for '%VIM_DIR%': git submodule init" !errorlevel!
        goto:eof
    )

    git submodule update > nul 2>&1
    IF !errorlevel! NEQ 0 (
        CALL:critError "Failed to update submodules for '%VIM_DIR%': git submodule update" !errorlevel!
        goto:eof
    )
goto:eof

:start
REM ################################################
REM  Main Logic                                    #
REM ################################################

pushd "%VIM_DIR%\"
IF !errorlevel! NEQ 0 (
    echo The user Vim folder '%VIM_DIR%' doesn't exist.
    goto :exitError
)

REM  Validate the checkout
CALL:validateCheckout
IF !errorlevel! NEQ 0 goto :exitError

REM  Perform the git submodule operations
CALL:ensureSubmodules
IF !errorlevel! NEQ 0 goto :exitError

REM  Make all of the expected directories for the vimrc
echo Making necessary directories...
CALL:makeDirectory "%TMP_PATH%"
IF !errorlevel! NEQ 0 goto :exitError
CALL:makeDirectory "%SWP_PATH%"
IF !errorlevel! NEQ 0 goto :exitError
CALL:makeDirectory "%BAK_PATH%"
IF !errorlevel! NEQ 0 goto :exitError

REM  Create symlinks for .vimrc/.gvimrc
echo Creating all necessary symlinks...
CALL:createFileLink "%VIM_DIR%\vimrc"     "%HOME%\_vimrc"
IF !errorlevel! NEQ 0 goto :exitError
CALL:createFileLink "%VIM_DIR%\gvimrc"    "%HOME%\_gvimrc"
IF !errorlevel! NEQ 0 goto :exitError

REM  All done
echo Finished!
popd
ENDLOCAL
EXIT /B 0
goto:eof

:exitError
SET err=!errorlevel!
popd
ENDLOCAL & SET RC=%err%
EXIT /B %RC%
goto:eof

