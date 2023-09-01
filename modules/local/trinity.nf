process TRINITY {
    tag "$sample_id"

    conda "bioconda::trinity=2.13.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/trinity:2.13.2--h00214ad_1':
        'biocontainers/trinity:2.13.2--h00214ad_1' }"
        
    input:
    tuple val(sample_id), val(fastq1), val(fastq2)
    
    output:
    tuple val(sample_id), path ("${sample_id}"), emit: trinity_dir
    tuple val(sample_id), path ("${sample_id}.Trinity.fasta"), emit: trinity_fasta
    path "versions.yml", emit: versions


    script:
    """
    Trinity \
        --max_memory ${task.memory.toGiga()}G \
        --left ${fastq1} \
        --right ${fastq2} \
        --CPU ${task.cpus} \
        --output ${sample_id} \
        ${task.ext.args}
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Trinity: \$(Trinity --version | sed -n '1 p' | sed 's/Trinity version: //g')
    END_VERSIONS
    """
}
