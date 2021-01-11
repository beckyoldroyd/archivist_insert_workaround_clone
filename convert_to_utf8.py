#!/bin/env python3

"""
Python 3
    go through all input files
    - guess the encoding
    - convert to utf-8
"""

from chardet import detect
import pandas as pd
import os


def get_encoding_type(file):
    """
    Get file encoding type
    """
    with open(file, 'rb') as f:
        rawdata = f.read()
    return detect(rawdata)['encoding']


def convert_encoding(filename, newFilename, encoding_from, encoding_to='UTF-8'):
    """
    Convert to utf-8
    """
    with open(filename, 'r', encoding=encoding_from) as fr:
        with open(newFilename, 'w', encoding=encoding_to) as fw:
            for line in fr:
                fw.write(line)


def main():
    input_dir = 'archivist_tables'
    output_dir = 'archivist_tables_utf8'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for srcfile in os.listdir(input_dir):
        from_codec = get_encoding_type(os.path.join(input_dir, srcfile))
        print(srcfile, from_codec)
        convert_encoding(os.path.join(input_dir, srcfile), os.path.join(output_dir, srcfile), from_codec, encoding_to='UTF-8')
 

if __name__ == '__main__':
    main()
