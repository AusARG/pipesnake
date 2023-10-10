process CONCATENATE_RAW {
    tag "$sample_id"

    conda "conda-forge::pigz=2.3.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pigz:2.3.4' :
        'biocontainers/pigz:2.3.4' }"
        
    input:
        tuple val(sample_id), path (fastq1), path (fastq2)
        val(name_suffix)

    output:
        tuple val(sample_id), path("*_${name_suffix}_R1.${task.ext.fastq_suffix}.gz"), path("*_${name_suffix}_R2.${task.ext.fastq_suffix}.gz"), emit: concatenated
        path "versions.yml", emit: versions


    script:
    
    """
    zcat ${fastq1.join(" ")} | gzip -c > ${sample_id}_${name_suffix}_R1.${task.ext.fastq_suffix}.gz
    zcat ${fastq2.join(" ")} | gzip -c > ${sample_id}_${name_suffix}_R2.${task.ext.fastq_suffix}.gz
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BusyBox: v1.22.1
    END_VERSIONS
    """
}