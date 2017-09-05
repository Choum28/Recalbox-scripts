<# 
.SYNOPSIS
    This script is intended to detect duplicate roms based on the name used by the gamelist.xml files of recalbox 

.DESCRIPTION
     This script will check in each subfolder of the roms folder, the file gamelist.xml in order to look for duplicates of the same game based on its name.
     Duplicates are displayed on the screen and stored in a text file.

.PARAMETER source
	Define the source folder for your roms folder
	By default : \\recalbox\share\roms
	
.PARAMETER destination
    Define in which folder the result file will be written
    By default : . (in the same folder as the source).
    
.PARAMETER systeme
    Define which systeme will be check (base of the system folder in recalbox inside the rom folder), by default this script will check all systems.
    By default : all

.EXAMPLE

	.\Doublon.ps1
	
		Launch the script to check all system, the result file will be put in \\recalbox\share\roms
	
 -------------------------- EXEMPLE 2 --------------------------

 .\Doublon.ps1 -source ""\\recalbox\share\roms" -destination "c:\recalbox\résultats\" -systeme "snes"
	
		Launch the script to check duplicate snes rom, the result file will be put in c:\recalbox\résultats

		
 .INPUTS

.OUTPUTS
	This script will generate a text file which all duplicate roms found.
    
.NOTES
    NOM:       Doublon.ps1
    AUTEUR:    Choum
	
    HISTORIQUE VERSION:
    1.1     02.09.2017
            add path of the duplicate roms
            
    1.0     31.08.2017
            Version Initiale

.LINK

 #>

 
 [CmdletBinding()]
 # Définition des arguments du script
  Param(
         [Parameter(Mandatory=$False,HelpMessage="Chemin vers dossier roms de recalbox")]
         [ValidateScript({Test-Path $_ -PathType Container})]
         [string]$Source = "\\recalbox\share\roms",
   
         [Parameter(Mandatory=$False,HelpMessage="Chemin vers dossier ou sera stocké le fichier de résultats")]
         [ValidateScript({Test-Path $_ -PathType Container})]
         [string]$Destination= ".",
         
         [Parameter(Mandatory=$False,HelpMessage="Définis le système à vérifier, valeur all pour l'ensemble des systèmes")]
         [Object]$systeme = "all"
 )
 
$result = "$Destination\doublon.txt"
New-Item $result -force
$a = ""

function Get-Name ($systeme)
{
    $roms = @("")
    $rompath = @("")
    $compteurDoublon = 0
    $compteurA = 0
    "### SEARCH $systeme ###" >> $result 
    try {
        $a = (Select-Xml $source\$systeme\gamelist.xml -XPath "//name" | forEach-object {$_.node.InnerXML})
        $path = (Select-Xml $source\$systeme\gamelist.xml -XPath "//path" | forEach-object {$_.node.InnerXML})
        }
    catch {
        Write-Host "no gamelist $systeme" 
        "$source\$systeme\gamelist.xml not present or not readable" >> $result 
        $a = ""
    }
    foreach ($lines in $a) 
    {
        $lines = $lines -replace "\[([^\[]*)\]",""
        $compteurB = 0
        foreach ($x in $roms)
            {
                if ($lines -eq $x)
                    {
                        $lines >> $result
                        $path[$compteura] >> $result
                        $rompath[$compteurB] >> $result 
                        write-host $lines
                        write-host $path[$compteurA]
                        write-host $rompath[$compteurB]
                        write-host " "
                        $compteurDoublon = $compteurDoublon +1  
                    }
            $compteurB = $compteurB +1
            }
        $rompath += $path[$compteurA]
        $roms += $lines
        $compteurA = $compteurA +1
    }
     



    "### END $systeme ### " >> $result 
    write-host "doublons sur $systeme : $compteurDoublon"
}


if ($systeme -eq "all")
    {
        $c = Get-ChildItem $source | Where-Object {$_.PSIsContainer} | Select-object $_.name
        foreach ($systeme in $c)
            {
                get-name($systeme)
            }
        }
    else {
        Get-Name($systeme)
    }
          