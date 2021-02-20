[CmdletBinding()]
Param (
    [string]$IsoName="gladius",
    [string]$BaseDir="baseiso",
    [string]$Rom="baseiso.iso",
    [switch]$init,
    [switch]$buildbec,
    [switch]$buildiso,
    [switch]$clean,
    [switch]$help
)

$PyVersion = (Get-Command python.exe).FileVersionInfo.FileVersion
$Python = (Get-Command python.exe).Path

# Check Python Version
if ( -not ( $PyVersion -ge 3 ) )
{
   Write-Output "Error: Need to require Python 3, Make sure you are using Python 3 or greater."
   Exit 1
}

Function Open-Iso { & $Python .\tools\ngciso-tool.py -unpack $args[0] $args[1] $args[2] }

Function Open-Bec { & $Python .\tools\bec-tool.py -unpack $args[0] $args[1] $args[2] }

Function Close-Iso { & $Python .\tools\ngciso-tool.py -pack $args[0] $args[1] $args[2] $args[3] }

Function Close-Bec { & $Python .\tools\bec-tool.py -pack $args[0] $args[1] $args[2] }

Function Print-Man
{
    Write-Output( 
"NAME
    gladius -- build and extract script for Gladius ROMs.

DESCRIPTION
    Executes prewritten tools to extract and repackage Gladius ROMs.

    -buildbec
            Repackages the gladius.bec file in  the 'build' directory.
    -clean
            Removes build directory contents and any previously built isos.
    -buildiso
            Repackages the gladius ROM in the project directory.
    -help
            shows this information and exits.
    -init
            Unpacks iso and gladius.bec to BaseDir directory.
    -IsoName
            custom name for iso. defaults to 'gladius'.
    -BaseDir
            Points to output directory for unpacking. Default is 'baseiso'.
    -Rom
            Points to Gladius ROM. Default is 'baseiso.iso'
    -Verbose
            shows more detailed information of what the script is doing. Use this
            for debugging.")
}

Function Print-Usage
{
    Write-Output "Usage: gladius.ps1 [-IsoName] [-BaseDir] [-BaseIso] [-Rom] [-init] [-clean] [-buildbec] [-buildiso] [-help] [-Verbose],"
    Write-Output "    where flags surrounded in '[]' are optional."
}

if ( $PSBoundParameters.Count -eq 0 )
{
    Print-Usage
    Exit 1
}

if ($help)
{
    Print-Man
    Exit 1
}

if ($clean)
{
   Write-Verbose -Message "Removing build contents and modified isos..."
   Remove-Item .\build\* -Recurse -Force
   Get-Item *.iso -Exclude $Rom | Remove-Item -Recurse -Force
}

if ($init)
{
    New-Item -ItemType Directory -Force -Path .\$BaseDir | Out-Null
    Write-Verbose -Message ("Extracting {0} to '{1}' directory..." -f $Rom, $BaseDir)
    Open-Iso $Rom $BaseDir\ BaseISO_FileList.txt
    Write-Verbose -Message ("Extracting gladius.bec to '{0}\gladius_bec\'..." -f $BaseDir)
    Open-Bec $BaseDir\gladius.bec $BaseDir\gladius_bec\ gladius_bec_FileList.txt
}

if ($buildbec)
{
    New-Item -ItemType Directory -Force -Path .\build | Out-Null
    Write-Verbose -Message "Repacking gladius.bec..."
    Close-Bec $BaseDir\gladius_bec\ .\build\gladius.bec $BaseDir\gladius_bec\gladius_bec_FileList.txt
}

if ($buildiso)
{
    New-Item -ItemType Directory -Force -Path .\build | Out-Null
    if (!($buildbec))
    {
         Write-Verbose -Message "Repacking gladius.bec..."
         Close-Bec $BaseDir\gladius_bec\ .\build\gladius.bec $BaseDir\gladius_bec\gladius_bec_FileList.txt
    }
    Write-Verbose -Message ("Moving build\gladius.bec to {0} directory..." -f $BaseDir)
    Copy-Item -Path .\build\gladius.bec -Destination $BaseDir\
    Write-Verbose -Message ("Packing {0}.iso..." -f $IsoName)
    Close-Iso $BaseDir $BaseDir\fst.bin $BaseDir\BaseISO_FileList.txt ("{0}.iso" -f $IsoName)
}
