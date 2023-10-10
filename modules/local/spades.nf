process SPADES {
    tag "$sample_id"

    conda "bioconda::spades=3.15.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:3.15.5--h95f258a_1' :
        'biocontainers/spades:3.15.5--h95f258a_1' }"
        
    input:
    tuple val(sample_id), path(fastq1), path(fastq2)
    
    output:
    tuple val(meta), path('*.scaffolds.fa')    , optional:true, emit: scaffolds
    tuple val(meta), path('*.contigs.fa')      , optional:true, emit: contigs
    tuple val(meta), path('*.transcripts.fa')  , optional:true, emit: transcripts
    tuple val(meta), path('*.gene_clusters.fa'), optional:true, emit: gene_clusters
    tuple val(meta), path('*.assembly.gfa')    , optional:true, emit: gfa
    tuple val(meta), path('*.log')                , emit: log
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
