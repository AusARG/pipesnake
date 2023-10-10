process TRIMMOMATIC_CLEAN_PE {
    tag "$sample_id"

    conda "bioconda::trimmomatic=0.39"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/trimmomatic:0.39--hdfd78af_2':
        'biocontainers/trimmomatic:0.39--hdfd78af_2' }"


    input:
    tuple val(sample_id), path(fastq1), path(fastq2)
    
    output:
    tuple val(sample_id), path("*_R1_paired_trimmed_cleaned.${task.ext.fastq_suffix}.gz"), path ("*_R2_paired_trimmed_cleaned.${task.ext.fastq_suffix}.gz"), emit: trimmed_cleaned_paired
    tuple val(sample_id), path ("*_R1_unpaired_trimmed_cleaned.${task.ext.fastq_suffix}.gz"), path ("*_R2_unpaired_trimmed_cleaned.${task.ext.fastq_suffix}.gz"), emit: trimmed_cleaned_unpaired
    path "versions.yml", emit: versions


    script:
    
    """
    trimmomatic PE \
        -threads  ${task.cpus} \
        ${fastq1} \
        ${fastq2} \
        ${sample_id}_R1_paired_trimmed_cleaned.${task.ext.fastq_suffix}.gz \
        ${sample_id}_R1_unpaired_trimmed_cleaned.${task.ext.fastq_suffix}.gz \
        ${sample_id}_R2_paired_trimmed_cleaned.${task.ext.fastq_suffix}.gz \
        ${sample_id}_R2_unpaired_trimmed_cleaned.${task.ext.fastq_suffix}.gz \
        ${task.ext.args}
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimmomatic: \$(trimmomatic -version)
    END_VERSIONS
    """
}
