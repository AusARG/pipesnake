include { TRIMAL } from '../modules/local/trimal'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

workflow {

    ch_versions = Channel.empty()
    Channel
        .fromPath("tests/data/*.fasta", checkIfExists: true)
        .collate(params.batching_size)
        .set{ align_ch }

    TRIMAL(align_ch)
        .trimmed_allignments
        .set{ align_trimmed_ch }

    align_trimmed_ch.view()

    ch_versions = ch_versions.mix(TRIMAL.out.versions)
    ch_versions.view()
}
