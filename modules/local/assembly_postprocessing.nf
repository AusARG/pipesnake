process ASSEMBLY_POSTPROCESSING {
    tag "$sample_id"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(sample_id), path(assembly_input)

    output:
    tuple val(sample_id), path ("${sample_id}_assembly_processed.fasta"), emit: processed
    path "versions.yml", emit: versions


    script:
    """
    assembly_postprocessing.py ${assembly_input} ${sample_id} ${task.ext.assembly_header} ${task.ext.read_depth_threshold}

    echo "${task.process}:
      python: \$(python -c 'import sys; print(sys.version.split()[0])')" > versions.yml
    """
}
