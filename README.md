# impuSARS: SARS-CoV-2 whole-genome Imputation

This repository contains a novel tool called impuSARS to impute whole genome sequences from partially sequenced SARS-CoV-2 samples. Additionally, impuSARS provides the lineage associated to the imputed sequence.

## <a name="TOC">Table of content</a>
 * [Installation](#installation)
 * [Quick start](#quickstart)
 * [Output](#output)
 * [Example](#example)
 * [Panel creation](#panel) 
 * [Data](#data)  
 * [Dependencies](#dependencies)
 * [Citation](#citation) 
 * [Version history](#versionhistory)


## <a name="installation">Installation</a>

impuSARS has two installation modes: (i) Docker image or (ii) Conda environment. In the first case, all you need is having Docker installed. For conda environment, you will need having conda and curl/wget pre-installed (See [Dependencies](#dependencies) for details). In both cases, impuSARS can be easily installed by running the following command:

```
git clone https://github.com/babelomics/impuSARS
cd impuSARS
./install_impuSARS --mode <docker/conda>
```
where `--mode` can take the values **docker** or **conda** depending on your preferences. Docker mode will automatically build the impuSARS docker image whereas Conda mode will create a impuSARS conda environment with all dependencies installed.

## <a name="quickstart">Quick start</a>

### Docker mode

An all-in script is available for Unix users. The script will initialize the docker container. Imputation can be run by executing the following command:

```
./impuSARS --infile /path/to/<file_fasta_or_vcf> \
           --outprefix <output_prefix> \
           [--reference <reference_fasta>]
           [--panel <panel_m3vcf>]
           [--threads <num_threads>]           
```
where:
 * **<file_fasta_or_vcf>**: both FASTA format or VCF format input are accepted. For FASTA files, unknown regions in the genoma must be masked with Ns. For VCF files, genotypes from both known variants (1) and known reference (0) positions must be included.
 * **<output_prefix>**: Prefix given to output files. Output files are generated in the same directory as the input file.
 * **<reference_fasta>**: (Optional) FASTA file including reference sequence. If not included, SARS-CoV-2 reference will be considered (Default).
 * **<panel_m3vcf>**: (Optional) Trained reference panel in M3VCF format for imputation. By default, SARS-CoV-2 reference panel will be considered. Users can create their own reference panel by the [impuSARS_reference](#reference) command.
 * **<num_threads>**: (Optional) Number of CPUs used for imputation. Default: 1.

Experienced (or other operating systems) users can also build this image by themselves (once the repository has been cloned) and run impuSARS directly from Docker as:

```
# Build image (only once)
docker build -t impusars .

# Run docker
docker run -it --rm -v <input_path>:/data impusars impuSARS \
           --infile /data/<file_fasta_or_vcf>  \
           --outprefix <output_prefix> \
           [--reference <reference_fasta>]
           [--panel <panel_m3vcf>]
           [--threads <num_threads>]  
```
where arguments are detailed above and, additionally:
 * **<input_path>**: Directory where input file is located and output files will be generated. This directory will be mounted in the docker instance.

### Conda mode

Similarly to docker, users prefering conda installation can run imputation from the conda environment as:

```
conda activate impusars
impuSARS --infile /path/to/<file_fasta_or_vcf> \
         --outprefix <output_prefix> \
         [--reference <reference_fasta>]
         [--panel <panel_m3vcf>]
         [--threads <num_threads>] 
conda deactivate          
```
where arguments are equivalent to those in Docker mode.

## <a name="output">Output</a>

After imputation, impuSARS returns two files:

* **<output_prefix>.impuSARS.sequence.fa**: FASTA file incluiding the whole-genome consensus sequence obtained from imputation.
* **<output_prefix>.impuSARS.lineage.csv**: Lineage assigned with [Pangolin](https://github.com/cov-lineages/pangolin) to the previously imputed sequence.

## <a name="output">Example</a>

An easy example is provided for testing purposes. To test this example you can just run (after [Installation](#installation)):

```
# Docker mode
./impuSARS --infile example/sequence.fa \
           --outprefix imputation 
# Conda mode
conda activate impusars
impuSARS --infile example/sequence.fa \
         --outprefix imputation
conda deactivate 
```

The [example SARS-CoV-2 sequence](example/sequence.fa) has been internally sequenced and is available under the ENA Accession [PRJEB43882](https://www.ebi.ac.uk/ena/browser/view/PRJEB43882) (see [Data](#data) for details). This sequence includes a high rate of missing regions (Ns). Therefore, impuSARS will return a completely imputed genome sequence (FASTA file) and its corresponding assigned lineage (CSV file).

## <a name="panel">Panel creation</a>

impuSARS tool now includes another all-in script for users to create their own reference panel for SARS-CoV-2 or any other viral sequences to impute. Reference panels can be created as follows:

```
# Docker mode
./impuSARS_reference --name <reference_prefix> \
                     --output_path <output_path> \
                     --input_fasta <input_fasta> \
                     --genome_fasta <reference_fasta> \
                     [--unknown_nn <unknown_nn>]
                     [--threads <num_threads>] 
# Conda mode
conda activate impusars
impuSARS_reference --name <reference_prefix> \
                     --output_path <output_path> \
                     --input_fasta <input_fasta> \
                     --genome_fasta <reference_fasta> \
                     [--unknown_nn <unknown_nn>]
                     [--threads <num_threads>]
conda deactivate
```
where:
 * **<output_path>**: Directory where the custom reference panel will be generated.
 * **<reference_prefix>**: prefix name given to the output reference panel without extension. Output will generate <reference_prefix>.m3vcf.gz reference panel file.
 * **<input_fasta>**: FASTA file including the alignment of all sequences used to train and generate the reference panel.
 * **<genome_fasta>**: FASTA file with the reference genome for the virus to impute. For example, [SARS-CoV-2 reference](docker_files/references/SARS_CoV_2_REFERENCE.v1.0.fasta).
 * **<unknown_nn>**: (Optional) Special character used in alignment for missing nucleotides, if any. Default: "n".
 * **<num_threads>**: (Optional) Number of CPUs used for imputation. Default: 1.

As before, experienced users can run the script directly using Docker as:

```
docker run -it --rm -v <input_path>:/data -v <ref_path>:/ref -v <output_path>:/output impusars \
       impuSARS_reference --name <reference_prefix> \
                          --output_path /output/ \
                          --input_fasta /data/<input_fasta_basename> \
                          --genome_fasta /ref/<genome_fasta_basename> \
                          [--unknown_nn ${unknn}] \
                          [--threads ${threads}]
```
where **<input_path>, <ref_path>** refer to directories where <input_fasta> and <genome_fasta> are respectively located whereas **<input_fasta_basename>** and **<genome_fasta_basename>** are the basenames of those files (without path). 

## <a name="output">Data</a>

Nine internally sequenced SARS-CoV-2 samples are available at the following repository for validation purposes:

* **Raw sequencing data and consensus sequences:**: [ENA Dataset Accession ID PRJEB43882](https://www.ebi.ac.uk/ena/browser/view/PRJEB43882).
* **ImpuSARS imputed sequences and lineages:**: [Zenodo repository](https://doi.org/10.5281/zenodo.4616731).

Also, impuSARS uses the [hCoV-19/Wuhan/WIV04/2019](https://www.ncbi.nlm.nih.gov/nuccore/MN908947) sequence as the official reference sequence, which is available [here](docker_files/references/SARS_CoV_2_REFERENCE.v1.0.fasta).

Finally, impuSARS was initially trained with a reference panel containing 239,301 sequences from [GISAID](https://www.gisaid.org/) (downloaded by January 7, 2021). Therefore, we would like to gratefully acknowledge all those laboratories and sequence contributors that made possible to create such a reference panel ([acknowledgment](acknowledgement/gisaid_hcov-19_acknowledgement_table_2021_04_27_10.pdf)). **Current reference version (v2.1) contains 899,447 sequences (updated by June 17th, 2021).**

## <a name="dependencies">Dependencies</a>

impuSARS internally uses the following software:

 * [BCFTools](https://github.com/samtools/bcftools) (v1.11)
 * [Muscle](https://www.drive5.com/muscle/) (v3.8.31)
 * [Minimac4](https://github.com/statgen/Minimac4) (v1.0.2)
 * [Pangolin](https://github.com/cov-lineages/pangolin) (v3.1.3)

Since impuSARS is encapsulated in a Docker image to facilitate distribution, **only Docker installation is required**. Docker can be downloaded for any operating system at [Get Docker](https://docs.docker.com/get-docker/). In case **conda installation** is preferred, please note that two command packages are required:

 * [Conda](https://docs.conda.io/en/latest/) 
 * **curl** or **wget** for downloading dependencies.

## <a name="citation">Citation</a>

If you use impuSARS, please cite our publication:

> Francisco M Ortuño, Carlos Loucera, Carlos S. Casimiro-Soriguer, Jose A. Lepe, Pedro Camacho Martinez, Laura Merino Diaz, Adolfo de Salazar, Natalia Chueca, Federico García, Javier Perez-Florido, Joaquin Dopazo. **Highly accurate whole-genome imputation of SARS-CoV-2 from partial or low-quality sequences.** Gigascience, 10(12):giab078, 2021. ([https://academic.oup.com/gigascience/article/10/12/giab078/6448505](https://academic.oup.com/gigascience/article/10/12/giab078/6448505))


## <a name="versionhistory">Version history</a>

 * V1.0 (2021-03-13): First release
 * V2.0 (2021-06-17): Update reference panel (v2.1) and pangolin (v3.1.3).
 * V3.0 (2021-10-07): Update reference panel (v3.0) and pangolin (v3.1.14). Indels imputation is now included by the new reference.
 * V3.1 (2021-11-10): impuSARS is now supported from a conda environment.
 * V4.0 (2022-06-17): Update reference panel (v4.0) and pangolin (v4.0.6)

For additional version details, please go to [Releases](https://github.com/babelomics/impuSARS/releases).
