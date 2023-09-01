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

def rev_comp(seq):
    seq = seq.upper()
    seq_dict = {'A':'T','T':'A','G':'C','C':'G'}
    return "".join([seq_dict[base] for base in reversed(seq)])


def make_RBG(sample, lineage, matches_file, sample_fasta_file, kept_tags, outdir):
    kept_tags = kept_tags.split(",")
    match = {}
    sample_seqs = {}
    curr_id = None
    with open(sample_fasta_file, "r") as sample_fasta:
        for line in sample_fasta:
            if line.startswith(">"):
                if curr_id is not None:
                    sample_seqs[curr_id] = curr_seq
                curr_seq = ""
                curr_id = line.strip()[1:]
            else:
                curr_seq += line.strip()
        sample_seqs[curr_id] = curr_seq
    
    if True:
        f = open(matches_file, 'r')
        head = f.readline()
        for line in f:
            d = line.strip().split(',')
            if d[5] in kept_tags:
                c = d[1]
                if c in match:
                    # only keep match if evalue diff not too big
                    # and it is the longer contig    
                    eval = match[c]['eval']
                    if eval == 0:
                        eval = 1e-200
                    if float(d[6]) / eval < 1e3:
                        # keep the match that is the longest
                        if len(sample_seqs[d[0]]) > match[c]['len']:
                            match[c] = {'sample': sample, 'con': d[0],
                                        'len': len(sample_seqs[d[0]]),
                                        'eval': float(d[6]), 'orr': d[4]}
                else:
                    match[c] = {'sample': sample, 'con': d[0],
                            'len': len(sample_seqs[d[0]]),
                            'eval': float(d[6]), 'orr': d[4]}
        f.close()

    if not os.path.isdir(outdir):
        os.mkdir(outdir)
    # prints out the PRG
    output_file = open(os.path.join(outdir, lineage + ".fasta"), 'w')
    for c in match:
        s = sample_seqs[match[c]['con']]
        # revcomp the contig so its orientation matches the target orientation
        if match[c]['orr'] == '-':
            s = rev_comp(s)
        output_file.write(">{} {}\n{}\n".format(c, match[c]['con'], s))
    output_file.close()

def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate and transform a tabular samplesheet.",
        epilog="Example: python check_samplesheet.py samplesheet.csv samplesheet.valid.csv",
    )

    parser.add_argument(
        "--lineage",
        metavar="LINEAGE",
        type=str,
        help="Lineage for which to make PRG.",
    )
    parser.add_argument(
        "--match-file",
        metavar="MATCH_FILE",
        type=Path,
        help="Query file path in fasta.",
    )
    parser.add_argument(
        "--sample-fasta",
        metavar="SAMPLE-FASTA",
        type=Path,
        help="Query file path in fasta.",
    )

    parser.add_argument(
        "--kept-tags",
        metavar="KEPT_TAGS",
        type=str,
        help="Tabular input samplesheet in CSV or TSV format.",
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
    parser.add_argument(
        "--sample",
        help=".",
        type=str
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
    make_RBG(args.sample, args.lineage, args.match_file, args.sample_fasta, args.kept_tags, args.output_dir)



if __name__ == "__main__":
    sys.exit(main())

