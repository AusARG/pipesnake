process BBMAP_DEDUPE {
    tag "$sample_id"

    conda "bioconda::bbmap=39.01"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bbmap:39.01--h5c4e2a8_0':
        'biocontainers/bbmap:39.01--h5c4e2a8_0' }"

    input:
    tuple val(sample_id), path (fastq) //, val(meta)
    
    output:
    tuple val(sample_id), path ("${sample_id}_deduped.${task.ext.fastq_suffix}.gz"), emit: deduplicates
    path "${sample_id}_duplicates.${task.ext.fastq_suffix}.gz", emit: duplicates
    path "versions.yml", emit: versions

    script:
    
    //input = meta.single_end ? "in=${fastq}" : "in=${fastq[0]} in2=${fastq[1]}"
    fastq_r1 = fastq[0]
    fastq_r2 = fastq[1]
    input = "in=${fastq_r1} in2=${fastq_r2}"
    
    def avail_mem = 3072
    if (!task.memory) {
        log.info '[dedupe] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = (task.memory.mega*0.8).intValue()
    }

    """
    dedupe.sh -Xmx${avail_mem}M ${input}  out=${sample_id}_deduped.${task.ext.fastq_suffix}.gz outd=${sample_id}_duplicates.${task.ext.fastq_suffix}.gz ${task.ext.args} threads=${task.cpus} 
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BBMAP - dedupe.sh: \$(dedupe.sh -version 2>&1 | sed -n '2 p' | sed 's/BBMap version //g')
    END_VERSIONS
    
    """
}
