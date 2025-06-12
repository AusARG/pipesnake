/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowPipesnake.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.filter, params.blat_db ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
//if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { BBMAP_DEDUPE } from '../modules/local/bbmap_dedupe'
include { PREPARE_ADAPTOR } from '../modules/local/prepare_adaptor'

include { TRIMMOMATIC } from '../modules/local/trimmomatic'
include { PEAR } from '../modules/local/pear'
include { CONCATENATE } from '../modules/local/concatenate'
include { CONCATENATE_RAW } from '../modules/local/concatenate_raw'
include { CONCATENATE as CONCATENATE2 } from '../modules/local/concatenate'
include { CONCATENATE as CONCATENATE3 } from '../modules/local/concatenate'
include {TRIMMOMATIC_CLEAN_PE} from '../modules/local/trimmomatic_clean_pe'
include {TRIMMOMATIC_CLEAN_SE} from '../modules/local/trimmomatic_clean_se'

include {BBMAP_FILTER} from '../modules/local/bbmap_filter'
include {TRINITY} from '../modules/local/trinity'
include {ASSEMBLY_POSTPROCESSING} from '../modules/local/assembly_postprocessing'
include {BLAT} from '../modules/local/blat'
include {BLAT as BLAT2} from '../modules/local/blat'
include {PARSE_BLAT_RESULTS} from '../modules/local/parse_blat_results'
include {SEGUL} from '../modules/local/segul'
include {SEGUL as SEGUL2} from '../modules/local/segul'
include {COMBINE_ALIGN_SUMMARY} from '../modules/local/combine_align_summary'
include {MAFFT} from '../modules/local/mafft'
include {PERL_CLEANUP} from '../modules/local/perl_cleanup'

include {MAKE_PRG} from '../modules/local/make_prg'
include {QUALITY_2_ASSEMBLY} from '../modules/local/quality_2_assembly'
include {PHYLOGENY_MAKE_ALIGNMENTS} from '../modules/local/phylogeny_make_alignments'
include { GBLOCKS } from '../modules/local/gblocks'
include { CLIPKIT } from '../modules/local/clipkit'
include { TRIMAL } from '../modules/local/trimal'

