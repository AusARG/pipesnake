process CONCATENATE {
    tag "$sample_id"

    conda "conda-forge::pigz=2.3.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pigz:2.3.4' :
        'biocontainers/pigz:2.3.4' }"

    input:
    tuple val(sample_id), val(fastq)
    val(name_suffix)
    
    output:
    tuple val(sample_id), path("*_${name_suffix}.${params.fastq_suffix}.gz"), emit: concatenated
    path "versions.yml", emit: versions


    script:
    
    """
    zcat ${fastq.join(" ")} | gzip -c > ${sample_id}_${name_suffix}.${params.fastq_suffix}.gz
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        zcat: \$(zcat -V | sed -n '1 p' | sed 's/gzip //g')
        gzip: \$(gzip --version | sed -n '1 p' | sed 's/gzip //g')
    END_VERSIONS
    """
}
