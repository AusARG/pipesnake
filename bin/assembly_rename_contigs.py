#!/usr/bin/env python3

import sys
import re


def process_fasta(input_path, sample_id, assembly_header):
    output_path = "{}_assembly_processed.fasta".format(sample_id)
    contig_cntr = 1

    with open(input_path, "r") as assembly_input, open(output_path, "w") as assembly_processed:
        for line in assembly_input:
            if not line.startswith(">"):
                assembly_processed.write(line)
                continue

            match = re.search(r"_([\d\.]+)$", line.strip())
            if match:
                cov = round(float(match.group(1)), 2)
            else:
                cov = 0.00
            new_header = ">{}_{}{}_{:.2f}\n".format(sample_id, assembly_header, contig_cntr, cov)
            line = new_header
            contig_cntr += 1
            assembly_processed.write(line)

    print("Processed file written to: {}".format(output_path))


if __name__ == "__main__":
    # if len(sys.argv) != 4:
    #     print("Usage: python process_fasta.py <input_fasta> <sample_id> <assembly_header>")
    #     sys.exit(1)

    input_fasta = sys.argv[1]
    sample_id = sys.argv[2]
    assembly_header = sys.argv[3]

    process_fasta(input_fasta, sample_id, assembly_header)
