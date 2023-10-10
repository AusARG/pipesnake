process ASTER {
    tag "Final Tree"

    conda "bioconda::aster=1.15"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/aster:1.15--h9f5acd7_0' :
        'biocontainers/aster:1.15--h9f5acd7_1' }"

    input:
    path all_trees
    
    output:
    path("aster_tree_final"), emit: final_tree
    path "versions.yml", emit: versions

    script:
    //locus = fasta.getBaseName().split('.')[0]
    
    """
    astral-hybrid \
    -i ${all_trees} \
    -o aster_tree_final

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        astral-hybrid: \$(astral-hybrid 2>&1 | sed -n '2{p;q}' |  sed 's/Version: v//g')
    END_VERSIONS
    """
}
