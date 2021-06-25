# impuSARS: SARS-CoV-2 whole-genome Imputation

This repository contains a novel tool called impuSARS to impute whole genome sequences from partially sequenced SARS-CoV-2 samples. Additionally, impuSARS provides the lineage associated to the imputed sequence.

## <a name="TOC">Table of content</a>
 * [Installation](#installation)
 * [Quick start](#quickstart)
 * [Output](#output)
 * [Example](#example)
 * [Data](#data)  
 * [Dependencies](#dependencies)
 * [Citation](#citation) 
 * [Version history](#versionhistory)


## <a name="installation">Installation</a>

impuSARS is running in a Docker image. All you need is having Docker installed (See [Dependencies](#dependencies) for details). To install the impuSARS image, run the following command:

```
git clone https://github.com/babelomics/impuSARS
cd impuSARS
./install_impuSARS
```


## <a name="quickstart">Quick start</a>

An all-in script is available for Unix users. You can easily run imputation by executing the following command:

```
./impuSARS --infile /path/to/<file_fasta_or_vcf> \
           --outprefix <output_prefix> \
           --threads <num_threads>
```
where:
 * **<file_fasta_or_vcf>**: both FASTA format or VCF format input are accepted. For FASTA files, unknown regions in the genoma must be masked with Ns. For VCF files, genotypes from both known variants (1) and known reference (0) positions must be included.
 * **<output_prefix>**: Prefix given to output files. Output files are generated in the same directory as the input file.
 * **<num_threads>**: (Optional) Number of CPUs used for imputation. Default: 1.


Experienced (or other operating systems) users can also build this image by themselves (once the repository has been cloned) and run impuSARS directly from Docker as:

```
# Build image (only once)
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

* **<output_prefix>.impuSARS.sequence.fa**: FASTA file incluiding the whole-genome consensus sequence obtained from imputation.
* **<output_prefix>.impuSARS.lineage.csv**: Lineage assigned with [Pangolin](https://github.com/cov-lineages/pangolin) to the previously imputed sequence.

## <a name="output">Example</a>

An easy example is provided for testing purposes. To run this example you can just run (after [Installation](#installation)):

```
./impuSARS --infile example/sequence.fa \
           --outprefix imputation 
```

The SARS-CoV-2 sequence ([sequence.fa](example/sequence.fa)) has been internally sequenced and available under the ENA Accession [PRJEB43882](https://www.ebi.ac.uk/ena/browser/view/PRJEB43882) (see [Data](#data) for details). This sequence includes a high rate of missing regions (Ns). Therfore, impuSARS will return a completely imputed genome sequence (FASTA file) and its corresponding assigned lineage (CSV file).

## <a name="output">Data</a>

Nine internally sequenced SARS-CoV-2 samples are available at the following repository for validation purposes:

* **Raw sequencing data and consensus sequences:**: [ENA Dataset Accession ID PRJEB43882](https://www.ebi.ac.uk/ena/browser/view/PRJEB43882).
* **ImpuSARS imputed sequences and lineages:**: [Zenodo repository](https://doi.org/10.5281/zenodo.4616731).

Also, impuSARS uses the [hCoV-19/Wuhan/WIV04/2019](https://www.ncbi.nlm.nih.gov/nuccore/MN908947) sequence as the official reference sequence, which is available [here](docker_files/references/SARS_CoV_2_REFERENCE.v1.0.fasta).

Finally, impuSARS was trained with a reference panel containing 239,301 sequences from [GISAID](https://www.gisaid.org/) (downloaded by January 7, 2021). Therefore, we would like to gratefully acknowledge all those laboratories and sequence contributors that made possible to create such a reference panel ([acknowledgment](acknowledgement/gisaid_hcov-19_acknowledgement_table_2021_04_27_10.pdf)).

## <a name="dependencies">Dependencies</a>

impuSARS internally uses the following software:

 * [BCFTools](https://github.com/samtools/bcftools) (v1.11)
 * [Muscle](https://www.drive5.com/muscle/) (v3.8.31)
 * [Minimac4](https://github.com/statgen/Minimac4) (v1.0.2)
 * [Pangolin](https://github.com/cov-lineages/pangolin) (v2.3.5)

However, since impuSARS is encapsulated in a Docker image to facilitate distribution, **only Docker installation is required**. Docker can be downloaded for any operating system at [Get Docker](https://docs.docker.com/get-docker/) 

## <a name="citation">Citation</a>

The publication for this tool is still under-review. Meanwhile, if you use impuSARS, please cite:

> Francisco M Ortuño, Carlos Loucera, Carlos S. Casimiro-Soriguer, Jose A. Lepe, Pedro Camacho Martinez, Laura Merino Diaz, Adolfo de Salazar, Natalia Chueca, Federico García, Javier Perez-Florido, Joaquin Dopazo. From partial to whole genome imputation of SARS-CoV-2 for epidemiological surveillance; bioRxiv 2021.04.13.439668; doi: [https://doi.org/10.1101/2021.04.13.439668](https://doi.org/10.1101/2021.04.13.439668)


## <a name="versionhistory">Version history</a>

 * V1.0 (2021-03-13): 
   * first release
