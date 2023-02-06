#!/usr/bin/env python3

#Author: Darrian Talamantes 

#Objective: This script will convert
import numpy as np
import argparse

def main():
    args = parse_args()
    cross = args.cross_we_are_on
    progeny_file = importfile(args.input_file_of_progeny)
    save = args.save_file
    path = args.pathway
    final_file = commandMake(progeny_file,path)
    np.save(progeny_file, final_file)




def commandMake(progeny_file,path):
    print("Killer")
    prog_file = numpy.loadtxt(progeny_file)
    extention = "_align_marked_sorted.bam"
    data = np.empty([len(prog_file), 3], dtype=object)
    for x in range(len(prog_file)):
        data[x][1] = path
        data[x][2] = prog_file[x][1]
        data[x][3] = extention
    return data 


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-cross", "--cross-we-are-on", help="two parents seperated by an x")
    parser.add_argument("-f", "--input-file-of-progeny", help="All progeny of one cross in a file")
    parser.add_argument("-s", "--save-file", help="name of file you wish to save to")
    parser.add_argument("-p", "--pathway", help="directory files are in")



    parser.add_argument("--debug", default=False, action="store_true")
    args = parser.parse_args()

    # Handle debug flag
    global debug
    debug = args.debug
    return parser.parse_args()