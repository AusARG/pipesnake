process SPADES {
    tag "$sample_id"

    conda "bioconda::spades=3.15.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:3.15.5--h95f258a_1' :
        'biocontainers/spades:3.15.5--h95f258a_1' }"
        
    input:
    tuple val(sample_id), path(fastq1), path(fastq2)
    
    output:
    tuple val(sample_id), path('contigs.fasta')      , emit: contigs
    tuple val(sample_id), path('*.log')                , emit: log
    path  "versions.yml"                          , emit: versions



    script:
    def maxmem = task.memory.toGiga()

    """
    spades.py \
        -1 ${fastq1} \
        -2 ${fastq2} \
        --threads $task.cpus \
        --memory $maxmem \
        -o ./ \
        ${task.ext.args} \
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spades: \$(spades.py --version 2>&1 | sed 's/^.*SPAdes genome assembler v//; s/ .*\$//')
    END_VERSIONS
    """
}
