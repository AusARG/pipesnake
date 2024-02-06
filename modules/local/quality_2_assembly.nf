process QUALITY_2_ASSEMBLY {
    tag "$sample_id"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(sample_id), path(sample_fasta), path(rgp_file), val(lineage)
    
    
    output:
    tuple val(sample_id), path("${sample_id}_assemblyquality.csv"), emit: quality
    path "versions.yml", emit: versions

    script:
    
    """
    quality_2_assembly.py \
        --lineage ${lineage} \
        --prg-file ${rgp_file} \
        --sample-fasta ${sample_fasta} \
        --output-dir ./ \
        --sample ${sample_id} ${task.ext.args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
