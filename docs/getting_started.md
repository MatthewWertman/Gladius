## Getting Started


#### Overview
This repo is a fork of JimB's Gladius extraction tools. While there are some flaws with the current tools, this repo aims to only provide a general-use wrapper for said tools. The main goal of this wrapper to make modifying the game easier and to improve the modding workflow for mod developers. Given that these scripts are ran in the terminal, they are not intended for people that are not familiar with working on a command-line environment. If you are someone who is new to Gladius modding, I would recommend [jrbuda's GUI tool](https://github.com/jrbuda/gladius-extractor-gui).

##### Prerequisites

JimB's tools are written in Python, so you will need Python installed on your system. I would recommend getting the latest version from https://www.python.org.

*NOTE: Python is the only REQUIRED dependency.*

*NOTE: If you plan on modifying on PS2 version of Gladius, you will also need [7-ZIP](https://www.7-zip.org) to extract the ISO.*

To make getting the repo a little easier, I would also recommend installing [Git](http://git-scm.com/downloads). This is completely optional however and this guide will document how to download the repo with and without it.

TD;DR

 * (Required)[Python](https://www.python.org) >= 3.6
 * (Only for PS2) [7-Zip](https://www.7-zip.org)
 * (Optional) [Git](http://git-scm.com/downloads)


##### Getting the repo (Git)

To get the repo on your local machine with Git, simply run the following command in a ternimal:
```
git clone https://github.com/MatthewWertman/Gladius.git
```

##### Getting the repo (Zip)
You can get the repo as a Zip archive by clicking the green "Code" button in the top-right corner and then clicking "Download Zip".

After the download is done, extract the archive.

##### Setting up a project

In this section, we will talk about how to get started with a new modding project.

Before proceeding, you will need a Gladius ROM. This should be in the form of a .iso file.

In the previous step, you should have either cloned or extracted the repo somewhere that is easy to work with in, For example on your desktop or in your Documents folder.

This "Gladius" folder is essentially your modding workspace. Everything you need is within this directory. To start, let's look at the overall project structure.

```
Gladius tree view

├── docs
│   ...
├── scripts
│   ├── conf
│   ├── launch
│   ├── launch.ps1
│   ├── zlib
│   └── zlib.ps1
├── tools
    ...
├── gladius
├── gladius.bat
├── gladius.ps1
├── GLSE64.ini
├── Makefile
└── README.md
```

The main files to point out are the various files named "gladius". This includes "gladius", "gladius.bat", and "gladius.ps1". These are all functionally the same main wrapper script just written for different environments.

The file named "gladius" is the wrapper script written for Linux's BASH shell interpreter and "gladius.ps1" is written for Window's PowerShell. "gladius.bat" is a small Command Prompt wrapper for the powershell script. For more detialed coverage of the differences and use cases for each of these files, see [the Scripts Overview page](./scripts-overview.md).

*NOTE: For more information on the other directories and files, see [Project Structure in docs/](./project-structure.md)*

##### Extracting the ISO

After getting a Gladius ROM, place it your "Gladius" workspace.

By default, the gladius wrapper script looks for a .iso file named "baseiso.iso" for extraction. Given this, It's recommended to rename your ISO to "baseiso.iso".

###### Using gladius.ps1 (Windows)

First off, due to PowerShell restricting ANY scripts from being ran by default, the easiest way to use the gladius script on Windows is actually using the "gladius.bat" file. See [Using gladius.ps1](./using-gladius-ps1.md) for more information about others way of resolving this issue and running the gladius.ps1 on Windows.

1. Open a PowerShell or CMD terminal.

    If you have your Gladius workspace open in File Explorer, you can simply Shift+Right Click to open a PowerShell window in that directory. Otherwise open PowerShell from the Start Menu and change directory to your Gladius workspace.

2. Run the following command:

    `.\gladius.bat -gc -init`

    If using the gladius.bat file, then it should open a powershell window and start extracting the ISO and the data archive within it.

    *NOTE: If you have the PS2 version of Gladius, make sure to change "-gc" to "-ps". So the resulting the command is this:
    `.\gladius.bat -ps -init`.*

###### Using gladius (Linux)

This steps are pretty much identical to how to extract on Windows.

1. Open a terminal in the Gladius workspace

2. Run the following command:

    `./gladius -i`

Notice now there is a "baseiso" directory. The ISO and data archive have been extracted into this directory!

#### Finishing Notes

You have now successfully extracted Gladius and it's data files! Feel free to start exploring the files.

If you are a new modder, I really recommend joining the [Gladius discord server](https://discord.gg/dHPSWqtXU8). Everyone there is very knowledgeable and approachable for help.

This is not even close to the extent of what this wrapper can do. Be sure to check out [Gladius](./gladius.md) in the docs for detailed coverage of the many functions of this script.