//include { CONVERT_PHYML } from '../modules/local/convert_phyml'
include { RAXML } from '../modules/local/raxml'
include { IQTREE } from '../modules/local/iqtree'
include { SED } from '../modules/local/sed'
include { BBMAP_REFORMAT } from '../modules/local/bbmap_reformat.nf'
include { MERGE_TREES } from '../modules/local/merge_trees.nf'
include { ASTER } from '../modules/local/aster.nf'
include { SPADES } from '../modules/local/spades.nf'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBPROCESSES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow TO_PRG {
take:
    ch_versions

main:
    // Parse input file
    def lineange_indx = params.disable_adapter_trimming ? 3 : 7
    Channel
        .fromPath(params.input, checkIfExists:true)
        .splitCsv(header:true, strip:true)
        .map {row ->
            if (params.disable_adapter_trimming){
                tuple(
                    row.sample_id,
                    file(row.read1, checkIfExists: true),
                    file(row.read2, checkIfExists: true),
                    row.lineage
                )
            }
            else{
                tuple(
                    row.sample_id,
                    file(row.read1, checkIfExists: true),
                    file(row.read2, checkIfExists: true),
                    row.adaptor1, row.adaptor2, row.barcode1, row.barcode2, row.lineage
                )
            }
        }
        .set{ch_sample_sheet_raw}


    // Check if lineages for a sample is unique and all lineages corresponding to different samples are different
    ch_sample_sheet_raw
        .groupTuple()
        .map{
            if (it[lineange_indx].unique().size() != 1){
                    exit 1, "Lineage for sample ${it[0]} should be unique across all records for this sample!"
            }
            it[lineange_indx][0]
        }
        .toList()
        .subscribe{
            if (it.toSet().size() != it.size()){
                exit 1, "Looks like the sample sheet has duplicate lineages, Lineage column should be unique!"
            }
        }

    // Check if adaptor and barcode for each sample is unique and map to lists
    ch_sample_sheet_raw.groupTuple().map{
            if (!params.disable_adapter_trimming){
                if (it[3].unique().size() != 1){
                    exit 1, "Adaptor1 for the sample ${it[0]} should be unique across all records for this sample!"
                }
                if (it[4].unique().size() != 1){
                    exit 1, "Adaptor2 for the sample ${it[0]} should be unique across all records for this sample!"
                }
                if (it[5].unique().size() != 1){
                    exit 1, "barcode1 for the sample ${it[0]} should be unique across all records for this sample!"
                }
                if (it[6].unique().size() != 1){
                    exit 1, "barcode2 for the sample ${it[0]} should be unique across all records for this sample!"
                }
                [it[0], it[1], it[2], it[3][0], it[4][0], it[5][0], it[6][0], it[7][0]]
            }else{
                [it[0], it[1], it[2], it[3][0]]
            }

        }.branch{
            singles: it[1].size() == 1
            multiples: it[1].size() > 1
        }.set{
            ch_sample_sheet_prepared
        }

    // Create channel of sample and lineage
    ch_sample_sheet_raw
        .groupTuple()
        .map{[it[0], it[lineange_indx][0]]}
        .set{ch_lineage}

    // Prepare simple and  multiple samples and merge
    ch_sample_sheet_prepared.singles
        .map{it -> [it[0], [it[1][0], it[2][0]]]}
        .set{ch_prepared_fastq_singles}

    CONCATENATE_RAW(
        ch_sample_sheet_prepared.multiples
            .map{it -> [it[0], it[1], it[2]]},
        Channel.value("concatenated")
    )

    ch_prepared_fastq_singles
        .mix(CONCATENATE_RAW.out.concatenated
            .map{[it[0], [it[1], it[2]]]})
        .set{ch_prepared_fastq}

    // Read filter file if filtering enabled
    if (params.filter){
        Channel.fromPath(params.filter, checkIfExists:true)
            .collect()
            .set{ch_filter}
    }else{
        Channel.empty().set{ch_filter}
    }

    // Read blat db
    Channel
        .fromPath(params.blat_db, checkIfExists:true)
        .collect()
        .set{ch_blat_db}

    // Deduplicate reads
    BBMAP_DEDUPE( ch_prepared_fastq )
        .deduplicates
        .set{ reformated_ch }

    // Perform adapter trimming if enabled
    if (!params.disable_adapter_trimming){
        ch_sample_sheet_prepared.singles
            .mix(ch_sample_sheet_prepared.multiples)
            .map{it -> [it[0], [it[3], it[4], it[5], it[6]]]}.set{ch_meta}

        PREPARE_ADAPTOR(
            ch_meta.map{
                [it[0], it[1][0], it[1][1], it[1][2], it[1][3]]
            }.toList()
        ).adaptor
            .flatten()
            .map{[it.getSimpleName(), it]}
            .set{ adaptor_ch }

        TRIMMOMATIC(
            reformated_ch.join( adaptor_ch )
        )
        TRIMMOMATIC.out.trimmed_paired.set{pear_input_ch}

        ch_versions = ch_versions.mix(PREPARE_ADAPTOR.out.versions)
        ch_versions = ch_versions.mix(TRIMMOMATIC.out.versions)
    }else{
        reformated_ch.set{pear_input_ch}
    }

    // Merge reads
    PEAR(
       pear_input_ch
    ).merged.set{ merged_ch }

    // Clean merged reads
    TRIMMOMATIC_CLEAN_PE(
        PEAR.out.unmerged
    ).trimmed_cleaned_paired.set{ prepared_fastq }

    // Filter reads if enabled
    if (params.filter){
        BBMAP_FILTER(
            TRIMMOMATIC_CLEAN_PE.out.trimmed_cleaned_paired,
            ch_filter
        )

        ch_versions = ch_versions.mix(BBMAP_FILTER.out.versions)
        ch_prepared_reads = BBMAP_FILTER.out.prepared_reads

    }else{
        ch_prepared_reads = TRIMMOMATIC_CLEAN_PE.out.trimmed_cleaned_paired
    }

    // Assemble reads using SPAdes or Trinity
    if (params.assembly == "SPAdes"){
        SPADES(
            ch_prepared_reads
        )

        ch_versions = ch_versions.mix(SPADES.out.versions)
        ch_assembly_out = SPADES.out.contigs
    } else {
        if (!params.disable_adapter_trimming) {
            CONCATENATE(
                TRIMMOMATIC.out.trimmed_unpaired
                    .join(merged_ch)
                    .map{ it -> [it[0], [it[1], it[2], it[3]]] }
                , Channel.value("trimmed_unpaired_concatenated")
            ).concatenated.set{ unpaired_concatenated_ch }

            TRIMMOMATIC_CLEAN_SE(
                unpaired_concatenated_ch
            )

            CONCATENATE2(
                TRIMMOMATIC_CLEAN_PE.out.trimmed_cleaned_unpaired
                    .join( TRIMMOMATIC_CLEAN_SE
                        .out
                        .trimmed_cleaned_se
                    )
                    .map{ it -> [it[0], [it[1], it[2], it[3]]]}
                , Channel.value("trimmed_unpaired_pe_seconcatenated")
            )
            CONCATENATE3(
                ch_prepared_reads
                    .join(CONCATENATE2.out.concatenated)
                    .map{ it -> [it[0], [it[1], it[3]]] }
                , Channel.value("trinity_r1_unpaired_concatenated")
            )
            ch_prepared_reads
                .join(CONCATENATE3.out.concatenated)
                .map{ it -> [it[0], it[3], it[2]] }
                .set{trinity_input_ch}

            ch_versions = ch_versions.mix(CONCATENATE2.out.versions)
            ch_versions = ch_versions.mix(CONCATENATE3.out.versions)
            ch_versions = ch_versions.mix(CONCATENATE.out.versions)
            ch_versions = ch_versions.mix( TRIMMOMATIC_CLEAN_SE.out.versions)
        }else{
            ch_prepared_reads.set{trinity_input_ch}
        }

        TRINITY(
            trinity_input_ch
        )

        ch_assembly_out = TRINITY.out.trinity_fasta
        ch_versions = ch_versions.mix(TRINITY.out.versions)
    }

    // Perform assembly posprocessing
    ASSEMBLY_POSTPROCESSING(
        ch_assembly_out
    )

    BLAT(
        ASSEMBLY_POSTPROCESSING.out.processed,
        ch_blat_db,
        Channel.value("to_probes"),
        Channel.value(false)
    )

    BLAT2(
        ASSEMBLY_POSTPROCESSING.out.processed,
        ch_blat_db,
        Channel.value("from_probes"),
        Channel.value(true)
    )

    // Parse blat results
    PARSE_BLAT_RESULTS(
        ASSEMBLY_POSTPROCESSING.out.processed
            .join(BLAT.out.matches)
            .join(BLAT2.out.matches)
    )

    // Construct PRG from the assembly
    MAKE_PRG(
        ASSEMBLY_POSTPROCESSING.out.processed
            .join(PARSE_BLAT_RESULTS.out.matches)
            .join(ch_lineage)
    ).RGB.set{ch_prg_out}

    // Find the quality of the assembly
    QUALITY_2_ASSEMBLY(
        ASSEMBLY_POSTPROCESSING.out.processed
            .join(ch_prg_out)
            .join(ch_lineage)
    )

    // Log software versions used
    ch_versions = ch_versions.mix(BBMAP_DEDUPE.out.versions)
    ch_versions = ch_versions.mix(PEAR.out.versions)
    ch_versions = ch_versions.mix(CONCATENATE_RAW.out.versions)
    ch_versions = ch_versions.mix(TRIMMOMATIC_CLEAN_PE.out.versions)
    ch_versions = ch_versions.mix(ASSEMBLY_POSTPROCESSING.out.versions)
    ch_versions = ch_versions.mix(BLAT.out.versions)
    ch_versions = ch_versions.mix(BLAT2.out.versions)
    ch_versions = ch_versions.mix(PARSE_BLAT_RESULTS.out.versions)
    ch_versions = ch_versions.mix(QUALITY_2_ASSEMBLY.out.versions)
    ch_versions = ch_versions.mix(MAKE_PRG.out.versions)

emit:
    ch_versions = ch_versions
    ch_prg_out = ch_prg_out
}

