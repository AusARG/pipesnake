# ausarg/pipesnake: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.2

- [ ] replaced deduplication software. We switched from using BBMAP's `dedupe.sh` to `clumpify.sh` as it's more appropriate for processing raw reads. dedupe.sh is really preferable for deduplicating contigs. See explanation of `clumpify` and usage [here](https://www.biostars.org/p/225338/). 

- [ ] replaced `test/example` data. Original example data were 4 samples from the same species. This caused an error when there was alignment trimming that resulted in identical sequences. Having 4 identical sequences passes our minimum sample check (`minsamp=4`) but IQTREE handles identical sequences by removing them from the analysis and adding them back at the end. This caused an error in IQTREE (not enough samples to estimate a tree). To avoid this issue we replaced 3 of 4 samples with new data, so this should no longer occur with `test/example` data. While it's conceivable that this issue could still arise for users who are exclusively working within a single species or with highly conserved target sequences, it's unlikely, and can be avoided by using RAxML to generate genetrees instead. We have added a note to the [`wiki/FAQ'](https://github.com/AusARG/pipesnake/wiki/8.-FAQ) to this effect.

- [ ] quick run `test` from `--stage from_prg`: We have added example PRG data files and a new sample info file to run the test data from the PRG stage (omitting read assembly et al.). This allows users to get the idea of running from the middle of the pipeline, and how it might be useful for combining projects. We have added a note to the [`wiki/Quick Start`](https://github.com/AusARG/pipesnake/wiki/2.-Quick-Start). 

## v1.0dev - [date]

Initial release of ausarg/pipesnake, created with the [nf-core](https://nf-co.re/) template.

### `Added`

### `Fixed`

### `Dependencies`

### `Deprecated`
