process BLAT {
    tag "$sample_id"

    conda "bioconda::blat=36"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/blat:36--0' :
        'quay.io/biocontainers/blat:36--0' }"

    input:
    tuple val(sample_id), path(fasta)
    path (db_path)
    val (suffix)
    val (switch_input)
    output:
    tuple val(sample_id), path ("${sample_id}_${suffix}"), emit: matches
    path "versions.yml", emit: versions


    script:
    input = switch_input ? "${db_path}  ${fasta}" : "${fasta} ${db_path}" 
    """
    blat ${input} \
        ${sample_id}_${suffix} \
        ${task.ext.args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        blat: \$(blat | sed -n '1 p' | sed 's/blat - Standalone BLAT //g' | sed 's/ fast sequence search command line tool/ /g')
    END_VERSIONS
    """
}
