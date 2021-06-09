# https://clalancette.github.io/pycdlib/pycdlib-api.html#PyCdlib
# https://github.com/clalancette/pycdlib

from __future__ import print_function

import argparse
import collections
import os
import sys

import pycdlib


def parse_arguments ():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-pack', action='store', nargs=4, type=str, metavar=("inputDir", "fstMap", "outputFile"), help="pack files into a playstation iso")
    group.add_argument('-unpack', action='store', nargs=3, type=str, metavar=("inputFile", "outputDir", "outFilelist"), help="unpack files from a playstation iso")
    return parser.parse_args()


def unpack_iso (isoFile, outputDir, outFileList):
    iso = pycdlib.PyCdlib()
    iso.open(isoFile)

    # Get path object for root
    root_entry = iso.get_record(udf_path="/")
    dirs = collections.deque([root_entry])
    while dirs:
        dir_record = dirs.popleft()
        recpath = iso.full_path_from_dirrecord(dir_record)
        relname = recpath[len("/"):].upper()
        if relname and relname[0] == "/":
            relname = relname[1:]
        print(relname)
        if dir_record.is_dir():
            if relname != '':
                os.makedirs(os.path.join(outputDir, relname), exist_ok=True)
            child_list = iso.list_children(udf_path=recpath)
            for child in child_list:
                if child is None or child == "." or child == "..":
                    continue
                dirs.append(child)
        else:
            iso.get_file_from_iso(os.path.join(outputDir, relname), udf_path=recpath)
    outFileList = outputDir + outFileList
    if not os.path.exists(os.path.dirname(outFileList)) and os.path.dirname(outFileList):
        os.makedirs(os.path.dirname(outFileList))
    fFileList = open(outFileList, 'w')
    for dirname, _, filelist in iso.walk(udf_path="/"):
        for file in filelist:
            if dirname == "/":
                dirname = ""
            fFileList.write('{}/{}\n'.format(dirname, file))
    fFileList.close()
    iso.close()


# def pack_iso (inputDir, fstMap, outputFile):
#     iso = pycdlib.PyCdlib()
#     iso.new(interchange_level=1, udf="2.60")
#
#     iso.add_directory(udf_path='/MODULES')
#     iso.add_directory(udf_path='/MOVIES')
#
#     with open(fstMap, "r") as fst:
#         for line in fst:
#             relitem = line.split("/")
#             # for i, el in enumerate(relitem):
#             #     if el.endswith("\n"):
#             #         relitem[i] = el.replace("\n", "")
#             relitem = [relitem[x].replace("\n", "") for x in range(0, len(relitem)) if x]
#             if relitem[0] == "MODULES":
#                 iso.add_file(inputDir + "/" + relitem[0] + "/" + relitem[1], udf_path="/MODULES/{}".format(relitem[1]))
#             elif relitem[0] == "MOVIES":
#                 iso.add_file(inputDir + "/" + relitem[0] + "/" + relitem[1], udf_path="/MOVIES/{}".format(relitem[1]))
#             else:
#                 iso.add_file(inputDir + "/" + relitem[0], udf_path="/{}".format(relitem[0]))
#
#
#     iso.write(outputFile)

if __name__ == "__main__":
    args = parse_arguments()
    if args.unpack:
        unpack_iso(args.unpack[0], args.unpack[1], args.unpack[2])
    #pack_iso("baseiso2", "baseiso2/baseiso2BaseIso_File_List.txt", "gladius.iso")
