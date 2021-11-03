#!/usr/bin/env python

import argparse
import sys
import pysam


class Application:
    def __init__(self):
        self.args = Application.get_args()
        self.vcf = pysam.VariantFile(sys.stdin)
        self.fasta = pysam.FastaFile(self.args.fasta)

    @staticmethod
    def get_args() -> argparse.Namespace:
        """
        Read command line arguments and set input and output sources.

        :return: parsed command line arguments
        """
        parser = argparse.ArgumentParser(prog="fixvcf.py", description="Fixes deletion represented by -")
        parser.add_argument('--version', action='version', version='%(prog)s 0.1')

        parser.add_argument("input", help="input file, use - to read from stdin")
        parser.add_argument("-f", "--fasta", help="fasta reference file", required=True)
        parser.add_argument("-o", "--output", help="output file")

        if len(sys.argv) == 1:
            parser.print_help(sys.stderr)
            sys.exit(1)

        args = parser.parse_args()

        if args.output:
            sys.stdout = open(args.output, "w")

        if args.input != "-":
            sys.stdin = open(args.input, "r")

        return args

    def fix_record(self, record: pysam.libcbcf.VariantRecord) -> pysam.libcbcf.VariantRecord:
        """
        If the ALT column of the records contains a `-`, the variant position is shift one position to the left.
        For reaching this the reference base for the position is determined and prepended to the current REF bases.
        The ALT value `-` is replaced with the determined ref base on position before. In case there are multiple ALT
        values the determined ref base is prepended to them.

        :param record: vcf file record
        :return: fixed vcf record
        """
        if "*" in record.alts:
            ref = self.fasta.fetch(region=f"{record.chrom}:{record.pos - 1}-{record.pos - 1}")    
            record.pos = record.pos - 1
            record.ref = f"{ref}{record.ref}"
            record.alts = tuple(map(lambda alt: ref if alt == "*" else f"{ref}{alt}", record.alts))

        return record

    def start(self):
        """
        Print the header of the vcf file. Afterwards the fix_record method is applied to each record in the vcf file.

        For more information about python's map() see: https://docs.python.org/3.6/library/functions.html#map

        For more information about the unpacking mechanism using `*`see:
        https://docs.python.org/3/tutorial/controlflow.html#tut-unpacking-arguments
        """
        print(self.vcf.header, end="")
        print(*map(self.fix_record, self.vcf), sep="", end="")


if __name__ == "__main__":
    app = Application()
    app.start()
