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

include { BBMAP_REFORMAT } from '../modules/local/bbmap_reformat'
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
include {MAFFT} from '../modules/local/mafft'
include {PERL_CLEANUP} from '../modules/local/perl_cleanup'

include {MAKE_PRG} from '../modules/local/make_prg'
include {QUALITY_2_ASSEMBLY} from '../modules/local/quality_2_assembly'
include {PHYLOGENY_MAKE_ALIGNMENTS} from '../modules/local/phylogeny_make_alignments'
include { GBLOCKS } from '../modules/local/gblocks'

//include { CONVERT_PHYML } from '../modules/local/convert_phyml'
include { RAXML } from '../modules/local/raxml'
include { IQTREE } from '../modules/local/iqtree'
include { SED } from '../modules/local/sed'
include { BBMAP_REFORMAT2 } from '../modules/local/bbmap_reformat2.nf'
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
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary

workflow PIPESNAKE {

    ch_versions = Channel.empty()
    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    


    Channel
        .fromPath(params.input, checkIfExists:true)
        .splitCsv(header:true, strip:true)
        .map {row -> tuple(
                row.sample_id, row.read1, row.read2, 
                row.adaptor1, row.adaptor2, row.barcode1, row.barcode2, row.lineage
                ) 
             }
        .set{ch_sample_sheet_raw}

    //ch_sample_sheet.map{it -> [it[0], [it[1][0], it[1][1], it[1][2], it[1][3]]]}.set{ch_meta}
    //ch_sample_sheet.map{it -> [it[0], it[1][4]]}.set{ch_lineage}
    //ch_sample_sheet.view()
    //ch_sample_sheet_raw.view()

    
    ch_sample_sheet_raw.groupTuple().map{
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
    }.branch{
        singles: it[1].size() == 1
        multiples: it[1].size() > 1
    }.set{
        ch_sample_sheet_prepared
    }

    ch_sample_sheet_prepared.singles
    .mix(ch_sample_sheet_prepared.multiples)
    .map{[it[0], it[7]]}.set{ch_lineage}
    
    ch_sample_sheet_prepared.singles
    .mix(ch_sample_sheet_prepared.multiples)
    .map{it -> [it[0], [it[3], it[4], it[5], it[6]]]}.set{ch_meta}
    

    ch_sample_sheet_prepared.singles
    .map{it -> [it[0], [it[1][0], it[2][0]]]}
    .set{ch_prepared_fastq_singles}

    CONCATENATE_RAW(
        ch_sample_sheet_prepared.multiples
        .map{it -> [it[0], it[1], it[2]]}
        , Channel.value("concatenated")
    )

    ch_prepared_fastq_singles
    .mix(CONCATENATE_RAW.out.concatenated
            .map{[it[0], [it[1], it[2]]]}
    )
    .set{ch_prepared_fastq}
    
    if (params.filter){
        Channel
        .fromPath(params.filter, checkIfExists:true)
        .collect()
        .set{ch_filter}
    }else{
        Channel.empty().set{ch_filter}
    }

    Channel
        .fromPath(params.blat_db, checkIfExists:true)
        .collect()
        .set{ch_blat_db}

    //ch_meta.view()
    //println("dfdfdf");
    //ch_lineage.view()
    PREPARE_ADAPTOR( ch_meta )
    .adaptor
    .set{ adaptor_ch }


    BBMAP_DEDUPE( ch_prepared_fastq )
    .deduplicates
    .set{ deduplicates_ch }
    
    
    BBMAP_REFORMAT( deduplicates_ch )
    .reformated_fastq
    .set{ reformated_ch }
    
    TRIMMOMATIC( 
        reformated_ch.join( adaptor_ch ) 
    )

    PEAR(
        TRIMMOMATIC.out.trimmed_paired
    )
    .merged
    .set{ merged_ch }
    


    TRIMMOMATIC
            .out
            .trimmed_unpaired
            .join(merged_ch)
            .map{ it -> [it[0], [it[1], it[2], it[3]]] }

    CONCATENATE(
        TRIMMOMATIC
            .out
            .trimmed_unpaired
            .join(merged_ch)
            .map{ it -> [it[0], [it[1], it[2], it[3]]] }
        , Channel.value("trimmed_unpaired_concatenated")
    )
    .concatenated
    .set{ unpaired_concatenated_ch }

    TRIMMOMATIC_CLEAN_PE(
        PEAR.out.unmerged
    )
    .trimmed_cleaned_paired
    .set{ prepared_fastq }

    
    TRIMMOMATIC_CLEAN_SE(
        unpaired_concatenated_ch
    )

    

    if (params.filter){
        BBMAP_FILTER(
            TRIMMOMATIC_CLEAN_PE
            .out
            .trimmed_cleaned_paired
            , ch_filter
        )

        ch_versions = ch_versions.mix( BBMAP_FILTER.out.versions)
        ch_prepared_reads = BBMAP_FILTER
        .out
        .prepared_reads
        
    }else{
        ch_prepared_reads = TRIMMOMATIC_CLEAN_PE
            .out
            .trimmed_cleaned_paired
    }


    if (params.assembly == "SPAdes"){
        SPADES(
            ch_prepared_reads
        )

        ch_versions = ch_versions.mix(SPADES.out.versions)
        ch_assembly_out = SPADES
        .out
        .contigs
    } else {
        CONCATENATE2(
        TRIMMOMATIC_CLEAN_PE
        .out
        .trimmed_cleaned_unpaired
        .join( TRIMMOMATIC_CLEAN_SE
                .out
                .trimmed_cleaned_se
        )
        .map{ it -> [it[0], [it[1], it[2], it[3]]] }
        , Channel.value("trimmed_unpaired_pe_seconcatenated")
        )
        
        CONCATENATE3(
            ch_prepared_reads
            .join( CONCATENATE2
                    .out
                    .concatenated
            )
            .map{ it -> [it[0], [it[1], it[3]]] }
            , Channel.value("trinity_r1_unpaired_concatenated")
        )

        
        TRINITY(
            ch_prepared_reads
            .join( CONCATENATE3
                    .out
                    .concatenated
                )
            .map{ it -> [it[0], it[3], it[2]] }
        )

        ch_assembly_out = TRINITY
        .out
        .trinity_fasta
        
        ch_versions = ch_versions.mix(CONCATENATE2.out.versions)
        ch_versions = ch_versions.mix(CONCATENATE3.out.versions)
        ch_versions = ch_versions.mix(TRINITY.out.versions)
    }
    

    ASSEMBLY_POSTPROCESSING(
        ch_assembly_out
    )
    
    BLAT(
        ASSEMBLY_POSTPROCESSING
        .out
        .processed
        , ch_blat_db
        , Channel
        .value("to_probes")
        , Channel
        .value(false)
    )

    BLAT2(
        ASSEMBLY_POSTPROCESSING
        .out
        .processed
        , ch_blat_db
        , Channel
        .value("from_probes")
        , Channel
        .value(true)
    )
    
    
    PARSE_BLAT_RESULTS(
        ASSEMBLY_POSTPROCESSING
        .out
        .processed
        .join(BLAT.out.matches)
        .join(BLAT2.out.matches)
    )
    
    MAKE_PRG(
        ASSEMBLY_POSTPROCESSING
        .out
        .processed
        .join(
            PARSE_BLAT_RESULTS.out.matches
        )
        .join(ch_lineage)
    )

    QUALITY_2_ASSEMBLY(
        ASSEMBLY_POSTPROCESSING
        .out
        .processed
        .join(
            MAKE_PRG.out.RGB
        )
        .join(ch_lineage)
    )

    PHYLOGENY_MAKE_ALIGNMENTS(
        MAKE_PRG.out.RGB.map(it -> it[1]).toSortedList()
    )



    MAFFT(
        PHYLOGENY_MAKE_ALIGNMENTS
        .out
        .locus_fasta.toSortedList()
        .flatten().buffer(size: params.batching_size, remainder: true)
    )

    if (params.trim_alignment){
        GBLOCKS(
            MAFFT.out.aligned.map{if (params.batching_size == 1) [it] else it}
        )
        .trimmed_allignments
        .set{ch_alignment}
        
    ch_versions = ch_versions.mix(GBLOCKS.out.versions)
    } else{
        ch_alignment = MAFFT.out.aligned.map{if (params.batching_size == 1) [it] else it}
    }
    
    SED( ch_alignment.map{if (params.batching_size == 1) [it] else it} )

    BBMAP_REFORMAT2(SED.out.seded.map{if (params.batching_size == 1) [it] else it})
   
    if (params.tree_method == 'raxml'){
        RAXML(
            BBMAP_REFORMAT2.out.reformated.map{if (params.batching_size == 1) [it] else it}
        )
        ch_all_trees = RAXML.out.tree_bipartitions.flatten().toSortedList()
        
        ch_versions = ch_versions.mix(RAXML.out.versions)
    }else if (params.tree_method == 'iqtree'){
        IQTREE(
            BBMAP_REFORMAT2.out.reformated.map{if (params.batching_size == 1) [it] else it}
        )
        ch_all_trees = IQTREE.out.contree.flatten().toSortedList()
        
        ch_versions = ch_versions.mix(IQTREE.out.versions)
    }

    MERGE_TREES(
        ch_all_trees
    )

    ASTER(
        MERGE_TREES.out.merged_trees
    )


    ch_versions = ch_versions.mix(BBMAP_DEDUPE.out.versions)
    ch_versions = ch_versions.mix(PREPARE_ADAPTOR.out.versions)
    ch_versions = ch_versions.mix(BBMAP_REFORMAT.out.versions)
    ch_versions = ch_versions.mix(TRIMMOMATIC.out.versions)
    ch_versions = ch_versions.mix(PEAR.out.versions)
    
    ch_versions = ch_versions.mix(CONCATENATE.out.versions)
    ch_versions = ch_versions.mix(CONCATENATE_RAW.out.versions)
    
    ch_versions = ch_versions.mix( TRIMMOMATIC_CLEAN_PE.out.versions)
    ch_versions = ch_versions.mix( TRIMMOMATIC_CLEAN_SE.out.versions)

    
    ch_versions = ch_versions.mix( ASSEMBLY_POSTPROCESSING.out.versions)
    ch_versions = ch_versions.mix( BLAT.out.versions)
    ch_versions = ch_versions.mix( BLAT2.out.versions)
    ch_versions = ch_versions.mix( PARSE_BLAT_RESULTS.out.versions)
    ch_versions = ch_versions.mix( MAFFT.out.versions)
    //ch_versions = ch_versions.mix( PERL_CLEANUP.out.versions)

    ch_versions = ch_versions.mix( MAKE_PRG.out.versions)
    ch_versions = ch_versions.mix( QUALITY_2_ASSEMBLY.out.versions)
    ch_versions = ch_versions.mix( PHYLOGENY_MAKE_ALIGNMENTS.out.versions)
    
    //ch_versions = ch_versions.mix(CONVERT_PHYML.out.versions)
    ch_versions = ch_versions.mix(SED.out.versions)
    ch_versions = ch_versions.mix(BBMAP_REFORMAT2.out.versions)
    ch_versions = ch_versions.mix(MERGE_TREES.out.versions)
    ch_versions = ch_versions.mix(ASTER.out.versions)


    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
    
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
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
