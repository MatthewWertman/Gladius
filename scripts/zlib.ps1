[CmdletBinding(DefaultParametersetName="zlib")]
Param(
    [string]$BaseDir="baseiso",
    [parameter(ParameterSetName="Compress")][string]$Compress,
    [parameter(ParameterSetName="Decompress")][string]$Decompress,
    [int]$CompressionLevel=1,
    [switch]$help
)

$ZLIB_PATH = (Join-Path ".\$BaseDir" "\gladius_bec\zlib")

# Python
$PyVersion = (Get-Command python.exe).FileVersionInfo.FileVersion
$Python = (Get-Command python.exe).Path

# Check Python Version
if ( ! ( $PyVersion -ge 3 ) )
{
   Write-Output "Error: Need to require Python 3, Make sure you are using Python 3 or greater."
   Exit 1
}

Function Print-Man
{
    Write-Output(
'NAME
zlib
DESCRIPTION
compress and decompress zlib archives. ONLY FOR USE WITH PS2 COPY OF GLADIUS.

-Compress
    compresses a specified file to a zlib archive. Overrides corresponding archive in gladius_bec\zlib.
    The path of file starts from within extracted bec directory (gladius_bec).
-BaseDir
    point to specified output directory. Default is "baseiso".
-help
    shows this information and exits.
-CompressionLevel
-Decompress
    decompresses a specified zlib archive to the original file. Overrides corresponding file in extracted bec directory.
    The path of file starts from within the extracted bec directory.')
}

Function Print-Usage
{
    Write-Output "Usage: .\zlib.ps1 (-Compress, -Decompress) [-CompressionLevel] [-help] [-Verbose]"
    Write-Output "    where flags surrounded in '[]' are optional."
}

Function Close-Zlib
{
    param (
        [string]$indata,
        [string]$output,
        [int]$level
    )

    & $Python .\tools\zlib-tool.py -l $level -c $indata $output
}
Function Open-Zlib
{
    param (
        [string]$indata,
        [string]$output
    )

    & $Python .\tools\zlib-tool.py -x $indata $output
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

if (Test-Path -Path .\$BaseDir)
{
    if (Test-Path -Path $ZLIB_PATH)
    {
        if ($Compress.Length -gt 0)
        {
            Close-Zlib (Join-Path ".\$BaseDir\gladius_bec\" $Compress) (Join-Path $ZLIB_PATH "\$Compress.zlib") $CompressionLevel
        }
        if ($Decompress.Length -gt 0)
        {
            Open-Zlib (Join-Path $ZLIB_PATH "$Decompress.zlib") (Join-Path ".\$BaseDir" "\gladius_bec\$Decompress")
        }
    }
    else
    {
        Write-Error ("Could not find {0}" -f $ZLIB_PATH)
        Exit 1
    }
}
else
{
    Write-Error ("The output directory {0} does not exist" -f $BaseDir)
    Exit 1
}

Exit 0
