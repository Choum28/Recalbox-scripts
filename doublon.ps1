<# 
.SYNOPSIS
    This script is intended to detect duplicate roms based on the name used by the gamelist.xml files of recalbox

.DESCRIPTION
     This script will check in each subfolder of the roms folder, the file gamelist.xml in order to look for duplicates of the same game based on its name.
     Duplicates roms are displayed on terminal and coule be store in log file.

.PARAMETER source
	Define the source folder for your roms folder
	By default : \\recalbox\share\roms
	
.PARAMETER destination
    Define in which folder the log file will be written
    By default : . (in the same folder as the script).
    
.PARAMETER systeme
    Define which systeme will be check (base of the system folder in recalbox inside the rom folder), by default this script will check all systems.
    By default : all

.PARAMETER log
    Define if you want a log file, put csv for a csv file, txt for a txt file, other value will not create log file
    By default : n

.EXAMPLE

	.\Doublon.ps1
	
		Launch the script to check all system, Duplicate roms will be display on terminal
	
 -------------------------- EXEMPLE 2 --------------------------

 .\Doublon.ps1 -source ""\\recalbox\share\roms" -destination "c:\recalbox\result" -systeme "snes" -log csv
	
		Launch the script to check duplicate snes rom, the result file will be put in c:\recalbox\result\Duplicate_roms_recalbox.csv

		
 .INPUTS

.OUTPUTS
	This script will generate a text file which all duplicate roms found.
    
.NOTES
    NOM:       Doublon.ps1
    AUTEUR:    Choum
	
    HISTORIQUE VERSION:
    1.2     09.09.2017
            Fix duplicate name on screen and in log
            better display on screen
            Add Csv log file

    1.1     02.09.2017
            add path of the duplicate roms
            
    1.0     31.08.2017
            Version Initiale

.LINK

 #>
 
 [CmdletBinding()]
 # Define script argument
  Param(
         [Parameter(Mandatory=$False,HelpMessage="Path to the roms folder of recalbox")]
         [ValidateScript({Test-Path $_ -PathType Container})]
         [string]$Source = "\\recalbox\share\roms",
   
         [Parameter(Mandatory=$False,HelpMessage="Path to the folder where you want your log file is argument -log is set to y, by default current folder of powershell temrinal")]
         [ValidateScript({Test-Path $_ -PathType Container})]
         [string]$Destination= ".",
         
         [Parameter(Mandatory=$False,HelpMessage="Define which system you want to check (base on roms folder), all by default")]
         [Object]$systeme = "all",

         [Parameter(Mandatory=$False,HelpMessage="if txt, create a txt log file call duplicate, if csv create a csv file, default value n")]
         [Object]$log = "n"
 )
 
 if ($log -eq "txt")
    {
        $result = "$Destination\Duplicate_roms_recalbox.txt"
        New-Item $result -force  > $null
    }
elseif ($log -eq "csv") 
    {
        $result = "$Destination\Duplicate_roms_recalbox.csv"
        New-Item $result -force  > $null
    }

$Gamelist = ""

function add-Rom
{
 param([string]$Game,[string]$Path,[string]$systeme)
 $d=New-Object PSObject
 $d | Add-Member -Name Nom -MemberType NoteProperty -Value $Game
 $d | Add-Member -Name Chemin -MemberType NoteProperty -Value $Path
 $d | Add-Member -Name Systeme -MemberType NoteProperty -Value $systeme
 return $d
}

