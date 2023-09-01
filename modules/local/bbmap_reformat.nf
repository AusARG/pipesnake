process BBMAP_REFORMAT {
    tag "$sample_id"

    conda "bioconda::bbmap=39.01"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bbmap:39.01--h5c4e2a8_0':
        'biocontainers/bbmap:39.01--h5c4e2a8_0' }"

    input:
    tuple val(sample_id), path(fastq) //, val(meta)
    
    output:
    tuple val(sample_id), path("*_R1_reformated.${params.fastq_suffix}.gz"), path("*_R2_reformated.${params.fastq_suffix}.gz"), emit: reformated_fastq
    path "versions.yml", emit: versions

    script:
    
    """
    reformat.sh in=${fastq} \
        out1=${sample_id}_R1_reformated.${params.fastq_suffix}.gz \
        out2=${sample_id}_R2_reformated.${params.fastq_suffix}.gz \
        ${task.ext.args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BBMAP - reformat.sh: \$(reformat.sh -version 2>&1 | sed -n '2 p' | sed 's/BBMap version //g')
    END_VERSIONS
    """
}
