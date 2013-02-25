import sys
from os.path import splitext
import re


def main(inlines, keeps=set([4, 5, 9, 10, 12, 13, 14, 15])):
    outlines = []
    for line in inlines:
        l = line.split(",")
        L = [item for (i, item) in enumerate(l) if i in keeps]

        date, time, type, name, quant, price, net, com = L
        time = time[:2] + ":" + time[2:4]
        type = re.sub("S", "Short", type)
        type = re.sub("B", "Cover", type)
        name = re.sub(" - .*", "", name)
        L2 = [date, time, type, name, quant, price, net, com]

        outlines += [", ".join(L2) + "\n"]
    return outlines


if __name__ == "__main__":
    inname = sys.argv[1]
    outname = splitext(sys.argv[1])[0] + "_trim.csv"

    infile = open(inname, 'r')
    outfile = open(outname, 'w')

    inlines = infile.readlines()[1:]
    outtext = main(inlines)
    for line in outtext:
        outfile.write(line)

    infile.close()
    outfile.close()
