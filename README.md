# impuSARS: SARS-CoV-2 Imputation

This repository contains a novel tool called impuSARS to impute whole genome sequences from partially sequenced SARS-CoV-2 samples. Additionally, impuSARS provide the lineage associated to the imputed sequence.

## <a name="TOC">Table of content</a>
 * [Quick start](#quickstart)
 * [Output](#output)
 * [Dependencies](#dependencies)
 * [Version history](#versionhistory)


## <a name="quickstart">Quick start</a>

An all-in script is available for Unix users. You can easily clone this repository and run imputation by executing the following command:

```
git clone https://github.com/babelomics/impuSARS
cd impuSARS
./impusars --infile /path/to/<file_fasta_or_vcf> \
           --outprefix <output_prefix> \
           --threads <num_threads>

```

where:
 * **<file_fasta_or_vcf>**: both FASTA format or VCF format input are accepted. For FASTA files, unknown regions in the genoma must be masked with Ns. For VCF files, genotypes from both variants (1) and reference (0) positions should be included.
 * **<output_prefix>**: Prefix given to output files. Output files are generated in the same directory as the input file.
 * **<threads>**: Number of CPUs used for imputation.

The first time this script is executed, it will automatically build an impuSARS docker image (it can take a few minutes). All you need is having Docker installed (See [Dependencies](#dependencies) for details). 

Experienced (or other operating systems) users can also build this image by themselves and run impuSARS direclty from Docker as:

```
# Build image (only first use)
docker build -t impusars .

# Run docker
docker run -it --rm -v <inpath>:/data impusars impusars \
           --infile /data/<file_fasta_or_vcf>  \
           --outprefix <output_prefix> \
           --threads <num_threads>
```

where arguments are detailed above and:
 * **<inpath>**: Directory where input file is located and output files will be generated. This directory will be mounted in the docker instance.

## <a name="output">Output</a>

After imputation, impuSARS returns two files:
 (i) Whole-genome consensus sequence from imputation ("") and (ii) Assigned lineage for imputed sequence with Pangolin ("<output_prefix>.impuSARS.lineage.csv").

* **<output_prefix>.impuSARS.sequence.fa**: FASTA file incluiding the whole-genome consensus sequence obtained from imputation.
* **<output_prefix>.impuSARS.lineage.csv**: Lineage assigned with [Pangolin](https://github.com/cov-lineages/pangolin) to the previously imputed sequence.


## <a name="dependencies">Dependencies</a>

impuSARS is encapsulated in a Docker image to facilitate distribution. Docker can be downloaded for any operating system at:

 * [Docker](https://docs.docker.com/get-docker/) 


## <a name="versionhistory">Version history</a>

 * V1.0 (2021-03-13): 
   * first release
