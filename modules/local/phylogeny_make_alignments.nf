process PHYLOGENY_MAKE_ALIGNMENTS {
    tag "all_run"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    val (lineage_list)
    
    output:
    path("locus_data.csv"), emit: locus_info
    path("*.fasta"), emit: locus_fasta
    path "versions.yml", emit: versions

    script:
    """
    phylogeny_make_alignments.py \
        --lineage-list ${lineage_list.join(" ")} \
        --output-dir ./  ${task.ext.args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
    
}
