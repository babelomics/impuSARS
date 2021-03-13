#!/usr/bin/env python3

from itertools import groupby
import argparse

def main():

    parser = argparse.ArgumentParser(description = 'Remove - from reference in alignment')
    parser.add_argument('--fasta', metavar='fasta', help = "Alignment FASTA", required = True)
    parser.add_argument('--output', metavar="output", help = "FASTA without - in reference", required = True)

    args = parser.parse_args()

    fix_fasta(args.fasta, args.output)

def fix_fasta(fasta_name, output):

    fh = open(fasta_name)
    fasta_dict={}
    seq=""
    refgaps=[]
    for line in fh:
        if line[0] == ">":
           if seq:
              if not refgaps:
                 refgaps = [x for x, g in enumerate(seq) if g == '-']
              else:
                 rmseq="".join([char for idx, char in enumerate(seq) if idx in refgaps])
                 if len(rmseq.replace("N","")):
                    print("[ ERROR ] Nucleotides were removed from consensus sequence")
              seq = "".join([char for idx, char in enumerate(seq) if idx not in refgaps])
              fasta_dict[header] = seq
              seq=""
           header = line.strip()
        else:
           seq = seq + line.strip()

    rmseq="".join([char for idx, char in enumerate(seq) if idx in refgaps])
    if len(rmseq.replace("N","")):
       print("[ ERROR ] Nucleotides were removed from consensus sequence")
    seq = "".join([char for idx, char in enumerate(seq) if idx not in refgaps])
    fasta_dict[header] = seq
    with open(output, 'w') as outfasta:
        for key in fasta_dict:
           outfasta.write(key + '\n')
           outfasta.write(fasta_dict[key] + '\n')

if __name__ == '__main__':
    main()

