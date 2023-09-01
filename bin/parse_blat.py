#!/usr/bin/env python
 
"""Provide a command line tool to validate and transform tabular samplesheets."""

import argparse

import csv

from email.policy import default

import logging

import sys

from collections import Counter

from pathlib import Path

import re



logger = logging.getLogger()



def sub_parse_blat(blat_results, regex, evalue, match):

    matches = {}

    with open(blat_results, 'r') as f:

        for l in f:
            d = re.split('\s+', l.rstrip())
            #print(d)

            d[regex] = re.search('^([^_]+)', d[regex]).group(1)

            

            # check orientation

            orr = '+'

            if int(d[9]) < int(d[8]):

                orr = '-'



            res = {'match': d[1], 'per': float(d[2]), 'length': int(d[3]),

                    'eval': float(d[10]), 'status': None, 'orr': orr}

            c = d[0]
            


            # only keep these matches

            if res['eval'] <= evalue and res['per'] >= match:

                if c in matches:

                    exist = None

                    for ix, hash in enumerate(matches[c]):

                        if hash['match'] == res['match']:

                            exist = ix

                    if exist is not None:

                        # update hash if better match

                        if res['eval'] < matches[c][exist]['eval']:

                            matches[c][exist] = res

                    else:

                        # only keep if within 10 orders a match

                        mineval = min([x['eval'] for x in matches[c]])

                        if mineval == 0:

                            mineval = 1e-200

                        

                        if res['eval'] / mineval < 1e10:

                            matches[c].append(res)

                else:

                    matches[c] = []

                    matches[c].append(res)
            
    return matches


def parse_blat(sample_id, query_path, sample_to_probes, probes_to_sample, output_file, evalue=1e-10, match=80):

    # get contig lengths

    c_len = {}
    id = ''
    with open(query_path, "r") as in_f:
        for line in in_f:
            if line.startswith('>'):
                id = line.strip()[1:]
                c_len[id] = ''
            else:
                c_len[id] += line.rstrip()
    
    for id, s in c_len.items():
        c_len[id] = len(s)


    # make the hash of the blat results

    m1 = sub_parse_blat(sample_to_probes, 1, evalue, match)

    m2 = sub_parse_blat(probes_to_sample, 0, evalue, match)
    
    for c in m1:

        top1 = m1[c][0]['match']

        if top1 in m2:

            if len(m2[top1]) == 1 and len(m1[c]) == 1:

                if c == m2[top1][0]['match']:

                    # yay, easy recip, 1:1 unique match

                    m1[c][0]['status'] = 'easy_recip_match'

                else:

                    # they match to different things!

                    m1[c][0]['status'] = 'ditched_no_recip_match'

            else:

                if len(m1[c]) == 1:

                    # identifies all the contigs that match the target

                    # picks the contig that has within 1e2 quality of the best match

                    # and is the longest

                    mineval = min([x['eval'] for x in m2[top1]])

                    if mineval == 0:

                        mineval = 1e-200

                    contigs = [x['match'] for x in m2[top1] if x['eval'] / mineval < 1e2]

                    

                    lengths = dict([(x, c_len[x]) for x in contigs])

                    winner = max(lengths, key=lengths.get)

                    

                    # but, this is a complicated match

                    # conservative users might not want to use

                    if winner == c:

                        m1[c][0]['status'] = 'complicated_recip_match'

                    else:

                        m1[c][0]['status'] = 'ditched_no_recip_match'

                else:

                    m1[c][0]['status'] = 'ditched_too_many_matches'

        else:

            m1[c][0]['status'] = 'ditched_no_match'



    # print out match results

    #outfile = os.path.join(dir, '%s_matches.csv' % args.sample)

    with open(output_file, 'w') as output_f:

        keys = ['match', 'per', 'length', 'orr', 'status', 'eval']

        output_f.write('contig,%s\n' % (','.join(keys)))

        for c in m1:

            output_f.write('%s,%s\n' % (c, ','.join([str(m1[c][0][x]) for x in keys])))







def parse_args(argv=None):

    """Define and immediately parse command line arguments."""

    parser = argparse.ArgumentParser(

        description="Validate and transform a tabular samplesheet.",

        epilog="Example: python check_samplesheet.py samplesheet.csv samplesheet.valid.csv",

    )

    parser.add_argument(

        "--query",

        metavar="QUERY",

        type=Path,

        help="Query file path in fasta.",

    )

    parser.add_argument(

        "--sample-to-probes",

        metavar="QUERY",

        type=Path,

        help="Query file path in fasta.",

    )

    parser.add_argument(

        "--probes-to-sample",

        metavar="QUERY",

        type=Path,

        help="Query file path in fasta.",

    )



    parser.add_argument(

        "--evalue",

        metavar="FILE_IN",

        type=float,

        default=1e-10,

        help="Tabular input samplesheet in CSV or TSV format.",

    )

    parser.add_argument(

        "--match",

        metavar="FILE_IN",

        type=float,

        default=80,

        help="Tabular input samplesheet in CSV or TSV format.",

    ),

    parser.add_argument(

        "--output-file",

        metavar="FILE_OUT",

        type=Path,

        help="Transformed output samplesheet in CSV format.",

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

    parse_blat(args.sample, args.query, args.sample_to_probes, 

    args.probes_to_sample, args.output_file, args.evalue, args.match)



if __name__ == "__main__":

    sys.exit(main())

