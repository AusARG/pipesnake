process MERGE_TREES {
    tag "Merging all trees"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'biocontainers/python:3.8.3' }"

    input:
    path(tree_list)
    
    output:
    path("AllLoci.trees"), emit: merged_trees
    path "versions.yml", emit: versions

    script:
    
    """
    for tree in ${tree_list.join(' ')}; do
        cat \$tree >> AllLoci.trees       
    done


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BusyBox: v1.22.1
    END_VERSIONS
    """
}
