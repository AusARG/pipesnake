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
