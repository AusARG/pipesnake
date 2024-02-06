process PERL_CLEANUP {
    tag "$sample_id"

    conda "conda-forge::perl=5.32.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/perl:5.26.2' :
        'quay.io/biocontainers/perl:5.26.2' }"

    input:
    tuple val(sample_id), path(fasta) //, val(meta)
    
    output:
    //tuple val(sample_id), path("*fasta.aln"), emit: aligned
    path "versions.yml", emit: versions

    script:

    """
    perl ${task.ext.args} ${fasta}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        perl: \$(perl --version | sed -n '2 p')
    END_VERSIONS
    """
}
