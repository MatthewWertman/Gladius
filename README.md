# Gladius
tools/ has python scripts for extracting and modifying data for the game Gladius by LucasArts. All tools were upgraded from their original version using python2 to python3.

## Requirements
- [Python](https://www.python.org/downloads/) | >=3.6
- A ROM of Gladius

### Getting the Source Code
Using git (optional):
```
git clone https://github.com/MatthewWertman/Gladius.git
cd Gladius
```
OR

Without git:

  1. Simply download and extract repo to desired location.
  2. Make sure to change directory into the project.

### The Tools
The repo contains the following tools:

#### ngciso-tool.py
This tool unpacks the content from a provided GameCube .iso copy of the game. A output file is created while unpacking to then repack into a new .iso.

To unpack, call the tool with the "-unpack" option:
```python3 tools/ngciso-tool.py -unpack <path-to-iso> <outputDir> <fileList>```

To pack, call the tool with the "-pack" option:
```python3 tools/ngciso-tool.py -pack <inputDir> <fstFile> <fstMap> <outputFile>```

#### bec-tool.py
This tool unpacks the content from a bec-archive which is used by Gladius to store game and audio data. While unpacking a outout file is created that is necessary to repack the content into a new bec-archive.
The tool can also create a bec-archive from a previously unpacked archive. It is possible to repack with changed files, it is not possible to add files since this requires additional information about all files in the archive.
PS2 and GameCube version use slightly different variants of this archive which I couldn't get reproduce without an additional option "--gc" that will produce bec-archives which are compatible with the GameCube version.

To unpack, call the tool with the "-unpack" option:
```python3 tools/bec-tool.py -unpack <inputFile> <outputDir> <fileList>```.
For example, to unpack gladius.bec:

```python3 tools/bec-tool.py -unpack gladius.bec gladius_bec/ gladius_bec_fileList.txt```

To pack files into an archive, call the tool with the "-pack" option:
```python3 tools/bec-tool.py -pack <inputDir> <outputFile> <fileList>```

#### tok-tool.py
The tok-tool is to compress the file "skills.tok" with the dictionary compression that is used by the game. As far as I know this compression is also used for the effect-files (i.e. particle effect settings).
Input is a single text file that will be compressed, output are 3 files with the data for the strings, lines and overall file data.

To compress a file, call the tool with the "-c" option:
```python3 tools/tok-tool.py -c skills.tok skills_strings.bin skills_lines.bin skills.tok.brf```

#### pak-tool.py
Within the game files, there are some .pak files that can be unpacked with this tool. Similarily, it can also pack files back into a .pak file.

To unpack, call the tool with the "-x" option:
```python3 tools/pak-tool.py -x <inputFile> <outputDir> <fileList>```

To pack, call the tool with the "-pack" option:
```python3 tools/pak-tool.py -pack <inputDir> <fileList> <outputFile>```

#### zlib-tool.py
A general tool to easily compress and decompress files.

To compress, use the "-c" option:
```python3 tools/zlib-tool.py -c <inputFile> <outputFile>```

To decompress, use the "-x" option.
```python3 tools/zlib-tool.py -x <inputFile> <outputFile>```

NOTE: You can change the level of compression using ```-l <0-9>```.

### The Scripts
Along with JimB16's tools, there are a few added scripts.
The two scripts named gladius are functionally the same for different shells.
These scripts essentially accomplish two things:

1. Allows you to spend less time in the terminal or Command Prompt, thus faster workflow when modding.

2. Gets rid of some hoop-jumping that is neccessary for the Makefile.

#### Why? There is already a Makefile.
When using make on linux, there is definently an advanage over windows, especially when it comes to the installation process. To use make on windows, you have two options. One is to download MinGW-w64 and add it your path and the other is setting up a linux subsystem in your windows install. While the first option isn't too bad, the second one requires learning a whole new shell (depending on what distro you choose) if you have not used linux before. Another thing is that this isn't a very optiminal use case of a Makefile in the first place. However, if you can setup make, I would highly recommend that you do.

#### Syntax

##### gladius
For the shell script, "gladius", you run it by:
```bash
./gladius
```
If you supply no parameters/flags, it will return the usage of the script. For more information on each flag, run:
```bash
./gladius -h
OR
./gladius --help
```
*NOTE: Each flag has a shorthand and a longhand version. For example, "-n" or "--name".*

##### Command Examples:

To extract your ROM and the gladius.bec file:
```bash
./gladius -i
```
*NOTE: The script will look for a iso named 'baseiso.iso' by default. To specify your ROM (if it is differenly named or in a different location), add "-r" or "--rom" and then the name or path to your ROM.*

*NOTE: This flag will also make a 'baseiso' folder in the current directory by default. To specify a new location for output, add the "-d" or "--dir" flag followed by a path.*

To pack the gladius.bec file back up, you can run:
```bash
./gladius -b
```

OR if you want to go right to the iso:

```bash
./gladius -g
```

*NOTE: This will automatically repack the gladius.bec before packing the iso.*

To remove old isos and build contents, you can run:
```bash
./gladius -c
```
This will remove the contents of the build directory and any isos that is not the specified base iso.

All of these flags can be chained together. For example,

```bash
./gladius -cigv
```

The above command will clean the directory, extract the iso and .bec and then repack it into a iso. the "-v" will verbose each step.

*NOTE: Make sure if you have a flag that takes an agrument (i.e. -n) that it is at the end of the chain followed by the argument.* For example:
```bash
./gladius -cigvn testrom
```
Now the packed iso will be named "testrom.iso"

*NOTE: If you have more than one flag that takes an agrument. you can not chain flags.*

##### gladius.ps1
For the powershell script, "gladius.ps1", you can run it by:
```powershell
.\gladius.ps1
```
### IMPORTANT:
By default, Powershell will not run ANY scripts. You need to set the ExecutionPolicy to "Unrestricted".

There are a few ways of doing this.

- To run just this script:

    Open CMD or your terminal and paste this:
    ```
    powershell.exe -ExecutionPolicy Bypass .\gladius.ps1

    OR

    powershell -ep Bypass .\gladius.ps1
    ```
    This will allow you to run this script or any other script that you point to, although you will have to run it like this every time. You can add whatever flags you want as normal.

- To run all future scripts:

    Open a powershell as Adminisrator and paste:
    ```
    Set-ExecutionPolicy Unrestricted
    ```
    You will then be ask to type "y" to apply changes.

    *NOTE: This will allow you to run any scripts signed or not and should be warned that this can be a security risk. Setting the execution policy to "RemoteSigned" may work and will require remotely downloaded scripts to be signed to run. This is untested however.*

This script features the same functionality as the shell script. However, there are a few differences.
- There are no shorthand options. All flags start with "-" and then the full flag. (i.e. "-help")
- There is no flag chaining.
    Taking the shell script example from above:
    ```bash
    ./gladius -cigvn testrom
    ```
    With gladius.ps1, this would be:
    ```powershell
    .\gladius.ps1 -IsoName testrom -clean -init -buildiso -Verbose
    ```

Notes on parameters/flags
- Flags that are considered switch flags or flags that take no agruments are lowercase.
- Flags that take arguments are PascalCase.
- "-Verbose" is the exception since it is a common parameter.

For more information about the gladius.ps1 script:
```powershell
.\gladius.ps1 -help
```