function Get-Duplicate ($systeme) 
# Return an array with all duplicate roms, path & system, also return nb of duplicate roms found.
{
    $roms = @()
    $liste = @()
    $rompath = @()
    $compteurDoublon = 0
    $compteurA = 0
    try {
            $Gamelist = (Select-Xml $source\$systeme\gamelist.xml -XPath "//name" | forEach-object {$_.node.InnerXML})
            $path = (Select-Xml $source\$systeme\gamelist.xml -XPath "//path" | forEach-object {$_.node.InnerXML})
            $path = $path.replace('&amp;', '&')
            $Gamelist = $Gamelist.replace('&amp;', '&')
        }
    catch 
        {
            Write-Host "no gamelist $systeme" 
            if ($log -eq "txt"){"$source\$systeme\gamelist.xml not present or not readable" | Out-File -Append $result}
            $Gamelist = ""
            $compteurDoublon = "N/A"
        }
    if ($gamelist -ne "")
    {
        foreach ($lines in $Gamelist) 
        {
            $lines = $lines -replace "\[([^\[]*)\]",""
            $compteurB = 0
            foreach ($x in $roms)  
                {
                    if ($lines -eq $x)
                        {
                            $test = $path[$compteurA].Replace('(',"\(")
                            $test = $test.Replace(')',"\)")
                            if ($liste | Where-Object { $liste.Chemin -match $test} )
                                {}
                            else
                                {
                                    $liste += add-Rom -Game $lines -Path $path[$compteurA] -systeme $systeme
                                }
                            $test = $rompath[$compteurB].Replace('(',"\(")
                            $test = $test.Replace(')',"\)")     
                            if ($liste | Where-Object { $liste.Chemin -match $test })
                                {}
                            else 
                                {
                                    $liste += add-Rom -Game $lines -Path $rompath[$compteurB] -systeme $systeme
                                }                                
                            $compteurDoublon = $compteurDoublon +1
                        }
                $compteurB = $compteurB +1
                }
            $rompath += $path[$compteurA]
            $roms += $lines
            $compteurA = $compteurA +1
        }
        if ($compteurDoublon > 0) # Fix when no gamelist (to not return a 0)
        {$liste = $liste | Sort-Object Nom}
    }
    return ($liste,$compteurDoublon)
}
# main
if ($systeme -eq "all")
    {
        $csv = @()
        $c = Get-ChildItem $source | Where-Object {$_.PSIsContainer} | Select-object $_.name
        foreach ($systeme in $c)
            {
                Write-Host "######### SEARCH $systeme #########"
                if ($log -eq "txt"){"######### SEARCH $systeme #########" | Out-File -Append $result}
                ($liste, $NbDuplicate) = Get-Duplicate($systeme)
                Write-Host "Duplicate roms found in $systeme : $NbDuplicate"
                if ($log -eq "txt"){ "Duplicate roms found in $systeme : $NbDuplicate" | Out-File -Append $result }
                Write-Host ($liste | Format-Table | Out-String)
                write-Host "######### END $systeme #########"
                write-Host ""
                write-Host ""
                if ($log -eq "txt")
                    {
                        $unik = $liste | Group-Object -Property Nom | Select-Object -ExpandProperty name #Recover unique game name
                        foreach($x in $unik)
                        {
                            "$x" | out-file -append $result 
                            $liste | Where-Object {$_.Nom -match "$x"} | Select-Object Chemin | Format-Table -hidetableheaders  | out-file -append $result # DIsplay all path for unique game
                        }
                        "######### END $systeme #########" | Out-File -Append $result
                        "" | Out-File -Append $result
                        "" | Out-File -Append $result
                    }
                elseif ($log -eq "csv")
                    {$csv = $csv + $liste}
            }
        if ($log -eq "csv")
            {$csv | Export-csv $result -noType -Encoding 'utf8'}
    }
else 
    {
        ($liste, $NbDuplicate) = Get-Duplicate($systeme)
        $unik = $liste | Group-Object -Property Nom | Select-Object -ExpandProperty name #Recover unique game name
        Write-Host "######### SEARCH $systeme #########"
        Write-Host "Duplicate roms found in $systeme : $NbDuplicate"
        Write-Host ($liste | Format-Table | Out-String)
        write-Host "######### END $systeme #########"
        if ($log -eq "txt")
            {
                foreach($x in $unik)
                {
                    "$x" | out-file -append $result 
                    $liste | Where-Object {$_.Nom -match "$x"} | Select-Object Chemin | Format-Table -hidetableheaders  | out-file -append $result # DIsplay all path for unique game
                }
            }
        if ($log -eq "csv")
            {
                $liste | Export-csv $result -noType -Encoding 'utf8'
            }
    }
       