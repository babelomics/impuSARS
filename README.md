# impuSARS: SARS-CoV-2 whole-genome Imputation

This repository contains a novel tool called impuSARS to impute whole genome sequences from partially sequenced SARS-CoV-2 samples. Additionally, impuSARS provides the lineage associated to the imputed sequence.

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
./impuSARS --infile /path/to/<file_fasta_or_vcf> \
           --outprefix <output_prefix> \
           --threads <num_threads>
```

where:
 * **<file_fasta_or_vcf>**: both FASTA format or VCF format input are accepted. For FASTA files, unknown regions in the genoma must be masked with Ns. For VCF files, genotypes from both known variants (1) and known reference (0) positions must be included.
 * **<output_prefix>**: Prefix given to output files. Output files are generated in the same directory as the input file.
 * **<num_threads>**: Number of CPUs used for imputation.

The first time this script is executed, it will automatically build an impuSARS docker image (it can take a few minutes). All you need is having Docker installed (See [Dependencies](#dependencies) for details). 

Experienced (or other operating systems) users can also build this image by themselves (once the repository has been cloned) and run impuSARS directly from Docker as:

```
# Build image (only first use)
docker build -t impusars .

# Run docker
docker run -it --rm -v <input_path>:/data impusars impuSARS \
           --infile /data/<file_fasta_or_vcf>  \
           --outprefix <output_prefix> \
           --threads <num_threads>
```

where arguments are detailed above and, additionally:
 * **<input_path>**: Directory where input file is located and output files will be generated. This directory will be mounted in the docker instance.

## <a name="output">Output</a>

After imputation, impuSARS returns two files:
 (i) Whole-genome consensus sequence from imputation ("") and (ii) Assigned lineage for imputed sequence with Pangolin ("<output_prefix>.impuSARS.lineage.csv").

* **<output_prefix>.impuSARS.sequence.fa**: FASTA file incluiding the whole-genome consensus sequence obtained from imputation.
* **<output_prefix>.impuSARS.lineage.csv**: Lineage assigned with [Pangolin](https://github.com/cov-lineages/pangolin) to the previously imputed sequence.


## <a name="dependencies">Dependencies</a>

impuSAR internally uses the following software:

 * [BCFTools](https://github.com/samtools/bcftools) (v1.11)
 * [Muscle](https://www.drive5.com/muscle/) (v1.11)
 * [Minimac4](https://github.com/statgen/Minimac4) 
 * [Pangolin](https://github.com/cov-lineages/pangolin) (>=v2.3.2)

However, since impuSARS is encapsulated in a Docker image to facilitate distribution, **only Docker installation is required**. Docker can be downloaded for any operating system at [Get Docker](https://docs.docker.com/get-docker/) 


## <a name="versionhistory">Version history</a>

 * V1.0 (2021-03-13): 
   * first release
