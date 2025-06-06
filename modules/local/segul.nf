process SEGUL {
    tag "${fasta_ls} summary statistics"

    conda "bioconda::segul=0.22.1"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/python:3.8.3' :
    //     'quay.io/biocontainers/segul:0.22.1--hc1c3326_1' }"
    container 'quay.io/biocontainers/segul:0.22.1--hc1c3326_1'

    input:
    path fasta_ls

    output:
    path "Align-Summary/alignment_summary.txt", emit: align_summary
    path "Align-Summary/locus_summary.csv", emit: locus_summary
    path "Align-Summary/taxon_summary.csv", emit: taxon_summary
    path "versions.yml", emit: versions

    script:

    """
    segul align summary -i ${fasta_ls.join(' ')} -f fasta --force ${task.ext.args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        segul: \$(echo \$(segul -V) | sed 's/segul //g')
    END_VERSIONS
    """

}
