process BBMAP_FILTER{
tag "$sample_id"

    conda "bioconda::bbmap=39.01"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bbmap:39.01--h5c4e2a8_0':
        'quay.io/biocontainers/bbmap:39.01--h5c4e2a8_0' }"

    input:
    tuple val(sample_id), path(fastq_r1), path(fastq_r2)
    path (reference_genome)
    output:
    tuple val(sample_id), 
            path ("${sample_id}_R1_bbmap.${task.ext.fastq_suffix}.gz"), 
            path ("${sample_id}_R2_bbmap.${task.ext.fastq_suffix}.gz") , emit: prepared_reads
    path "versions.yml", emit: versions

    script:
    
    input = "in=${fastq_r1} in2=${fastq_r2}"
    
    def avail_mem = 3072
    if (!task.memory) {
        log.info '[bbmap] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = (task.memory.mega*0.8).intValue()
    }

    """
    bbmap.sh -Xmx${avail_mem}M in1=${fastq_r1} in2=${fastq_r2} \
        ref=${reference_genome} \
        outm1=${sample_id}_R1_bbmap.${task.ext.fastq_suffix}.gz \
        outm2=${sample_id}_R2_bbmap.${task.ext.fastq_suffix}.gz \
        ${task.ext.args} threads=auto
						
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BBMAP - bbmap.sh: \$(bbamp.sh -version 2>&1 | sed -n '2 p' | sed 's/BBMap version //g')
    END_VERSIONS
    """
}
