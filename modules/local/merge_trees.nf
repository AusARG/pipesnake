process MERGE_TREES {
    tag "Merging all trees"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    val(tree_list)
    
    output:
    path("AllLoci.trees"), emit: merged_trees
    path "versions.yml", emit: versions

    script:
    
    """
    for tree in ${tree_list.join(' ')}; do
        cat \$tree >> AllLoci.trees       
    done



    "${task.process}":
        cat: \$(cat -V | sed -n '1 p' | sed 's/gzip //g')
        gzip: \$(gzip --version | sed -n '1 p' | sed 's/gzip //g')
    END_VERSIONS
    """
}
