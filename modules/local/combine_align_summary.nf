process COMBINE_ALIGN_SUMMARY {
    tag "Combining alignment summmary"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    path pre_trim_locus_summary
    path post_trim_locus_summary

    output:
    path "combined_locus_summary.csv", emit: combined_locus_summary
    path "versions.yml", emit: versions

    script:

    """
    combine_align_summary.py \
        --pre-trim-locus-summary ${pre_trim_locus_summary} \
        --post-trim-locus-summary ${post_trim_locus_summary} \
        --output-file combined_locus_summary.csv ${task.ext.args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
