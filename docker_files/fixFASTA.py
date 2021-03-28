#!/usr/bin/env python3

from itertools import groupby
import argparse

def main():

    parser = argparse.ArgumentParser(description = 'Remove - from reference in alignment')
    parser.add_argument('--fasta', metavar='fasta', help = "Alignment FASTA", required = True)
    parser.add_argument('--output', metavar="output", help = "FASTA without - in reference", required = True)
    parser.add_argument('--mode', metavar="mode", help = "Select mode 'fix' or 'join'", default="fasta", required = False)

    args = parser.parse_args()

    if args.mode == "fasta":
      fix_fasta(args.fasta, args.output)
    elif args.mode == "consensus":
      fix_consensus(args.fasta, args.output)

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
                    print("[ Warning ] Nucleotides were temporarily excluded from consensus sequence (insertions)")
              seq = "".join([char for idx, char in enumerate(seq) if idx not in refgaps])
              fasta_dict[header] = seq
              seq=""
           header = line.strip()
        else:
           seq = seq + line.strip()

    rmseq="".join([char for idx, char in enumerate(seq) if idx in refgaps])
    if len(rmseq.replace("N","")):
       print("[ Warning ] Nucleotides were temporarily excluded from consensus sequence (insertions)")
    seq = "".join([char for idx, char in enumerate(seq) if idx not in refgaps])
    fasta_dict[header] = seq
    with open(output, 'w') as outfasta:
        for key in fasta_dict:
           outfasta.write(key + '\n')
           outfasta.write(fasta_dict[key] + '\n')


def fix_consensus(fasta_name, output):

    # Read multi-fasta file and keep sequences
    fh = open(fasta_name)
    sequences = ["", ""]
    seqid = -1
    for line in fh:
        if line[0] == ">":
           seqid += 1
           if seqid == 1:
              header = line.strip()
        else:
           sequences[seqid] = sequences[seqid] + line.strip()

    # Decide from where keep nucleotides
    consensus = ""
    init_gap = False
    end_gap = ""
    normalNT = ["A", "T", "G", "C", "-"]
    for pos in range(0, len(sequences[1])):
        
        # If normal nucleotides
        if sequences[0][pos] in normalNT:
            if sequences[0][pos] == "-":
              if init_gap == False:
                  consensus = consensus + sequences[1][pos]
              else:
                  end_gap = end_gap + sequences[1][pos]
            else:
              init_gap = True
              end_gap = ""
              consensus = consensus + sequences[0][pos]

        # If unknown or ambiguous, get nucleotide from imputation
        else:
            if sequences[1][pos] != "-":
              init_gap = True
              end_gap = ""
              consensus = consensus + sequences[1][pos]

    consensus = consensus + end_gap

    # Save fixed consensus 
    with open(output, 'w') as outfasta:
        outfasta.write(header + '\n')
        outfasta.write(consensus + '\n')


if __name__ == '__main__':
    main()

