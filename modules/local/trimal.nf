process TRIMAL {
    tag "${ fasta_ls.size() > 1 ? 'batch of ' + fasta_ls.size() + ' fasta files' : fasta_ls[0].getSimpleName()}"

    conda "bioconda::trimal=1.5.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/trimal%3A1.5.0--h9948957_2' :
        'quay.io/biocontainers/trimal:1.5.0--h9948957_2' }"

    input:
    path(fasta_ls)

    output:
    path("*.trimal"), emit: trimmed_allignments
    path "versions.yml", emit: versions

    script:

    """
    for fasta in ${fasta_ls.join(' ')}; do
        trimal -in \${fasta} -out \${fasta}.trimal ${task.ext.args} || true
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimal: 1.5.0
    END_VERSIONS
    """
}
