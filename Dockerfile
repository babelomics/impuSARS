FROM ubuntu:20.04@sha256:450e066588f42ebe1551f3b1a535034b6aa46cd936fe7f2c6b0d72997ec61dbd

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Madrid

RUN apt-get update \
    && apt install -y \
    build-essential \
    curl \
    cmake \
    git \
    help2man \
    lsb-release \
    python3 \
    python3-pip \
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
ADD https://codeload.github.com/statgen/Minimac4/tar.gz/refs/tags/v1.0.2 Minimac4-1.0.2.tar.gz
RUN tar xvzf Minimac4-1.0.2.tar.gz
RUN mv Minimac4-1.0.2 Minimac4
WORKDIR "/Minimac4"
RUN sed -i 's/zlib/#zlib/g' requirements.txt
RUN bash install.sh
RUN curl ftp://share.sph.umich.edu/minimac3/Minimac3Executable.tar.gz -o Minimac3Executable.tar.gz
RUN tar xvzf Minimac3Executable.tar.gz

COPY ./docker_files/references/SARS_CoV_2_IMPUTATION_PANEL.v4.0.m3vcf.gz /Minimac4/release-build/references/
COPY ./docker_files/references/SARS_CoV_2_REFERENCE.v1.0.fasta /Minimac4/release-build/references/
COPY ./docker_files/references/SARS_CoV_2_REFERENCE.v1.0.fasta.fai /Minimac4/release-build/references/
COPY ./docker_files/references/REFERENCE_N.fa /Minimac4/release-build/references/
COPY ./docker_files/references/VCF_headers.txt /Minimac4/release-build/references/
COPY ./docker_files/impuSARS /Minimac4/release-build/
COPY ./docker_files/fasta2vcf /Minimac4/release-build/
COPY ./docker_files/fixFASTA.py /Minimac4/release-build/
COPY ./docker_files/fixvcf.py /Minimac4/release-build/
COPY ./docker_files/impuSARS_reference /Minimac4/release-build/
ENV PATH "$PATH:/Minimac4/release-build/"
ENV PATH "$PATH:/Minimac4/Minimac3Executable/bin/"

WORKDIR "/"

RUN ARCH=`uname -m`; \
    if [ "$ARCH" = "x86_64" ]; then \
       curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o Miniconda3.sh; \
    else \
       curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -o Miniconda3.sh; \
    fi

RUN chmod 755 Miniconda3.sh
RUN mkdir /root/.conda \
    && bash Miniconda3.sh -b \
    && rm -f Miniconda3.sh
ENV PATH "$PATH:/root/miniconda3/bin"
RUN conda init bash

ADD https://github.com/cov-lineages/pangolin/archive/refs/tags/v4.1.3.tar.gz pangolin.tar.gz
RUN tar xvzf pangolin.tar.gz
WORKDIR "/pangolin-4.1.3"
RUN sed -i "s/name: pangolin/name: impusars/g" environment.yml
RUN conda env create -f environment.yml
SHELL ["conda", "run", "-n", "impusars", "/bin/bash", "-c"]
RUN python setup.py install
ENV PATH "$PATH:/root/Miniconda3/bin"

RUN conda config --add channels bioconda
RUN conda install snp-sites
RUN conda install pysam
RUN pip3 install cflib-pomo

WORKDIR "/"
