process PARSE_BLAT_RESULTS {
    tag "$sample_id"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(sample_id), path(query), path(probes_to_sample), path(sample_to_probes) //, val(meta)
    
    output:
    tuple val(sample_id), path("${sample_id}_matches.csv"), emit: matches
    path "versions.yml", emit: versions

    script:
    
    """
    parse_blat.py \
        --query ${query} \
        --sample-to-probes ${sample_to_probes} \
        --probes-to-sample ${probes_to_sample} \
        --output-file ${sample_id}_matches.csv \
        --sample ${sample_id} ${task.ext.args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
    
}
