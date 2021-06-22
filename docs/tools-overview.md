### The Tools
The repo contains the following tools:

#### ngciso-tool.py
This tool unpacks the content from a provided GameCube .iso copy of the game. A output file is created while unpacking to then repack into a new .iso.

To unpack, call the tool with the "-unpack" option:
`python3 tools/ngciso-tool.py -unpack <pathToIso> <outputDir> <fileList>`

To pack, call the tool with the "-pack" option:
`python3 tools/ngciso-tool.py -pack <inputDir> <fstFile> <fstMap> <outputFile>`

#### bec-tool.py
This tool unpacks the content from a bec-archive which is used by Gladius to store game and audio data. While unpacking, a output file is created that is necessary to repack the content into a new bec-archive.
While it's possible to repack with changed files, it is not possible to add files since this requires additional information about all files in the archive.
PS2 and GameCube version use slightly different variants of this archive which I couldn't reproduce without an additional option "--gc" that will produce bec-archives which are compatible with the GameCube version.

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
A general tool to easily compress and decompress files. This tool is only used for the PS2 Version of the game.

To compress, use the "-c" option:
```python3 tools/zlib-tool.py -c <inputFile> <outputFile>```

To decompress, use the "-x" option.
```python3 tools/zlib-tool.py -x <inputFile> <outputFile>```

*NOTE: You can change the level of compression using ```-l <0-9>```.*
