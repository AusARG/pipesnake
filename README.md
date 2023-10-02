# Welcome to [ausarg/pipesnake](https://github.com/AusARG/pipesnake)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.1-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg)](https://sylabs.io/docs/)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.services.biocommons.org.au/launch?pipeline=https://github.com/ausarg/pipesnake)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8)](https://doi.org/10.5281/zenodo.XXXXXXX)


<img src="docs/images/pipesnake_Logo.png" width=50% height=50%>

**ausarg/pipesnake** is a bioinformatics best-practice analysis pipeline for phylogenomic reconstruction starting from short-read 'second-generation' sequencing data.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

<!-- TODO ausarg: Add full-sized test dataset and amend the paragraph below if applicable -->

&nbsp;
&nbsp;


# Wiki + Quick Start

All of `pipesnake`'s documentation is covered in this lovingly crafted [Wiki](https://github.com/AusARG/pipesnake/wiki). 

Antsy? Follow our [Quick Start](https://github.com/AusARG/pipesnake/wiki/2.-Quick-Start) guide to get up and running (slithering?).

&nbsp;
&nbsp;


# [Documentation](docs/) + Detailed Summary

`pipesnake` comes with documentation about the pipeline [usage](docs/usage.md), [parameters](docs/usage.md) and [output]().

A detailed summary of the workflow---including tools used---can be found in the [Wiki](https://github.com/AusARG/pipesnake/wiki/1.-Pipeline-Summary). 

&nbsp;
&nbsp; 


# Contributions + Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch. Having trouble? [Open an issue](https://github.com/AusARG/pipesnake/issues) or try [contacting us directly](mailto:ian.brennan@anu.edu.au).

&nbsp;
&nbsp;

# Citation

If you use `pipesnake`, please consider citing it and its depenedencies.

> *pipesnake: Generalized software for the assembly and analysis of phylogenomic datasets from conserved genomic loci*
>
> Name1, Name2, Name3
>
> A journal. Maybe bioRxiv.

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  ausarg/pipesnake for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

<!--

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).

-->
