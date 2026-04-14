@echo off

cd /d "%~dp0"
cd ..
cd ..

::
:: RUN HXPKG INSTALL
::
haxelib --global install hxpkg

:askGlobal
set /p i1= "Would you like to install these libraries globally (might interfere with other mods) [y/n] ? "

::
:: INSTALL EITHER LOCALLY OR GLOBALLY
::
if "%i1%"=="n" (
    haxelib --global run hxpkg install --force
) else if "%i1%"=="y" (
    haxelib --global run hxpkg install --force --global
) else (
    goto askGlobal
)

:: TO-DO! Better video support solution...
:: Or maybe we force everyone to use hxvlc? :fearful:

:askBuild
set /p i3= "All versions set!! Would you like to build the game now [y/n] ? "
if "%i3%"=="y" (
    haxelib run lime test windows
) else if not "%i3%"=="n" (
    goto askBuild
)

pause