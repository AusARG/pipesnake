process MAKE_PRG {
    tag "$sample_id"

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'biocontainers/python:3.8.3' }"

    input:
    tuple val(sample_id), path(sample_fasta), path(sample_matches), val(lineage)
    
    output:
    tuple val(sample_id), path("${lineage}.fasta"), emit: RGB
    path "versions.yml", emit: versions

    script:
    
    """
    make_PRG.py \
        --lineage ${lineage} \
        --match-file ${sample_matches} \
        --sample-fasta ${sample_fasta} \
        --output-dir ./ \
        --sample ${sample_id} ${task.ext.args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
    
}
