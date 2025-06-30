process READ_DEPTH_STATISTICS {
    tag "Statistics for ${prg_files.size()} samples"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    val sample_ids
    path prg_files

    output:
    path 'read_depth_statistics.csv'
    path "versions.yml", emit: versions

    script:
    """
    read_depth_statistics.py "${sample_ids}" ${prg_files.join(' ')}

    echo "${task.process}:
      python: \$(python -c 'import sys; print(sys.version.split()[0])')" > versions.yml
    """
}
