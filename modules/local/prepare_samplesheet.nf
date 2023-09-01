process PREPARE_SAMPLESHEET {
    tag "$samplesheet"

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(sample_id), val(reads), val(meta)
    output:
    //path '*.csv'       , emit: csv
    path "versions.yml", emit: versions
    path "*_R{1,2}.${params.fastq_suffix}.gz", emit: fastq
    
    script: // This script is bundled with the pipeline, in nf-core/ausargph/bin/
    
    if (reads[0][0].getBaseName().contains("_R1")){
        read1_ls = reads[0]
        read2_ls = reads[1]
    }else{
        read2_ls = reads[0]
        read1_ls = reads[1]
    }
    
    """
    zcat ${read1_ls.join(" ")} | gzip -c > ${meta[0]}_${meta[1]}_${sample_id}_R1.${params.fastq_suffix}.gz
    zcat ${read2_ls.join(" ")} | gzip -c > ${meta[0]}_${meta[1]}_${sample_id}_R2.${params.fastq_suffix}.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        zcat: \$(zcat -V | sed -n '1 p' | sed 's/gzip //g')
        gzip: \$(gzip --version | sed -n '1 p' | sed 's/gzip //g')
    END_VERSIONS
    """
    
}

