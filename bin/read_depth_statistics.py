#!/usr/bin/env python3

import sys
from csv import DictWriter
import argparse


def read_depth_statistics(prg_files, samples, output_file):
    data = []
    targets = set()
    for file, sample in zip(prg_files, samples):
        curr = {}
        for line in file:
            if not line.startswith('>'):
                continue

            target = line[1:].split()[0]
            read_depth = float(line.split('_')[-1])

            curr[target] = read_depth
            targets.add(target)

        read_depths = list(curr.values())
        curr['Sample'] = sample
        curr['Low'] = min(read_depths)
        curr['High'] = max(read_depths)
        curr['Mean'] = round(sum(read_depths) / len(read_depths), 2)
        data.append(curr)

    header = ['Sample'] + sorted(targets) + ['Mean', 'Low', 'High']
    writer = DictWriter(output_file, header, restval=0)
    writer.writeheader()
    writer.writerows(data)


def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate read depth statistics for PRGs",
        epilog="Example: python read_depth_statistics.py prg1.fasta prg2.fasta"
    )
    parser.add_argument(
        "samples",
        type=str,
        help="Comma seperated list of samples"
    )
    parser.add_argument(
        "prg_files",
        metavar="FILE_IN",
        type=argparse.FileType('r'),
        nargs='+',
        help="PRG files",
    )
    parser.add_argument(
        "--output_file",
        type=argparse.FileType('w'),
        default="read_depth_statistics.csv",
        help="Output file for read depth statistics",
    )
    return parser.parse_args(argv)


def main(argv=None):
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    read_depth_statistics(
        args.prg_files,
        args.samples.split(','),
        args.output_file
    )


if __name__ == "__main__":
    sys.exit(main())
