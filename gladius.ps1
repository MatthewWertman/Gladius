<#
.SYNOPSIS

Unpacks and packs Gladius ROMs.

.DESCRIPTION

The gladius.ps1 script unpacks and packs both GameCube and PlayStation 2 Gladius ROMs using JimB's tools.

#>


[CmdletBinding(DefaultParametersetName="gladius")]
Param (
    [parameter(ParameterSetName="gc")][switch]$gc,
    [parameter(ParameterSetName="ps")][switch]$ps,
    [string]$BaseDir="baseiso",
    [string]$Rom="baseiso.iso",
    [string]$IsoName="gladius",
    [switch]$init,
    [switch]$initiso,
    [switch]$initaudio,
    [switch]$echo,
    [switch]$buildaudio,
    [switch]$builddata,
    [switch]$buildiso,
    [switch]$clean,
    [switch]$cleanall,
    [switch]$help
)

# Actions
$ACTIONS = @($init, $initiso, $initaudio, $buildaudio, $builddata, $buildiso, $clean, $cleanall)

# Python
Function Get-Python
{
    $PyLocations = "C:\Python*\", "C:\Python\Python*\", "C:\Python3\Python*\", "C:\Users\$Env:USERNAME\AppData\Local\Programs\Python\Python*\"
    $PythonPath = ""
    foreach ($path in $PyLocations)
    {
        if ( Test-Path $path)
        {
            $PythonPath = Resolve-Path $path
            Break
        }
    }
    return $PythonPath
}

$PyVersion = (Get-Command python.exe).FileVersionInfo.FileVersion
$Python = (Get-Command python.exe).Path

if (!$Python)
{
    $Python = (Get-ChildItem -Path (& Get-Python) -File python.exe).FullName
    $PyVersion = (Get-Command $Python).FileVersionInfo.FileVersion
}

# Check Python Version
if ( !$PyVersion -or ! ( $PyVersion -ge 3 ) )
{
   Write-Output "Error: Need to require Python 3, Make sure you are using Python 3 or greater."
   Exit 1
}

Function Get-7zip
{
    $PathArr = "C:\Program Files\7-Zip\", "C:\Program Files (x86)\7-Zip\"
    $P7ZipPath = ""
    foreach ($path in $PathArr)
    {
        if ( Test-Path -Path $path )
        {
            $P7ZipPath += $path
            Break
        }
    }
    return $P7ZipPath
}
# 7Zip
$P7Zip = (Get-ChildItem -Path (& Get-7zip) -File 7z.exe).FullName

Function Open-Iso
{
    param(
        [string]$iso,
        [string]$outDir,
        [string]$fileList
    )
    if ($ps)
    {
        if ($P7Zip)
        {
            & $P7Zip x -o"$outDir" $iso -aos
        }
        else
        {
            Write-Error -Message "7-Zip doesn't seem to be installed and is required."
            Exit 1
        }
    }
    elseif ($gc)
    {
        & $Python .\tools\ngciso-tool.py -unpack $iso $outDir $fileList
    }
}

Function Open-Bec { & $Python .\tools\bec-tool.py -unpack $args[0] $args[1] $args[2] }

Function Close-Iso { & $Python .\tools\ngciso-tool.py -pack $args[0] $args[1] $args[2] $args[3] }

Function Close-Bec { & $Python .\tools\bec-tool.py -pack $args[0] $args[1] $args[2] }

Function Build-Bec
{
    param(
        [string]$becFile,
        [string]$becPath
    )
    Write-Verbose -Message ("Repacking {0}..." -f $becFile)
    EORR Close-Bec $BaseDir\$becPath\ .\build\$becFile ("{0}\{1}\{1}_FileList.txt" -f $BaseDir, $becPath)
    Write-Verbose -Message ("Moving build\{0} to {1} directory..." -f $becFile, $BaseDir)
    EORR Copy-Item -Path .\build\$becFile -Destination $BaseDir\
}

Function EORR
{
    if ($echo)
    {
        Write-Host $args
    }
    else
    {
        ForEach ($arg in $args)
        {
            $cmd+="$arg "
        }
        Invoke-Expression $cmd
    }
}

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
            Repackages the audio.bec file in the 'build' directory.
    -builddata
            Repackages the gladius.bec file in  the 'build' directory.
    -buildiso
            Repackages the gladius ROM in the project directory.
    -clean
            Removes build directory contents and any previously built isos.
    -cleanall
            Removes BaseDir directory, build directory, and any modified isos. Use with caution.
    -echo
            Outputs the commands to be run without executing them.
    -help
            Shows this information and exits.
    -gc
            Manaully denotes GameCube version.
    -init
            Unpacks iso and gladius.bec to BaseDir directory.
    -initiso
            Unpacks the pointed ROM to BaseDir directory. Does NOT unpack any BEC archives.
    -initaudio
            Unpacks the audio.bec file to BaseDir directory.
    -IsoName
            custom name for iso. defaults to 'gladius'.
    -ps
            Manually denotes PlayStaion version. REQUIRES 7-Zip!
    -Rom
            Points to Gladius ROM. Default is 'baseiso.iso'
    -Verbose
            Shows more detailed information of what the script is doing. Use this
            for debugging.")
}

