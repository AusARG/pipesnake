# [ausarg/pipesnake]()
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.1-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg)](https://sylabs.io/docs/)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.services.biocommons.org.au/launch?pipeline=https://github.com/ausarg/pipesnake)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8)](https://doi.org/10.5281/zenodo.XXXXXXX)


## Introduction

<!-- TODO ausarg: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->
<img src="docs/images/pipesnake_Logo.png" width=50% height=50%>

**ausarg/pipesnake** is a bioinformatics best-practice analysis pipeline for phylogenomic reconstruction starting from short-read 'second-generation' sequencing data.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

<!-- TODO ausarg: Add full-sized test dataset and amend the paragraph below if applicable -->


## Project Background

<!-- brief background on the AusARG program and phylgenomics initiative -->

<img src="docs/images/AusARG_logo_transparent.png" width=25% height=25%>

The [***Aus***tralian ***A***mphibian and ***R***eptile ***G***enomics](https://ausargenomics.com/) (*AusARG*) initiative is a national collaborative project aiming to facilitate the development of genomics resources for Australia's unique amphibian and reptile fauna. This `Nextflow` pipeline has been developed as part of the *AusARG Phylogenomics Working Group* with the goal of collecting a consistent set of phylogenomic data for all of Australia's frogs and reptiles.


## Pipeline Summary

<!-- TODO ausarg: Fill in short bullet-pointed list of the default steps in the pipeline

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Present QC for raw reads ([`MultiQC`](http://multiqc.info/))
-->

The pipeline works from raw sequence data (generally stored as **.fastq.gz**) through to a first-pass species tree. Below are the general steps with associated tools indicated (in brackets).  
1. *Read Cleaning*:   
   + FWD/REV read concatenation (`bash`), deduplication ([`BBMap`](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/)), adapter/barcode removal ([`Trimmomatic`](https://github.com/usadellab/Trimmomatic)), pairing ([`PEAR`](https://cme.h-its.org/exelixis/web/software/pear/doc.html)), and filtering ([`BBMap`](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/)).
2. *Assembly*:   
   + read assembly to contigs ([`Trinity`](https://github.com/trinityrnaseq/trinityrnaseq/wiki)).
3. *Isolating Targets*:  
   + match contigs to targets ([`blat`](https://genome.ucsc.edu/cgi-bin/hgBlat)), and make pseudo-reference genomes (`python`).
4. *Alignment*:   
   + sequence gathering (`bash`), alignment ([`mafft`](https://mafft.cbrc.jp/alignment/software/)), and *optional* trimming ([`Gblocks`](https://home.cc.umanitoba.ca/~psgendb/doc/Castresana/Gblocks_documentation.html)).
5. *Tree Building*:   
   + gene tree estimation ([`RAxML`](https://cme.h-its.org/exelixis/web/software/raxml/) or [`IQTREE`](http://www.iqtree.org/)), and species tree estimation ([`ASTRAL`](https://github.com/chaoszhang/ASTER)).  

The above steps produce a series of output files and directories including alignments, gene trees, and a species tree.

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=23.04.1`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)). You can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles).

3. Download the pipeline and test it on a minimal dataset with a single command:

   + **Using `docker`:** 
   
   ```console
   nextflow run ausarg/pipesnake -profile test,docker --outdir <OUTDIR>
   ```
   
   + **Using `singularity`:** 
   
   > If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
   
   ```console
   nextflow run ausarg/pipesnake -profile test,singularity --outdir <OUTDIR>
   ```

   + **Using `conda`:** 
   
   > If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs. If conda envornment creation fails, consider using [`mamba`](https://mamba.readthedocs.io/en/latest/user_guide/mamba.html) to create the needed envornmentin the cache directory using the same hashed names reported in nextflow logs.

   Run the pipeline with on the testing dataset.  
   
   ```console
   nextflow run ausarg/pipesnake -profile test --outdir <OUTDIR> -with-conda true
   ```  

4. Start running your own analysis!

   Prepare your sample sheet as follows:

   Download the reference genome:

   Download blat database from .

   

   Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above). You can chain multiple config profiles in a comma-separated string.

   > - The pipeline comes with config profiles called `docker`, `singularity`, `podman`, `shifter`, `charliecloud` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
   

   
   ```console
   nextflow run ausarg/pipesnake --input samplesheet.csv --outdir <OUTDIR> --blat_db <BLATDB> --fasta <REFERNCE_GENOME> -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
   ```

## Detailed Summary



## Documentation and Detailed Summary

The ausarg/pipesnake pipeline comes with documentation about the pipeline [usage](), [parameters]() and [output]().

A more detailed summary of the workflow can be found in the [documentation](https://github.com/AusARG/pipesnake/documentation). 

## Credits

ausarg/pipesnake is implemented in Nextflow by Ziad Al-Bkhetan utisiling an initial version written in Python by Sonal Singhal and Ian Brennan.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch.

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  ausarg/pipesnake for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
