# ausarg/pipesnake: Usage

## Introduction

To efficiently utilise and customise the workflow, we recommend the user to learn more about [Nextflow](https://www.nextflow.io/docs/latest/index.html) and [workflow configuration and parameter prioritisation](https://www.nextflow.io/docs/latest/config.html).

In general, most of the workflow parameters have default values to be used as is for most cases. These parameters are configured in the configuration file (`base.config`). All these parameters can be customised by either providing a new config file and passing it to the Nextflow running command using `-c` or `-config` (core nextflow parameter described below). The other way is to pass these parameters using two hyphens `--`. Details about workflow parameters and their default values are available below.

## Pipeline parameters

You can get the full ist of the pipeline parameters with their default values using the following command:

`nextflow run ausarg/pipesnake --help --show_hidden_params`


However, the popular parameters are described below and can be passed to the pipeline using two hyphens `--` followed by the parameter name and then its value.

e.g. `--input /scratch/testdata/sample_sheet.csv --disable_filter true`.

### Main options

| Parameter       | Type |  Description  |
|---------------|:---------------:|---------------------|
| --input  | string |   Path to comma-separated file containing information about the samples in the experiment.
| --outdir  | string |   The output directory where the results will be saved. <br/> You have to use absolute paths to storage on Cloud infrastructure. |
--disable_filter  | boolean | Default is `true`.<br />Disable bbmap filtration process. <br/>This speed up the performance. When enabled, the reference genome parameter is required. | 
|--reference_genome | string | Path to the filter sequences FASTA file.|
| --blat_db  | string | Path to the target sequences FASTA file.|
| --tree_method  | string | Default is `iqtree`.<br /> The supported options are: `iqtree` or `raxml`. | 
| --trim_alignment  | boolean | Default is `false`.<br />Trim initial MAFFT alignments. |
| --batching_size  | integer |  Default is `250`.<br /> Number of alignment files to be processed sequentially in batches <br/> to avoid submitting a large number of jobs when using HPCs. | 
| --trinity_scratch_tmp  | boolean |  Default is `true`.<br /> Trinity generates large number of intermediate files. <br/>This can be an issue for some HPCs that limits the file number for each user.<br/> This option will make trinity writes to the `/tmp` directory on the compute node <br/> then copy the compressed output directory (not the fasta) to the working directory to avoid this issue. |  


### Tools arguments for each stage of the pipeline
italic variables in the default values represent other parameters. 

| Parameter       | Type |  Description           |
|-----------------|------|------------------------|
|--phylogeny_make_alignments_minsamp|`integer`|Default is `4` <br/>Minimum number of samples to constitute an alignment Some phylogeny building methods rely on a minimum number of samples in an alignment. To estimate bootstraps for a genetree or include a genetree in an ASTRAL analysis, the minimum number of samples is 4. Suggested Usage: 4|
|--phylogeny_make_alignments_args|`string`|Default is `--minsamp `*`phylogeny_make_alignments_minsamp`* <br/>The arguments to be passed to process (phylogeny_make_alignments). The value 4 is taken from the parameter |
|--trinity_postprocessing_args|`string`|Default is `None` <br/> |
|--trimmomatic_clean_pe_args|`string`|Default is `-phred33 LEADING` <br/>The arguments to be passed to process (trimmomatic_clean_pe). |
|--trimmomatic_clean_se_args|`string`|Default is `-phred33 LEADING` <br/>The arguments to be passed to process (trimmomatic_clean_se). |
|--prepare_samplesheet_args|`string`|The arguments to be passed to process (prepare_samplesheet). |
|--blat_parser_evalue|`number`|Default is `1e-10` <br/>the E-value score for filtering BLAT hits E-value scores designate the number of expected hits as a result of chance. Simply put, the lower the score, the fewer (but better) the matches. [See here](https://www.metagenomics.wiki/tools/blast/evalue) for a detailed explanation.|
|--blat_parser_match|`integer`|Default is `80` <br/> |
|--parse_blat_results_args|`string`|Default is `--evalue `*`blat_parser_evalue `*  `--match `*`blat_parser_match`* <br/> The arguments to be passed to process (parse_blat_results).|
|--quality_2_assembly_args|`string`|The arguments to be passed to process (quality_2_assembly). |
|--samplesheet_check_args|`string`|The arguments to be passed to process (samplesheet_check). |
|--prepare_adaptor_args|`string`|The arguments to be passed to process (prepare_adaptor). |
|--bbmap_reformat_minconsecutivebases|`number`|Default is `100.0` <br/> |
|--bbmap_reformat_dotdashxton|`boolean`|Default is `True` <br/> |
|--bbmap_reformat_fastawrap|`number`|Default is `32000.0` <br/> |
|--bbmap_reformat_args|`string`|The arguments to be passed to process (bbmap_reformat). |
|--bbmap_reformat2_args|`string`|Default is `minconsecutivebases=`*`bbmap_reformat_minconsecutivebases`* `dotdashxton=`*`bbmap_reformat_dotdashxton`* `fastawrap=`*`bbmap_reformat_fastawrap`* <br/>The arguments to be passed to process (bbmap_reformat2).|
|--convert_phyml_args|`string`|The arguments to be passed to process (convert_phyml). |
|--preprocessing_args|`string`|Default is `None` <br/> |
|--bbmap_dedupe_args|`string`|Default is `None` <br/> |
|--bbmap_filter_minid|`number`|Default is `0.75` <br/>Minimum identity to reference sequence to retain a read Discards reads that do not map to a reference target with at least the indicated identity score. This was designed to quickly filter off-target reads such as mtDNA. Suggested Usage: 0.75. It's important to note that application of the minid is more complicated than it looks. BBMAP also has an idfilter=X option which is more literal. Read the [BBMAP documentation](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/) and [this forum response by Brian Bushnell](https://www.biostars.org/p/376782/) for more nuance.|
|--bbmap_filter_mem|`integer`|Default is `2` <br/>Specify memory use for mapping/filtering (Gb) |
|--bbmap_filter_args|`string`|Default is `minid=0.75` <br/>The arguments to be passed to process (bbmap_filter). `*`bbmap_filter_minid`*|
|--perl_cleanup_args|`string`|Default is `-pi -w -e "s/!/N/g;"` <br/>The arguments to be passed to process (perl_cleanup). |
|--concatenate_args|`string`|The arguments to be passed to process (concatenate). |
|--merge_trees_args|`string`|The arguments to be passed to process (merge_trees). |
|--trimmomatic_clean_minlength|`integer`|Default is `36` <br/>Minimum read length to be retained after trimming Discard reads shorter than this minimum threshold after adaptor/barcode trimming. Suggested Usage: 36|
|--trimmomatic_clean_trail|`integer`|Default is `3` <br/>Remove trailing bases below indicated quality Discard trailing bases below this minimum quality threshold. Suggested Usage: 3|
|--trimmomatic_clean_head|`integer`|Default is `3` <br/>Remove leading bases below indicated quality Discard leading bases below this minimum quality threshold.  Suggested Usage: 3|
|--trimmomatic_clean_qual|`integer`|Default is `15` <br/>Minimum quality score of 4-base sliding window Cut the read when the 4-base sliding window quality score drops below this threshold.  Suggested Usage: 15|
|--trimmomatic_args|`string`|Default is `-phred33` <br/>The arguments to be passed to process (trimmomatic). |
|--make_rgb_kept_tags|`string`|Default is `easy_recip_match,complicated_recip_match` <br/> |
|--make_prg_args|`string`|Default is `--kept-tags` *`make_rgb_kept_tags`*  <br/> The arguments to be passed to process (make_prg). |
|--gblocks_b1|`number`|Default is `0.5` <br/>Minimum number of sequences to be identified as a conserved site This establishes the minimum threshold for identifying a conserved site. The value must be greater than half the number of sequences, e.g. min value is 0.5 and we'll round that up|
|--gblocks_b2|`number`|Default is `0.85` <br/>Minimum number of sequences to be identified as a flanking site Flanking sites are assessed until they make a series of conserved positions at both flanks relative to the contiguous nonconserved sites. This value must be equal to or greater than the value of b1|
|--gblocks_b3|`integer`|Default is `8` <br/>Maximum number of contiguous nonconserved sites allowed Stretches of contiguous nonconserved sites greater than b3 are rejected. Greater b3 values increase the selected number of positions|
|--gblocks_b4|`number`|Default is `10` <br/>Minimum length of a sequence block after gap cleaning After gap cleaning, sequence blocks less than the indicated value are rejected|
|--gblocks_args|`string`|Default is `-t=DNA` <br /> `-b3=`*`gblocks_b3`* <br /> `-b4=`*`gblocks_b4`* <br /> `-b5=h -p=n` <br/> The arguments to be passed to process (gblocks). |
|--testing_args|`string`|Default is `None` <br/> |
|--trinity_normalize_reads|`boolean`|Default is `False` <br/>Normalize the read pool, discarding excess coverage Depending on the sequencing effort, there may be excess reads (above desired coverage) that will slow down computation by requiring additional memory. New versions of trinity normalize reads do this by default, and it's highly recommended here.|
|--trinity_processed_header|`string`|Default is `contig` <br/>Prefix for a contig of assembled reads Naming convention for assembled contigs. Suggested Usage: contig|
|--trinity_args|`string`|Default is `--seqType fq --NO_SEQTK` <br/>The arguments to be passed to process (trinity). [check the wiki](https://github.com/trinityrnaseq/trinityrnaseq/wiki)|
|--iqtree_args|`string`|Default is `--quiet -B 1000` <br/>The arguments to be passed to process (iqtree). |
|--aster_args|`string`|The arguments to be passed to process (aster). |
|--macse_stop|`number`|Default is `10.0` <br/> |
|--macse_program|`string`|Default is `refineLemmon` <br/> |
|--macse_refine_alignment_optim|`number`|Default is `1.0` <br/> |
|--macse_refine_alignment_local_realign_init|`number`|Default is `0.1` <br/> |
|--macse_refine_alignment_local_realign_dec|`number`|Default is `0.1` <br/> |
|--macse_refine_alignment_fs|`number`|Default is `10.0` <br/> |
|--macse_args_refine|`string`|Default is `-stop `*`macse_stop`* <br /> `-prog refineAlignment` <br/>The arguments to be passed to process (macse). |
|--macse_args_export|`string`|Default is `-prog exportAlignment` <br /> `-stop `*`macse_stop`*` <br/>The arguments to be passed to process (macse). |
|--macse_args_align|`string`|Default is `-prog alignSequences` <br /> `-stop_lr `*`macse_stop`*` <br/>The arguments to be passed to process (macse). |
|--macse_args_refineLemmon|`string`|Default is `-prog refineAlignment` `-optim `*`macse_refine_alignment_optim`* ` -local_realign_init `*`macse_refine_alignment_local_realign_init`* `-local_realign_dec `*`macse_refine_alignment_local_realign_dec`* `-fs `*`macse_refine_alignment_fs`* <br />The arguments to be passed to process (macse). |
|--mafft_maxiterate|`integer`|Default is `1000` <br/>Number of cycles of iterative refinement Iterative refinement helps to improve the alignment process, at the cost of additional time. 1000 iterations is sufficient for most exercises|
|--mafft_args|`string`|Default is `--maxiterate `*`mafft_maxiterate`* <br /> `--globalpair` <br /> `--adjustdirection` <br /> `--quiet ` <br/>The arguments to be passed to process (mafft). |
|--raxml_runs|`integer`|Default is `100` <br/> |
|--raxml_args|`string`|Default is `-m GTRCAT -f a -n` <br/>The arguments to be passed to process (raxml). |
|--blat_parser_match|`number`|Default is `80.0` <br/>Minimum required percent (0-100) match between contig and target Discards contig-to-target matches below minimum threshold provided. Values closer to 100 require greater similarity. Suggested Usage: 80|
|--blat_parser_evalue|`number`|Default is `1e-10` <br/>Minimum required e-value for match between contig and target Discards contig-to-target matches greater than threshold provided. Values closer to 0 (smaller) require greater similarity. Suggested Usage: 1e-10|
|--blat_args|`string`|Default is `-out=blast8` <br/>The arguments to be passed to process (blat). |
|--pear_args|`string`|The arguments to be passed to process (pear). |
|--sed_args|`string`|The arguments to be passed to process (sed). |


### Resources for each stage of the pipeline

You can customise the resources requested for each stage of the pipeline including `cpus`, `memory`, and `walltime` using the following parameters: *`process-name`*`_cpus`, *`process-name`*`_cpus`, and *`process-name`*`_walltime`, respectively.

*`process-name`* can be any one of the following processes:

`perl_cleanup`, `phylogeny_make_alignments`, `preprocessing`, `trimmomatic_clean_pe`, `trinity_postprocessing`, `blat`, `bbmap_reformat`, `gblocks`, `parse_blat_results`, `aster`, `bbmap_reformat2`, `convert_phyml`, `trimmomatic`, `iqtree`, `concatenate`, `trinity`, `saved_output`, `bbmap_filter`, `bbmap_dedupe`, `prepare_adaptor`, `mafft`, `sed`, `pear`, `merge_trees`, `raxml`, `trimmomatic_clean_se`, `make_prg`, `macse`, `quality_2_assembly`


Examples:

`--perl_cleanup_cpus 4 --blat_memory 8.GB --mafft_walltime 9.h`



## Running the pipeline

The typical command for running the pipeline is as follows:

```console
nextflow run ausarg/pipesnake --input samplesheet.csv --outdir <OUTDIR> -profile docker
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```console
work                # Directory containing the nextflow working files
<OUTIDR>            # Finished results in the specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```console
nextflow run ausarg/pipesnake
```

### Reproducibility

It is a good idea to specify a pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [ausarg/pipesnake releases page](https://github.com/ausarg/pipesnake/releases) and find the latest version number - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future.



## Core Nextflow arguments

> **NB:** These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen).

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Conda) - see below. When using Biocontainers, most of these software packaging methods pull Docker containers from quay.io e.g [FastQC](https://quay.io/repository/biocontainers/fastqc) except for Singularity which directly downloads Singularity images via https hosted by the [Galaxy project](https://depot.galaxyproject.org/singularity/) and Conda which downloads and installs software locally from [Bioconda](https://bioconda.github.io/).

> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to see if your system is available in these configs please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended.

- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter or Charliecloud.
- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

### `-work-dir`

Specify the path to your preferred working directory, instead of your current working directory. 

## Custom configuration

### Updating containers

The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. If for some reason you need to use a different version of a particular tool with the pipeline then you just need to identify the `process` name and override the Nextflow `container` definition for that process using the `withName` declaration. For example, in the [nf-core/viralrecon](https://nf-co.re/viralrecon) pipeline a tool called [Pangolin](https://github.com/cov-lineages/pangolin) has been used during the COVID-19 pandemic to assign lineages to SARS-CoV-2 genome sequenced samples. Given that the lineage assignments change quite frequently it doesn't make sense to re-release the nf-core/viralrecon everytime a new version of Pangolin has been released. However, you can override the default container used by the pipeline by creating a custom config file and passing it as a command-line argument via `-c custom.config`.

1. Check the default version used by the pipeline in the module file for [Pangolin](https://github.com/nf-core/viralrecon/blob/a85d5969f9025409e3618d6c280ef15ce417df65/modules/nf-core/software/pangolin/main.nf#L14-L19)
2. Find the latest version of the Biocontainer available on [Quay.io](https://quay.io/repository/biocontainers/pangolin?tag=latest&tab=tags)
3. Create the custom config accordingly:

   - For Docker:

     ```nextflow
     process {
         withName: PANGOLIN {
             container = 'quay.io/biocontainers/pangolin:3.0.5--pyhdfd78af_0'
         }
     }
     ```

   - For Singularity:

     ```nextflow
     process {
         withName: PANGOLIN {
             container = 'https://depot.galaxyproject.org/singularity/pangolin:3.0.5--pyhdfd78af_0'
         }
     }
     ```

   - For Conda:

     ```nextflow
     process {
         withName: PANGOLIN {
             conda = 'bioconda::pangolin=3.0.5'
         }
     }
     ```

> **NB:** If you wish to periodically update individual tool-specific results (e.g. Pangolin) generated by the pipeline then you must ensure to keep the `work/` directory otherwise the `-resume` ability of the pipeline will be compromised and it will restart from scratch.

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```console
NXF_OPTS='-Xms1g -Xmx4g'
```