Function Print-Usage
{
    Write-Output "Usage: gladius.ps1 -gc|-ps [-IsoName] [-BaseDir] [-Rom] (-init | -initiso | -initaudio | -clean | -cleanall | -buildaudio | -builddata | -buildiso) [-help] [-echo],"
    Write-Output "    where flags surrounded in '[]' are optional."
    Write-Output "    and all flags within '()' are actions. There must be at least one action."
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
   EORR Remove-Item .\build\* -Recurse -ErrorAction SilentlyContinue
   EORR Get-Item *.iso -Exclude $Rom | Remove-Item
   Exit 0
}

if ($cleanall)
{
    if ($echo)
    {
        Write-Host "Remove-Item .\$BaseDir -Recurse -ErrorAction SilentlyContinue"
        Write-Host "Remove-Item .\build -Recurse -ErrorAction SilentlyContinue"
        Write-Host "Get-Item *.iso -Exclude $Rom | Remove-Item"
    }
    else
    {
        $readline = Read-Host -Prompt "WARNING: This will remove the $BaseDir directory, any modified isos, and build contents. Do you want to continue? (y/n)"
        switch -Exact ($readline)
        {
            "y" {Break}
            "n" {Exit 1}
            Default { "Please enter (y)es or (n)o."}
        }
        Write-Verbose -Message "Removing $BASEDIR..."
        Remove-Item .\$BaseDir -Recurse -ErrorAction SilentlyContinue
        Write-Verbose -Message "Removing build directory..."
        Remove-Item .\build -Recurse -ErrorAction SilentlyContinue
        Write-Verbose -Message "Removing any modified isos (not $BASEISO)..."
        # Remove relative path
        $Rom = $Rom.TrimStart(".\")
        Get-Item *.iso -Exclude $Rom | Remove-Item

    }
    Exit 0
}

# Require either "-gc" or "-ps"
if (!($gc.IsPresent -or $ps.IsPresent))
{
    Write-Error -Message "Must denote game version."
    Print-Usage
    Exit 1
}

if ($gc)
{
   Write-Verbose -Message "Manually selected GameCube version."
   $DATABEC = "gladius.bec"
   $AUDIOBEC = "audio.bec"
}

if ($ps)
{
    Write-Verbose -Message "Manually selected PlayStation2 version."
    $DATABEC = "DATA.BEC"
    $AUDIOBEC = "AUDIO.BEC"
}

# Require at least one action
$LEAST_ONE_ACTION=$false
foreach ( $action in $ACTIONS )
{
    if ($action)
    {
        $LEAST_ONE_ACTION=$true
        Break
    }
}

if ( ! $LEAST_ONE_ACTION)
{
    Write-Error "Must supply at least one action."
    Print-Usage
    Exit 1
}

if ($init)
{
    EORR New-Item -ItemType Directory -Force -Path .\$BaseDir | Out-Null
    Write-Verbose -Message ("Extracting {0} to '{1}' directory..." -f $Rom, $BaseDir)
    EORR Open-Iso $Rom $BaseDir\ BaseISO_FileList.txt
    Write-Verbose -Message ("Extracting {0} to '{1}\gladius_bec\'..." -f $DATABEC, $BaseDir)
    EORR Open-Bec $BaseDir\$DATABEC $BaseDir\gladius_bec\ gladius_bec_FileList.txt
}

if ($initiso)
{
    Write-Verbose -Message ("Extracting {0} to '{1}' directory..." -f $Rom, $BaseDir)
    EORR Open-Iso $Rom $BaseDir\ BaseISO_FileList.txt
}

if ($initaudio)
{
    if (!$init -and !$initiso -and !(Test-Path -Path $BaseDir))
    {
        EORR New-Item -ItemType Directory -Force -Path .\$BaseDir | Out-Null
        Write-Verbose -Message ("Extracting {0} to '{1}' directory..." -f $Rom, $BaseDir)
        EORR Open-Iso $Rom $BaseDir\ BaseISO_FileList.txt
    }
    Write-Verbose -Message ("Extracting {0} to '{1}\audio_bec\'..." -f $AUDIOBEC, $BaseDir)
    EORR Open-Bec $BaseDir\$AUDIOBEC $BaseDir\audio_bec\ audio_bec_FileList.txt
}

if ($buildaudio)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    EORR Build-Bec $AUDIOBEC audio_bec
}

if ($builddata)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    EORR Build-Bec $DATABEC gladius_bec
}

if ($buildiso)
{
    EORR New-Item -ItemType Directory -Force -Path .\build | Out-Null
    if (!($builddata))
    {
        Build-Bec $DATABEC gladius_bec
    }
    if (!($buildaudio) -and (Test-Path -Path $BaseDir\audio_bec))
    {
        Build-Bec $AUDIOBEC audio_bec
    }
    # Do not build iso if PS2
    if (!($ps))
    {
        Write-Verbose -Message ("Packing {0}.iso..." -f $IsoName)
        EORR Close-Iso $BaseDir $BaseDir\fst.bin $BaseDir\BaseISO_FileList.txt ("{0}.iso" -f $IsoName)
    }
}
