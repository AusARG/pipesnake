#!/usr/bin/env python

"""Provide a command line tool to validate and transform tabular samplesheets."""


import argparse
import os
import logging
import sys
from collections import Counter
from pathlib import Path
from tokenize import String
logger = logging.getLogger()

def make_alignment(lineage_ls, minsamp, outdir):
    lineage_seqs = {}
    lineage_loci = {}
    curr_id = None
    for lineage_file in lineage_ls:
        lineage = Path(lineage_file).stem
        lineage_seqs[lineage] = {} 
        with open(lineage_file, "r") as lineage_fasta:
            for line in lineage_fasta:
                if line.startswith(">"):
                    if curr_id is not None:
                        lineage_seqs[lineage][curr_id] = curr_seq
                    curr_seq = ""
                    # Ziad get the id from teh firsdt element in teh read header
                    curr_id = line.strip().split()[0][1:]
                    if curr_id not in lineage_loci:
                        lineage_loci[curr_id] = 1
                    else:
                        lineage_loci[curr_id] += 1
                else:
                    curr_seq += line.strip()
            lineage_seqs[lineage][curr_id] = curr_seq
    
    sps = sorted(lineage_seqs.keys())
    sp_cnt = len(sps)
    with open(outdir / "locus_data.csv", "w") as out_file:
        out_file.write('locus,n_lineages,missingness,length,PICs\n')
        for locus in lineage_loci:
            # count how many sps have the locus
            count = sum([1 for sp in sps if locus in lineage_seqs[sp]])
            # only print out the locus if in 4 sp
            if count >= minsamp:
                with open(outdir / "{}.fasta".format(locus), 'w') as locus_out:
                    for sp in sps:
                        if locus in lineage_seqs[sp]:
                            locus_out.write(">{}\n{}\n".format(sp, lineage_seqs[sp][locus]))
            out_file.write("{},{},{}.3f,NA,NA\n".format(locus, count, count / float(sp_cnt)))

def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate and transform a tabular samplesheet.",
        epilog="Example: python check_samplesheet.py samplesheet.csv samplesheet.valid.csv",
    )
    parser.add_argument(
        "--lineage-list",
        metavar="LINEAGE",
        nargs='+',
        help="Lineage for which to make PRG.",
    )
    parser.add_argument(
        "--minsamp",
        metavar="MINSAMP",
        type=int,
        help="Query file path in fasta.",
    )
    parser.add_argument(
        "--output-dir",
        metavar="FILE_OUT",
        type=Path,
        help="output.",
    )
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
    #if not args.file_in.is_file():
    #    logger.error(f"The given input file {args.file_in} was not found!")
    #    sys.exit(2)
    #args.file_out.parent.mkdir(parents=True, exist_ok=True)
    make_alignment(args.lineage_list, args.minsamp, args.output_dir)

if __name__ == "__main__":
    sys.exit(main())
