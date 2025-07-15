#!/usr/bin/env python3

import sys
from pathlib import Path
from newick import read, dumps
import argparse


def combine_align_summary(input_file, output_file, taxa):
    tree = read(input_file)[0]
    print(tree.ascii_art())
    tree.prune_by_names(taxa, inverse=True)
    tree.remove_redundant_nodes(preserve_lengths=True, keep_leaf_name=True)
    print(tree.ascii_art())
    with output_file.open('w') as out_file:
        out_file.write(dumps([tree]))


def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate a tree containing a subset of taxa of the input tree",
        epilog="Example: python input_tree output_tree \"taxon1,taxon2...\"",
    )
    parser.add_argument(
        "input_file",
        metavar="FILE_IN",
        type=Path,
        help="Input phylogenetic tree",
    )
    parser.add_argument(
        "output_file",
        metavar="FILE_OUT",
        type=Path,
        help="Output phylogenetic tree",
    )
    parser.add_argument(
        "taxa",
        type=str,
        help="Comma seperate list of taxa to be included in the output tree",
    )
    return parser.parse_args(argv)


def main(argv=None):
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    combine_align_summary(args.input_file, args.output_file, args.taxa.split(','))


if __name__ == "__main__":
    sys.exit(main())
