process CONCATENATE {
    tag "$sample_id"

    conda "conda-forge::pigz=2.3.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pigz:2.3.4' :
        'quay.io/biocontainers/pigz:2.3.4' }"

    input:
    tuple val(sample_id), path(fastq)
    val(name_suffix)
    
    output:
    tuple val(sample_id), path("*_${name_suffix}.${task.ext.fastq_suffix}.gz"), emit: concatenated
    path "versions.yml", emit: versions


    script:
    
    """
    zcat ${fastq.join(" ")} | gzip -c > ${sample_id}_${name_suffix}.${task.ext.fastq_suffix}.gz
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BusyBox: v1.22.1
    END_VERSIONS
    """
}
