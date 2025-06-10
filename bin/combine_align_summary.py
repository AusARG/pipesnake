#!/usr/bin/env python

import sys
from pathlib import Path
from csv import DictReader, DictWriter
import argparse


def combine_align_summary(pre_trim_locus_summary, post_trim_locus_summary, output_file):
    combined_summary = {}
    with open(pre_trim_locus_summary) as file:
        pre_trim_reader = DictReader(file)
        for row in pre_trim_reader:
            locus = row['locus'].split('.')[0]
            row.pop('locus')
            combined_summary[locus] = {f'pre_trim_{k}': v for k, v in row.items()}
            combined_summary[locus]['locus'] = locus

    keys = set()
    with open(post_trim_locus_summary) as file:
        post_trim_reader = DictReader(file)
        for row in post_trim_reader:
            locus = row['locus'].split('.')[0]
            row.pop('locus')
            for k, v in row.items():
                combined_summary[locus][f'post_trim_{k}'] = v

            if not keys:
                keys = combined_summary[locus].keys()

    with open(output_file, 'w', newline='') as file:
        print(output_file, file=sys.stderr)
        csv_writer = DictWriter(file, keys)
        csv_writer.writeheader()
        csv_writer.writerows(combined_summary.values())


def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate and transform a tabular samplesheet.",
        epilog="Example: python check_samplesheet.py samplesheet.csv samplesheet.valid.csv",
    )
    parser.add_argument(
        "--pre-trim-locus-summary",
        metavar="FILE_IN",
        type=Path,
        help="Locus summary of alignment before trimming",
    )
    parser.add_argument(
        "--post-trim-locus-summary",
        metavar="FILE_IN",
        type=Path,
        help="Locus summary of alignment after trimming",
    )
    parser.add_argument(
        "--output-file",
        metavar="FILE_OUT",
        type=Path,
        help="Combined locus summary of alignment before and after trimming",
    )
    return parser.parse_args(argv)


def main(argv=None):
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    combine_align_summary(
        args.pre_trim_locus_summary,
        args.post_trim_locus_summary,
        args.output_file
    )


if __name__ == "__main__":
    sys.exit(main())
