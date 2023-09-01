process MAFFT {
    tag "$fasta"

    conda "bioconda::mafft=7.520"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mafft:7.520--hec16e2b_1':
        'biocontainers/mafft:7.520--hec16e2b_1' }"


    input:
    val (fasta_ls)
    
    output:
    path("*fasta.aln"), emit: aligned
    path "versions.yml", emit: versions

    script:
    """
    for fasta in ${fasta_ls.join(' ')}; do
        f_out="\$(basename -- "\$fasta" | sed 's/\\(.*\\)\\..*/\\1/')"
        mafft ${task.ext.args} \${fasta} > \${f_out}.fasta.aln  

    done

    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mafft: \$(mafft --version)
    END_VERSIONS
    """
}
