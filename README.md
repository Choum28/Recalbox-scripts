# Recalbox-scripts
Various Scripts for recalbox roms management

Doublon script will check for Duplicate roms in your recalbox.

the PS1 script is a powershell only script which support 3 arguments:
    Source : Path to the roms folder (by defualt point to \\recalbox\share\roms)
    Destination : Path to write the result.txt file (which contain all duplicate rom name and file), value by default (same as source)
    Systeme : To check for a specific system (base on rom folder) or all, if empty all system are check.
./Doublon.ps1 -Source "c:\recalbox\roms" -destination "c:\recalbox\" -systeme "all"

The Py Scripts is the python version which is supported by the python version of recalbox.
Actually this script only support one argument, the system you want to check, if empty all system will be tested.
Duplicate roms are only show on terminal screen for the moment.

python ./doublon.py snes      to only check on snes folder
python ./doublon.py           to check all system
