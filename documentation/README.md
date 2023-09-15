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