process TRINITY {
    tag "$sample_id"

    conda "bioconda::trinity=2.13.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/trinity:2.15.1--hff880f7_1':
        'quay.io/biocontainers/trinity:2.15.1--hff880f7_1' }"
        
    input:
    tuple val(sample_id), path(fastq1), path(fastq2)
    
    output:
    tuple val(sample_id), path ("${sample_id}_trinity.tar.gz"), emit: trinity_dir
    tuple val(sample_id), path ("${sample_id}_trinity.Trinity.fasta"), emit: trinity_fasta
    path "versions.yml", emit: versions


    script:
    """
    Trinity \
        --max_memory ${task.memory.toGiga()}G \
        --left ${fastq1} \
        --right ${fastq2} \
        --CPU ${task.cpus} \
        --output ${sample_id}_trinity \
        ${task.ext.args}
    
    tar czf ${sample_id}_trinity.tar.gz ${sample_id}_trinity 
    rm -rf ${sample_id}_trinity

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trinity: \$(echo \$(Trinity --version | head -n 1 2>&1) | sed 's/^Trinity version: Trinity-v//' ))
    END_VERSIONS
    """
}
