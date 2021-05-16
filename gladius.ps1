<#
.SYNOPSIS

Unpacks and packs Gladius ROMs.

.DESCRIPTION

The gladius.ps1 script unpacks and packs both GameCube and PlayStation 2 Gladius ROMs using JimB's tools.

#>


[CmdletBinding()]
Param (
    [string]$IsoName="gladius",
    [string]$BaseDir="baseiso",
    [string]$Rom="baseiso.iso",
    [string]$ZlibCompress,
    [switch]$init,
    [switch]$initaudio,
    [switch]$echo,
    [switch]$buildaudio,
    [switch]$builddata,
    [switch]$buildiso,
    [switch]$clean,
    [switch]$help
)

#PS2
$Global:PS = $false

$Global:DATABEC = "gladius.bec"
$Global:AUDIOBEC = "audio.bec"

# Python
$PyVersion = (Get-Command python.exe).FileVersionInfo.FileVersion
$Python = (Get-Command python.exe).Path

# Check Python Version
if ( ! ( $PyVersion -ge 3 ) )
{
   Write-Output "Error: Need to require Python 3, Make sure you are using Python 3 or greater."
   Exit 1
}

Function Get-7zip
{
    $PathArr = "C:\Program Files\7-Zip\", "C:\Program Files (x86)\7-Zip\"
    $P7ZipPath = @()
    foreach ($path in $PathArr)
    {
        if ( Test-Path -Path $path )
        {
            $P7ZipPath = $P7ZipPath += $path
        }
    }
    return $P7ZipPath
}
# 7Zip
Get-7zip
$P7Zip = (Get-ChildItem -Path $P7ZipPath -File 7z.exe).FullName

Function Check-PS2
{
    if ( ! ($P7Zip -eq $null) )
    {
        if ( & $P7Zip l $Rom | Select-String -Pattern "PLAYSTATION" )
        {
            $Global:PS = $true
            $Global:DATABEC = "DATA.BEC"
            $Global:AUDIOBEC = "AUDIO.BEC"
            Write-Verbose -Message "Found PS2 Version"
        } else {
            Write-Verbose -Message "Found GC Version"
        }
    } else {
        Write-Verbose -Message "Failed automatic check for PS2 version."
        Write-Error -Message "Failed to find 7z.exe"
        $readline = Read-Host -Prompt "Warning: 7-zip is required to unpack the PS2 version. Is $Rom a PS2 Copy? (y/n)"
        switch -Exact ($readline)
        {
            "y" {"Error: 7z.exe was not found. exiting..."; Exit 1}
            "n" {"Manually selected GC Version"; Break}
            default { "please enter (y)es or (n)o" }
        }
    }
}

# Check for PS2 Version
Check-PS2

Function Open-Iso
{
    param(
        [string]$iso,
        [string]$outDir,
        [string]$fileList
    )
    if ( $Global:PS )
    {
        & $P7Zip x -o"$outDir" $iso
    } else {
        & $Python .\tools\ngciso-tool.py -unpack $iso $outDir $fileList
    }
}

Function Open-Bec { & $Python .\tools\bec-tool.py -unpack $args[0] $args[1] $args[2] }

Function Open-Zlib { & $Python .\tools\zlib-tool.py -x $args[0] $args[1] }

Function Close-Iso { & $Python .\tools\ngciso-tool.py -pack $args[0] $args[1] $args[2] $args[3] }

Function Close-Bec { & $Python .\tools\bec-tool.py -pack $args[0] $args[1] $args[2] }

Function Close-Zlib { & $Python .\tools\zlib-tool.py -c $args[0] $args[1] }

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
            for debugging.
    -ZlibCompress
            Compresses a supplied file into a zlib archive. Paths are relative to
            BaseDir\gladius_bec\data. Use only for PS2 Version.")
}

Function Print-Usage
{
    Write-Output "Usage: gladius.ps1 [-IsoName] [-BaseDir] [-Rom] [-init] [-initaudio] [-clean] [-buildaudio] [-builddata] [-buildiso] [-help] [-echo] [-ZlibCompress] [-Verbose],"
    Write-Output "    where flags surrounded in '[]' are optional."
}

Function EORR
{
    if ($echo) {
        Write-Host $args
    } else {
        ForEach ($arg in $args)
        {
            $cmd+="$arg "
        }
        Invoke-Expression $cmd
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

if ($ZlibCompress)
{
    Write-Verbose -Message ("Compressing {0} to zlib..." -f $ZlibCompress)
    Close-Zlib "$BaseDir\gladius_bec\data\$ZlibCompress" "$BaseDir\gladius_bec\zlib\data\$ZlibCompress.zlib"
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
    Write-Verbose -Message ("Extracting {0} to '{1}\gladius_bec\'..." -f $DATABEC, $BaseDir)
    EORR Open-Bec $BaseDir\$DATABEC $BaseDir\gladius_bec\ gladius_bec_FileList.txt
}

if ($initaudio)
{
    Write-Verbose -Message ("Extracting {0} to '{1}\audio_bec\'..." -f $AUDIOBEC, $BaseDir)
    EORR Open-Bec $BaseDir\$AUDIOBEC $BaseDir\audio_bec\ audio_bec_FileList.txt
}

if ($buildaudio)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    Write-Verbose -Message ("Repacking {0}..." -f $AUDIOBEC)
    EORR Close-Bec $BaseDir\audio_bec\ .\build\$AUDIOBEC $BaseDir\audio_bec\audio_bec_FileList.txt
}

if ($builddata)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    Write-Verbose -Message ("Repacking {0}..." -f $DATABEC)
    EORR Close-Bec $BaseDir\gladius_bec\ .\build\$DATABEC $BaseDir\gladius_bec\gladius_bec_FileList.txt
}

if ($buildiso)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    if (!($builddata))
    {
        Write-Verbose -Message ("Repacking {0}..." -f $DATABEC)
        EORR Close-Bec $BaseDir\gladius_bec\ .\build\$DATABEC $BaseDir\gladius_bec\gladius_bec_FileList.txt
    }
    if (!($buildaudio) -and (Test-Path -Path $BaseDir\audio_bec))
    {
        Write-Verbose -Message ("Repacking {0}..." -f $AUDIOBEC)
        EORR Close-Bec $BaseDir\audio_bec\ .\build\$AUDIOBEC $BaseDir\audio_bec\audio_bec_FileList.txt
        Write-Verbose -Message ("Moving build\{0} to {1} directory..." -f $AUDIOBEC, $BaseDir)
        EORR Copy-Item -Path .\build\$AUDIOBEC -Destination $BaseDir\
    }
    Write-Verbose -Message ("Moving build\{0} to {1} directory..." -f $DATABEC, $BaseDir)
    EORR Copy-Item -Path .\build\$DATABEC -Destination $BaseDir\
    # Do not build iso if PS2
    if ( ! ($PS) )
    {
        Write-Verbose -Message ("Packing {0}.iso..." -f $IsoName)
        EORR Close-Iso $BaseDir $BaseDir\fst.bin $BaseDir\BaseISO_FileList.txt ("{0}.iso" -f $IsoName)
    }
}
