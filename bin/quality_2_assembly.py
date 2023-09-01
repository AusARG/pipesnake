#!/usr/bin/env python
 
"""Provide a command line tool to validate and transform tabular samplesheets."""

import argparse
import os
import logging
from random import sample
import sys
from collections import Counter
from pathlib import Path



logger = logging.getLogger()

def get_seq_info(fasta_file):
    all_seqs = {}
    total_length = 0
    seq_lengths = []
    curr_id = None
    with open(fasta_file, "r") as sample_fasta:
        for line in sample_fasta:
            if line.startswith(">"):
                if curr_id is not None:
                    total_length += len(curr_seq)
                    seq_lengths.append(len(curr_seq))
                    all_seqs[curr_id] = curr_seq
                curr_seq = ""
                curr_id = line.strip()[1:]
            else:
                curr_seq += line.strip()
        all_seqs[curr_id] = curr_seq
    seq_lengths = sorted(seq_lengths)
    
    run_count = 0
    for ix, val in enumerate(seq_lengths):
        run_count += val
        if run_count >= (total_length / 2.0):
            n50 = val
            break
    return all_seqs, seq_lengths, n50


def quality_2_assembly(sample, lineage, sample_fasta_file, prg_fasta_file, outdir):
    
    sample_seqs, sample_seqs_lengths, sample_n50 = get_seq_info(sample_fasta_file)
    stats = {}

    stats['assembled_contig_count'] = len(sample_seqs_lengths)
    stats['assembled_contig_totlength'] = sum(sample_seqs_lengths)
    stats['assembled_contig_n50'] = sample_n50
    
    prg_seqs, prg_seqs_lengths, prg_n50 = get_seq_info(prg_fasta_file)
    
    stats['annotated_contig_count'] = len(prg_seqs_lengths)
    stats['annotated_contig_totlength'] = sum(prg_seqs_lengths)
    stats['annotated_contig_n50'] = prg_n50

    loci = list(prg_seqs.keys())
    stats['annotated_AHE_count'] = len([x for x in loci if "AHE" in x])
    stats['annotated_uce_count'] = len([x for x in loci if "uce" in x])
    stats['annotated_gene_count'] = len([x for x in loci if "gene" in x])

    with open("{}/{}_assemblyquality.csv".format(outdir, sample), 'w') as out_f:
        out_f.write("individual,lineage,metric,value\n")
        for k, v in stats.items():
            out_f.write("{},{},{},{}\n".format(sample, lineage, k, v))
        

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
        "--prg-file",
        metavar="PRG_FILE",
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
        help="The desired log level (default WARNING).",
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
    quality_2_assembly(args.sample, args.lineage, args.sample_fasta, args.prg_file, args.output_dir)



if __name__ == "__main__":
    sys.exit(main())

