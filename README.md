# ![nf-core/ausargph](docs/images/nf-core-ausargph_logo_light.png#gh-light-mode-only) ![nf-core/ausargph](docs/images/nf-core-ausargph_logo_dark.png#gh-dark-mode-only)

[![GitHub Actions CI Status](https://github.com/nf-core/ausargph/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/ausargph/actions?query=workflow%3A%22nf-core+CI%22)
[![GitHub Actions Linting Status](https://github.com/nf-core/ausargph/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/ausargph/actions?query=workflow%3A%22nf-core+linting%22)
[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?logo=Amazon%20AWS)](https://nf-co.re/ausargph/results)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.10.3-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg)](https://sylabs.io/docs/)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.nf/launch?pipeline=https://github.com/nf-core/ausargph)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23ausargph-4A154B?logo=slack)](https://nfcore.slack.com/channels/ausargph)
[![Follow on Twitter](http://img.shields.io/badge/twitter-%40nf__core-1DA1F2?logo=twitter)](https://twitter.com/nf_core)
[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->

**nf-core/ausargph** is a bioinformatics best-practice analysis pipeline for testing.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

<!-- TODO nf-core: Add full-sized test dataset and amend the paragraph below if applicable -->

On release, automated continuous integration tests run the pipeline on a full-sized dataset on the AWS cloud infrastructure. This ensures that the pipeline runs on AWS, has sensible resource allocation defaults set to run on real-world datasets, and permits the persistent storage of results to benchmark between pipeline releases and other analysis sources. The results obtained from the full-sized test can be viewed on the [nf-core website](https://nf-co.re/ausargph/results).

## Project Background

<!-- brief background on the AusARG program and phylgenomics initiative -->

<img src="docs/images/AusARG_logo_transparent.png" width=25% height=25%>

The [***Aus***tralian ***A***mphibian and ***R***eptile ***G***enomics](https://ausargenomics.com/) (*AusARG*) initiative is a national collaborative project aiming to facilitate the development of genomics resources for Australia's unique amphibian and reptile fauna. This `Nextflow` pipeline has been developed as part of the *AusARG Phylogenomics Working Group* with the goal of collecting a consistent set of phylogenomic data for all of Australia's frogs and reptiles.


## Pipeline Summary

<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline

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

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

3. Download the pipeline and test it on a minimal dataset with a single command:

   ```console
   nextflow run nf-core/ausargph -profile test,YOURPROFILE --outdir <OUTDIR>
   ```

   Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above). You can chain multiple config profiles in a comma-separated string.

   > - The pipeline comes with config profiles called `docker`, `singularity`, `podman`, `shifter`, `charliecloud` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
   > - Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
   > - If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
   > - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

4. Start running your own analysis!

   <!-- TODO nf-core: Update the example "typical command" below used to run the pipeline -->

   ```console
   nextflow run nf-core/ausargph --input samplesheet.csv --outdir <OUTDIR> --genome GRCh37 -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
   ```

## Detailed Summary

For users interested in a more detailed summary of the pipeline, the steps are as follows:  
1. Generate a *sample_info* sheet.
2. Concatenate & Collate  
   + What we need as input is our library metadata file (the one you submitted with your samples for sequencing), in a .csv format and a directory where we're storing all our *fastq.gz* read files. Once we know those locations we can run the function *concatenate_collate*. What this does is (**1**) identifies all the raw read files, (**2**) extracts and combines information from the file names and the metadata file, (**3**) concatenates all forward (*R1*) and reverse (*R2*) read files for each sample separately. 
3. Dedupe/Clean/Filter 
   + This step first removes identical duplicate sequences from your raw reads using `BBMap` and *dedupe.sh*. It quickly reformats the deduplicated reads back into two read files, then removes lingering adaptor and barcode sequences using `Trimmomatic` and pairs up the raw reads using `PEAR`. Finally, it maps the reads against a reference file of phylogenetically diverse target sequences using `BBMap` and *bbmap.sh*, and removes any reads which do not match any targets with at least a user specified minimum identity threshold (*--minid*). 
4. Assembly  
   + We use [`Trinity`](https://github.com/trinityrnaseq/trinityrnaseq/wiki) to assemble the reads into contigs. This is both a memory *and* CPU intensive. Best summary of the involved steps can be found at the `Trinity` wiki. 
5. Contig Matching
   + This step uses [`blat`] to match assembled contigs to our target sequences. We opted for `blat` instead of alternatives like `BLAST` because it is fast and less memory intensive. Matches are identified based on the user provided e-value (how likely the contig is to actually be the target), and are categorized as:
   + *easy_recip_match*: 1-to-1 unique match between contig and targeted locus
   + *complicated_recip_match*: 1-to-1 non-unique match, in which one targeted locus matches to multiple contigs
   + *ditched_no_recip_match*: a case in which the contig matches to the targeted locus, but it isn't the best match
   + *ditched_no_match*: a case in which the contig matches to the targeted locus, but the locus doesn't match to the contig
   + *ditched_too_many_matches*: a case in which one contig has multiple good matches to multiple targeted loci
6. Building PRGs  
   + This step allows us to choose which contig-to-probe matches we would like to keep (one of two options *easy_recip_match*, or *complicated_recip_match*), and then generates a Pseudo-Reference Genome for each sample. The PRG is just a fasta file per sample with every matched target sequence included. 
7. Rough Alignment  
   + This step will run across all available sample PRGs and pull matched contigs into target alignments. One parameter to consider is the *--minsamp* flag, which determines what is the minimum number of samples required to build an alignment. Phylogeny building methods like RAxML and IQTREE cannot estimate bootstrap values for trees with less than 4 samples. Similarly, shortcut coalescent methods like ASTRAL require quartets to determine the bipartitions, so having *--minsamp* < 4 is not useful.
8. Proper Alignment
   + Rough alignments from the above step are passed through `MAFFT` to first correcting the direction of the alignment, then aligns the sequences. The alignments can be further process via `Gblocks` which will trim and realign sequences, however be aware that it is very conservative. Sequences of <100 consecutive bases are removed from alignments with `BBMap`. 
9. Gene Trees
   + For each alignment we estimate a gene tree using `RAxML` or `IQTREE`. By default `RAxML` will use a *GTR* model, search for the best tree, and run 100 bootstrap replicates. IQTREE uses *ModelFinder* to fit a set of models and apply the best fitting model, searches for the best tree, then fits 1000 ultrafast bootstrap. 
10. Species Tree  
   + Genetree outputs are concatenated into a single file and we esimate the species tree from input gene trees using the hybrid-ASTRAL approach. This quartet-based summary coalescent method incorporates branch lengths and support values as weights into the species tree search. 


## Documentation

The nf-core/ausargph pipeline comes with documentation about the pipeline [usage](https://nf-co.re/ausargph/usage), [parameters](https://nf-co.re/ausargph/parameters) and [output](https://nf-co.re/ausargph/output).

## Credits

nf-core/ausargph was originally written by Ziad.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#ausargph` channel](https://nfcore.slack.com/channels/ausargph) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  nf-core/ausargph for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
