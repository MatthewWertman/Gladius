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

# TODO

if __name__ == "__main__":
    args = parse_arguments()
