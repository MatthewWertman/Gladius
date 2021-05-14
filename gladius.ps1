[CmdletBinding()]
Param (
    [string]$IsoName="gladius",
    [string]$BaseDir="baseiso",
    [string]$Rom="baseiso.iso",
    [switch]$init,
    [switch]$initaudio,
    [switch]$echo,
    [switch]$buildaudio,
    [switch]$builddata,
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

    -BaseDir
            Points to output directory for unpacking. Default is 'baseiso'.
    -buildaudio
            Repackages the audio,bec file in the 'build' directory.
    -builddata
            Repackages the gladius.bec file in  the 'build' directory.
    -buildiso
            Repackages the gladius ROM in the project directory.
    -clean
            Removes build directory contents and any previously built isos.
    -echo
            Outputs the commands to be run without executing them.
    -help
            Shows this information and exits.
    -init
            Unpacks iso and gladius.bec to BaseDir directory.
    -initaudio
            Unpacks the audio.bec file to BaseDir directory.
    -IsoName
            custom name for iso. defaults to 'gladius'.
    -Rom
            Points to Gladius ROM. Default is 'baseiso.iso'
    -Verbose
            Shows more detailed information of what the script is doing. Use this
            for debugging.")
}

Function Print-Usage
{
    Write-Output "Usage: gladius.ps1 [-IsoName] [-BaseDir] [-Rom] [-init] [-initaudio] [-clean] [-buildaudio] [-builddata] [-buildiso] [-help] [-echo] [-Verbose],"
    Write-Output "    where flags surrounded in '[]' are optional."
}

Function EORR
{
    if ($echo) {
        Write-Host $args
    }
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
   EORR Remove-Item .\build\* -Recurse -Force
   EORR Get-Item *.iso -Exclude $Rom | Remove-Item -Recurse -Force
}

if ($init)
{
    EORR New-Item -ItemType Directory -Force -Path .\$BaseDir | Out-Null
    Write-Verbose -Message ("Extracting {0} to '{1}' directory..." -f $Rom, $BaseDir)
    EORR Open-Iso $Rom $BaseDir\ BaseISO_FileList.txt
    Write-Verbose -Message ("Extracting gladius.bec to '{0}\gladius_bec\'..." -f $BaseDir)
    EORR Open-Bec $BaseDir\gladius.bec $BaseDir\gladius_bec\ gladius_bec_FileList.txt
}

if ($initaudio)
{
    Write-Verbose -Message ("Extracting audio.bec to '{0}\audio_bec\'..." -f $BaseDir)
    EORR Open-Bec $BaseDir\audio.bec $BaseDir\audio_bec\ audio_bec_FileList.txt
}

if ($buildaudio)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    Write-Verbose -Message "Repacking audio.bec..."
    EORR Close-Bec $BaseDir\audio_bec\ .\build\audio.bec $BaseDir\audio_bec\audio_bec_FileList.txt
}

if ($builddata)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    Write-Verbose -Message "Repacking gladius.bec..."
    EORR Close-Bec $BaseDir\gladius_bec\ .\build\gladius.bec $BaseDir\gladius_bec\gladius_bec_FileList.txt
}

if ($buildiso)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    if (!($builddata))
    {
        Write-Verbose -Message "Repacking gladius.bec..."
        EORR Close-Bec $BaseDir\gladius_bec\ .\build\gladius.bec $BaseDir\gladius_bec\gladius_bec_FileList.txt
    }
    if (!($buildaudio) -and (Test-Path -Path $BaseDir\audio_bec))
    {
        Write-Verbose -Message "Repacking audio.bec..."
        EORR Close-Bec $BaseDir\audio_bec\ .\build\audio.bec $BaseDir\audio_bec\audio_bec_FileList.txt
        EORR Copy-Item -Path .\build\audio.bec -Destination $BaseDir\
    }
    Write-Verbose -Message ("Moving build\gladius.bec to {0} directory..." -f $BaseDir)
    EORR Copy-Item -Path .\build\gladius.bec -Destination $BaseDir\
    Write-Verbose -Message ("Packing {0}.iso..." -f $IsoName)
    EORR Close-Iso $BaseDir $BaseDir\fst.bin $BaseDir\BaseISO_FileList.txt ("{0}.iso" -f $IsoName)
}
