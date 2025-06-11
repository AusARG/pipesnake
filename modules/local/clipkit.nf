process CLIPKIT {
    tag "${ fasta_ls.size() > 1 ? 'batch of ' + fasta_ls.size() + ' fasta files' : fasta_ls[0].getSimpleName()}"

    conda "bioconda::clipkit=2.4.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/clipkit%3A2.4.1--pyhdfd78af_0' :
        'quay.io/biocontainers/clipkit:2.4.1--pyhdfd78af_0' }"

    input:
    path(fasta_ls)

    output:
    path("*.clipkit"), emit: trimmed_allignments
    path "versions.yml", emit: versions

    script:

    """
    for fasta in ${fasta_ls.join(' ')}; do
        clipkit \${fasta} ${task.ext.args} || true
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        clipkit: 2.4.1
    END_VERSIONS
    """
}
