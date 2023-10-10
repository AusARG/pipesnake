process PEAR {
    tag "$sample_id"

    conda "bioconda::pear=0.9.6"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pear:0.9.6--h67092d7_8':
        'biocontainers/pear:0.9.6--h67092d7_8' }"
        
    input:
    tuple val(sample_id), path(fastq_r1), path (fastq_r2)
    
    output:
    tuple val(sample_id), path("*.unassembled.forward.${task.ext.fastq_suffix}.gz"), path ("*.unassembled.reverse.${task.ext.fastq_suffix}.gz"), emit: unmerged
    tuple val(sample_id), path ("*.assembled.${task.ext.fastq_suffix}.gz"), emit: merged
    tuple val(sample_id), path ("*.discarded.${task.ext.fastq_suffix}.gz"), emit: discarded

    path "versions.yml", emit: versions

	script:
    
    """
    pear -f ${fastq_r1} -r ${fastq_r2} -o ${sample_id} -j ${task.cpus} ${task.ext.args}
    gzip  *.fastq
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pear: \$(pear -h | grep 'PEAR v' | sed 's/PEAR v//' | sed 's/ .*//' ))
    END_VERSIONS
    """
}


