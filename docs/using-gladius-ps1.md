## Using the gladius.ps1 script

This section talks about how to use the gladius.ps1 script as PowerShell requires additional steps to run this script.

#### The Issue

By default, PowerShell does not let the user run ANY scripts, signed or unsigned. PowerShell has a "ExecutionPolicy" variable that needs to be changed to allow scripts to run. Fortunately, there are multiple workarounds for this.

#### The Workarounds

As stated, there are many ways to resolve this issue.

 - By far, the easiet way around this is to use the "gladius.bat" batch file. This serves as a small wrapper for gladius.ps1 to effectively bypass the current ExecutionPolicy for that instance, passing any suppiled parameters to gladius.ps1. All this means is that instead of running `.\gladius.ps1`, we run `.\gladius.bat` AND we don't have to worry about the current ExecutionPolicy variable that is set.  

 - Of course, you could do this manually in a Command Prompt by running:
    ```
    powershell.exe -ExecutionPolicy Bypass .\gladius.ps1

    OR

    powershell -ep Bypass .\gladius.ps1
    ```

 - If you want to have PowerShell run ANY script, unsigned or signed, permanently:

    Open a powershell as Adminisrator and paste:
    ```
    Set-ExecutionPolicy Unrestricted
    ```
    You will then be ask to type "y" to apply changes.

    *NOTE: This will allow you to run any scripts signed or not and should be warned that this can be a security risk.*

    This can be reverted by setting Set-ExecutionPolicy to "Restricted"
