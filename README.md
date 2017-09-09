# Recalbox-scripts
Scripts to find Duplicate rom.

## Powershell version

Doublon script will check for Duplicate roms in your recalbox.

the PS1 script is a powershell only script which support 4 arguments:
    Source : Path to the roms folder (by defualt point to \\recalbox\share\roms)
    Destination : Path to write the result.txt file (which contain all duplicate rom name and file), value by default (.\)
    Systeme : To check for a specific system (base on rom folder) or all, if empty all system are check.
    log : txt if you want a txt file or csv to have a csv log file, other value or missing argument will not create log file

./Doublon.ps1 -Source "c:\recalbox\roms" -destination "c:\recalbox\" -systeme "all" -log csv

<img src="https://i.imgur.com/B2xhGIXl.jpg">

## Python version

The Py Scripts is the python version which is supported by the python version of recalbox.
It has far less functionnalities than the powershell script
Actually this script only support one argument, the system you want to check, if empty all system will be tested.
Duplicate roms are only show on terminal.

python ./doublon.py snes      to only check on snes folder
python ./doublon.py           to check all system
