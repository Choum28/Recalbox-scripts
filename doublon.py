#!/usr/bin/python
# coding=utf-8
""" This script will search duplicate roms for system put as argument (name folder), if
argument is all, then all system will be check"""
import xml.etree.ElementTree as ET
import re
import os.path
import sys


def get_doublon(systeme):
    """ recover name and path of duplicate games in gamelist.xml for a specific system"""
    rom = []
    rompath = []
    compteur_a = 0
    compteurdoublon = 0
    #print os.path.isfile("/recalbox/share/roms/"+systeme+"/gamelist.xml")
    if os.path.isfile("/recalbox/share/roms/"+systeme+"/gamelist.xml"):
        tree = ET.parse("/recalbox/share/roms/"+systeme+"/gamelist.xml")
        root = tree.getroot()
        print "START SEARCH FOR DUPLICATE "+systeme+" ROMS"

        for line in root.findall('game'):
            compteur_b = 0
            name = line.find('name').text
            name = name.encode('utf-8')
            name = re.sub("\\[([^\\[]*)\\]", '', name)
            path = line.find('path').text
            path = path.encode('utf-8')

            for lines2 in rom:
                if name == lines2:
                    print lines2
                    print path
                    print rompath[compteur_b]
                    compteurdoublon = compteurdoublon +1
                compteur_b = compteur_b +1
            rom.append(name)
            rompath.append(path)
            compteur_a = compteur_a +1
    else:
        print "no gamelist found"
    print "Duplicate roms for "+systeme+" : "+str(compteurdoublon)
    print ""

if len(sys.argv) > 1:
    ARGS = str(sys.argv[1])
else:
    ARGS = "all"
if ARGS == "all":
    print ARGS
    for x in os.listdir("/recalbox/share/roms/"):
        get_doublon(x)
else:
    get_doublon(ARGS)
