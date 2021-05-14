[CmdletBinding()]
Param (
    [string]$Rom="gladius.iso",
    [string]$InstallPath="C:\Program Files\Dolphin\Dolphin.exe",
    [string]$Args="-b -e ""$pwd\$Rom""",
    [string]$ShortcutPath="$HOME\Desktop",
    [switch]$override,
    [switch]$help
)

$Dolph_Exe = "C:\Program Files\Dolphin\Dolphin.exe"
$Dolph_GS = "$HOME\Documents\Dolphin Emulator\GameSettings"
$Dolph_Args = "-b -e ""$pwd\$Rom"""
$Dolph_Lnk = "$ShortcutPath\Dolphin.lnk"

Function Print-Man
{
    Write-Output(
'NAME
    launch -- launches dolphin with specified ROM.

DESCRIPTION
    -Rom
            Points to ROM. Default is "gladius.iso".
    -InstallPath
            Points to Dolphin install path. Default is "C:\Program Files\Dolphin\Dolphin.exe".
    -Args
            Supply Dolphin command parameters. See the command line parameters section here: https://wiki.dolphin-emu.org/index.php?title=Help:Contents. Default supplied parameters are "-b -e "$pwd\$Rom"".
    -ShortcutPath
            Point to where the shortcut is created. Default is "$HOME\Desktop".
    -override
            Override the gladius game settings with the GLSE64.ini in the project directory.')
}

Function Set-Shortcut
{
    param (
        [string]$SourceExe,
        [string]$SourceArgs,
        [string]$DestinationPath
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DestinationPath)
    $Shortcut.TargetPath = $SourceExe
    $Shortcut.Arguments = $SourceArgs
    $Shortcut.Save()
}

if ($help)
{
    Print-Man
    Exit 1
}

if ($override -or !(Test-Path -Path $Dolph_GS\GLSE64.ini))
{
    Copy-Item -Path $pwd\GLSE64.ini -Destination $Dolph_GS
}
Set-Shortcut $Dolph_Exe $Dolph_Args $Dolph_Lnk
Invoke-Item $Dolph_Lnk