workflow ALIGNMENT {
take:
    ch_versions
    ch_prg_out

main:
    // Create fasta file for alignment
    PHYLOGENY_MAKE_ALIGNMENTS(
        ch_prg_out.map(it -> it[1]).toSortedList()
    )

    // Perform alignment using MAFFT
    MAFFT(
        PHYLOGENY_MAKE_ALIGNMENTS.out.locus_fasta
            .toSortedList()
            .flatten()
            .buffer(
                size: params.batching_size,
                remainder: true
            )
    )
    ch_versions = ch_versions.mix(MAFFT.out.versions)

    // Get alignment summary (pre-trimming)
    SEGUL(
        MAFFT.out.aligned
            .flatten()
            .toList(),
        'pre_trim'
    )

    // Perform alignment trimming if enabled
    def trimmer_map = [
        gblocks: { input -> GBLOCKS(input) },
        clipkit: { input -> CLIPKIT(input) },
        trimal: { input -> TRIMAL(input) }
    ]

    ch_trim_out = trimmer_map.get(
        params.trim_method.toLowerCase()
    )?.call(
        MAFFT.out.aligned.map {if (params.batching_size == 1) [it] else it}
    ) ?: [
        trimmed_allignments: MAFFT.out.aligned,
        versions: Channel.empty()
    ]
    ch_versions = ch_versions.mix(ch_trim_out.versions)

    // Remove specific characters from the alignment
    SED(
        ch_trim_out.trimmed_allignments
            .map{if (params.batching_size == 1) [it] else it}
    )

    // Covert format of sed output file
    BBMAP_REFORMAT(
        SED.out.seded
            .map{if (params.batching_size == 1) [it] else it}
    ).reformated.set{ ch_alignment }

    // Get alignment summary (post-trimming)
    SEGUL2(
        BBMAP_REFORMAT.out.reformated
            .flatten()
            .toList(),
        'post_trim'
    )

    // Combine the results of alignment summary before and after trimming
    COMBINE_ALIGN_SUMMARY(
        SEGUL.out.locus_summary,
        SEGUL2.out.locus_summary
    )

    // Log software versions
    ch_versions = ch_versions.mix(PHYLOGENY_MAKE_ALIGNMENTS.out.versions)
    ch_versions = ch_versions.mix(SED.out.versions)
    ch_versions = ch_versions.mix(SEGUL.out.versions)
    ch_versions = ch_versions.mix(COMBINE_ALIGN_SUMMARY.out.versions)
    ch_versions = ch_versions.mix(BBMAP_REFORMAT.out.versions)

emit:
    ch_versions = ch_versions
    ch_alignment = ch_alignment
}

