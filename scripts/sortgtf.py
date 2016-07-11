#! /usr/bin/env python
from gtfutils import GTFRecord, sortgtf
import sys

def main(args):
    lines = (l.strip('\n').split('\t') for l in args.infile if not l.startswith('#'))
    gtfrecords = [GTFRecord(l) for l in lines]
    if args.sortfile:
        chrom_order = [l.split('\t')[0] for l in args.sortfile]
    else:
        chrom_order = None
    sortgtf(gtfrecords, chrom_order)
    print >>args.outfile, '\n'.join(str(g) for g in gtfrecords)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Build the annotation')
    parser.add_argument('--sortfile', type=argparse.FileType('r'))
    parser.add_argument('infile', nargs='?', type=argparse.FileType('r'), default=sys.stdin)
    parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'), default=sys.stdout)
    main(parser.parse_args())