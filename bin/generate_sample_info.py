#!/usr/bin/env python3
"""Provide a command line tool to create input csv file."""

import argparse
import logging
import sys
from pathlib import Path
import os

logger = logging.getLogger()


def from_start(args):
    """Create a sample info csv file for running from the start of the pipeline"""
    pass


def from_prg(args):
    """Create a sample info csv file for running from PRG files"""
    csv_data = []
    for path in args.prg_dir.rglob("*.fasta"):
        if path.name.startswith(args.prg_prefix):
            path_name = os.path.splitext(path.name)[0].lstrip(args.prg_prefix)
            csv_data.append(f"{path_name},{path.resolve()}\n")

    with open(args.output_file, 'w') as out_file:
        out_file.write("sample_id,prg_file\n")
        out_file.writelines(csv_data)


def from_alignment(args):
    """Create a sample info csv file for running from alignment files"""
    file_names = [str(path.resolve()) + '\n' for path in args.alignment_dir.rglob("*")]
    with open(args.output_file, 'w') as out_file:
        out_file.write("alignment_file\n")
        out_file.writelines(file_names)


def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Create sample info input csv files",
#        epilog="Example: python generate_sample_info.py <output>.csv from-start",
        epilog="Example: python generate_sample_info.py <output>.csv from-prg --prg_directory <dir>",
    )

    parser.add_argument(
        "output_file",
        metavar="FILE_OUT",
        type=Path,
        help="Output sample info sheet in CSV format"
    )

    subparsers = parser.add_subparsers(help='stage help')

    parser_from_start = subparsers.add_parser(
        "from-start",
        help="Create sample info csv file from the starting stage (In development)"
    )
    parser_from_start.set_defaults(func=from_start)

    parser_from_prg = subparsers.add_parser(
        "from-prg",
        help="Create sample info csv file from the PRG stage"
    )
    parser_from_prg.add_argument(
        "--prg_dir",
        type=Path,
        help="Directory containing all PRG fasta files"
    )
    parser_from_prg.add_argument(
        "--prg_prefix",
        type=str,
        default="",
        help="Prefix for files to be removed while creating sample IDs"
    )
    parser_from_prg.set_defaults(func=from_prg)

    parser_from_alignment = subparsers.add_parser(
        "from-alignment",
        help="Create sample info csv file from the aligment stage"
    )
    parser_from_alignment.add_argument(
        "--alignment_dir",
        type=Path,
        help="Directory containing all alignment files"
    )
    parser_from_alignment.set_defaults(func=from_alignment)

    parser.add_argument(
        "-l",
        "--log-level",
        help="The desired log level (default WARNING).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="WARNING",
    )

    return parser.parse_args(argv)


def main(argv=None):
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