workflow FROM_PRG {
take:
    ch_versions
    ch_alignment

main:
    // Construct phylogenetic tree
    if (params.tree_method == 'raxml'){
        RAXML(
            ch_alignment
                .map{if (params.batching_size == 1) [it] else it}
        )
        ch_all_trees = RAXML.out.tree_bipartitions
            .flatten()
            .toSortedList()

        ch_versions = ch_versions.mix(RAXML.out.versions)
    } else if (params.tree_method == 'iqtree'){
        IQTREE(
            ch_alignment
                .map{if (params.batching_size == 1) [it] else it}
        )
        ch_all_trees = IQTREE.out.contree
            .flatten()
            .toSortedList()

        ch_versions = ch_versions.mix(IQTREE.out.versions)
    }

    // Merge trees
    MERGE_TREES(
        ch_all_trees
    )

    // Estimate species tree using aster
    if (!params.no_tree_merge){
        ASTER(
            MERGE_TREES.out.merged_trees
        )
        ch_versions = ch_versions.mix(ASTER.out.versions)
    }

    // Log software versions
    ch_versions = ch_versions.mix(MERGE_TREES.out.versions)

emit:
    ch_versions = ch_versions
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary

workflow PIPESNAKE {
    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //

    ch_versions = Channel.empty()

    if (params.stage.toLowerCase() == "from-prg"){
         Channel
            .fromPath(params.input, checkIfExists:true)
            .splitCsv(header:true, strip:true)
            .map {
                row -> tuple(
                    row.sample_id,
                    file(row.prg_file, checkIfExists: true)
                )
            }
            .set{ch_prg_out}
    }
    else if (params.stage.toLowerCase() != "from-alignment") {
        TO_PRG(ch_versions)
        TO_PRG.out.ch_versions.set{ ch_versions }
        TO_PRG.out.ch_prg_out.set{ ch_prg_out }
    }

    if (params.stage == "end-prg") {
        exit 0
    }

    if (params.stage.toLowerCase() == "from-alignment") {
         Channel
            .fromPath(params.input, checkIfExists:true)
            .splitCsv(header:true, strip:true)
            .map {
                row -> file(row.alignment_file, checkIfExists: true)
            }
            .buffer(
                size: params.batching_size,
                remainder: true
            )
            .set{ch_alignment}
    }
    else {
        ALIGNMENT(ch_versions, ch_prg_out)
        ALIGNMENT.out.ch_versions.set{ ch_versions }
        ALIGNMENT.out.ch_alignment.set{ ch_alignment }
    }

    if (params.stage.toLowerCase() != "end-alignment") {
        FROM_PRG(ch_versions, ch_alignment)
        FROM_PRG.out.ch_versions.set{ ch_versions }
    }

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions
            .unique()
            .collectFile(name: 'collated_versions.yml')
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    // Send summary email once workflow is complete
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
