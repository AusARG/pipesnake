# Example Data

## Contents

Unzip the `data.zip` file to acess the directory. Files contained in the `pipesnake/example/data` directory are as follows:

+ *ToyData_Sample...fastq*: raw short-read files for four samples. One forward (R1) and one reverse (R2) read file per sample. These read files have been downsampled considerably so that they can run as a quick example.

+ *ToyData_SampleInfo.csv*: sample info file for the `--input` command. It's ***essential*** that you adjust the paths to the raw read files before running this example dataset. 

+ *ToyData_SqCL_Filter.fasta*: target sequences from phylogenetically near (same family) relatives to the ToyData samples. This fasta file can be used for the read filtering step: `--fasta` command.

+ *ToyData_SqCL_25Targets.fasta*: 25 target sequences to assemble/match from the example data. This fasta file accompanies the `---blat-db` command and is used in the BLAT steps. 

---

## Running the Example

To run the example data 
1. follow the nextflow and pipesnake installation instructions in the [Quick-Start guide](https://github.com/AusARG/pipesnake/wiki/2.-Quick-Start)
2. unzip the `data.zip` directory and make sure to change file paths in the *ToyData_SampleInfo.csv* file to direct to the read files.
3. run the example analysis with read filtering:
```
nextflow run ausarg/pipesnake --input pipesnake/example/data/ToyData_SampleInfo.csv --outdir [out_directory] --blat_db pipesnake/example/data/ToyData_SqCL_25Targets.fasta --fasta pipesnake/example/data/ToyData_SqCL_Filter.fasta -profile [docker/singularity/conda choose accordingly]
```
4. or run the example analysis without read filtering:
```
nextflow run ausarg/pipesnake --input pipesnake/example/data/ToyData_SampleInfo.csv --outdir [out_directory] --blat_db pipesnake/example/data/ToyData_SqCL_25Targets.fasta -profile [docker/singularity/conda choose accordingly]
```