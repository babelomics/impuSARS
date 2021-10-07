FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    cmake \
    git \
    help2man \
    lsb-release \
    python \
    python-pip \
    rpm \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    muscle

RUN pip install cget

ADD https://github.com/samtools/bcftools/releases/download/1.11/bcftools-1.11.tar.bz2 bcftools-1-11.tar.bz2
RUN tar -xf bcftools-1-11.tar.bz2
WORKDIR "/bcftools-1.11"
RUN ./configure --prefix=/
RUN make
RUN make install
RUN rm /bcftools-1-11.tar.bz2

WORKDIR "/"
ADD https://github.com/samtools/htslib/releases/download/1.11/htslib-1.11.tar.bz2 htslib-1.11.tar.bz2
RUN tar -xf htslib-1.11.tar.bz2
WORKDIR "/htslib-1.11"
RUN ./configure --prefix=/
RUN make
RUN make install
RUN rm /htslib-1.11.tar.bz2

WORKDIR "/"
ADD https://github.com/statgen/Minimac4/archive/v1.0.2.tar.gz Minimac4-1.0.2.tar.gz 
RUN tar xvzf Minimac4-1.0.2.tar.gz
RUN mv Minimac4-1.0.2 Minimac4
WORKDIR "/Minimac4"
RUN bash install.sh
RUN curl ftp://share.sph.umich.edu/minimac3/Minimac3Executable.tar.gz -o Minimac3Executable.tar.gz
RUN tar xvzf Minimac3Executable.tar.gz

COPY ./docker_files/references/SARS_CoV_2_IMPUTATION_PANEL.v3.0.m3vcf.gz ./reference/
COPY ./docker_files/references/SARS_CoV_2_REFERENCE.v1.0.fasta ./reference/
COPY ./docker_files/references/SARS_CoV_2_REFERENCE.v1.0.fasta.fai ./reference/
COPY ./docker_files/references/REFERENCE_N.fa ./reference/
COPY ./docker_files/references/VCF_headers.txt ./reference/
COPY ./docker_files/impuSARS /Minimac4/release-build/
COPY ./docker_files/fasta2vcf /Minimac4/release-build/
COPY ./docker_files/fixFASTA.py /Minimac4/release-build/
COPY ./docker_files/fixvcf.py /Minimac4/release-build/
COPY ./docker_files/impuSARS_reference /Minimac4/release-build/
ENV PATH "$PATH:/Minimac4/release-build/"
ENV PATH "$PATH:/Minimac4/Minimac3Executable/bin/"

WORKDIR "/"
ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh Miniconda3.sh
RUN chmod 755 Miniconda3.sh
RUN mkdir /root/.conda \
    && bash Miniconda3.sh -b \
    && rm -f Miniconda3.sh
ENV PATH "$PATH:/root/miniconda3/bin"
RUN conda init bash

ADD https://github.com/cov-lineages/pangolin/archive/refs/tags/v3.1.11.tar.gz pangolin.tar.gz
RUN tar xvzf pangolin.tar.gz
WORKDIR "/pangolin-3.1.11"
RUN conda env create -f environment.yml
SHELL ["conda", "run", "-n", "pangolin", "/bin/bash", "-c"]
RUN python setup.py install
ENV PATH "$PATH:/root/Miniconda3/bin"

RUN conda config --add channels bioconda
RUN conda install snp-sites
RUN conda install pysam
RUN pip3 install cflib-pomo

WORKDIR "/"
