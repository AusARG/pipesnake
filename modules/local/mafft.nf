process MAFFT {
    tag "${ fasta_ls.size() > 1 ? 'batch of ' + fasta_ls.size() + ' fasta files' : fasta_ls[0].getSimpleName()}"


    conda "bioconda::mafft=7.520"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mafft:7.520--hec16e2b_0':
        'biocontainers/mafft:7.520--hec16e2b_0' }"


    input:
    path (fasta_ls)
    
    output:
    path("*fasta.aln"), emit: aligned
    path "versions.yml", emit: versions

    script:
    """
    for fasta in ${fasta_ls.join(' ')}; do
        f_out="\$(basename -- "\$fasta" | sed 's/\\(.*\\)\\..*/\\1/')"
        mafft --thread -1 ${task.ext.args} \${fasta} > \${f_out}.fasta.aln  

    done

    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mafft: \$(mafft --version 2>&1 | sed 's/^v//' | sed 's/ (.*)//')
    END_VERSIONS
    """
}
