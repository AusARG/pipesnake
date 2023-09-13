process BBMAP_REFORMAT2 {
    tag "$fasta"

    conda "bioconda::bbmap=39.01"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bbmap:39.01--h5c4e2a8_0':
        'biocontainers/bbmap:39.01--h5c4e2a8_0' }"

    input:
    val(fasta_ls) //, val(meta)
    
    output:
    path "*.fasta", emit: reformated
    path "versions.yml", emit: versions
    
    script:
    
    def avail_mem = 3072
    if (!task.memory) {
        log.info '[reformat] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = (task.memory.mega*0.8).intValue()
    }
    
    """
    for fasta in ${fasta_ls.join(' ')}; do
        file_base_name="\$(basename -- "\$fasta")"
        reformat.sh -Xmx${avail_mem}M in=\${fasta} out=\${file_base_name}.fasta threads=${task.cpus} ${task.ext.args}
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        BBMAP - reformat.sh: \$(reformat.sh -version 2>&1 | sed -n '2 p' | sed 's/BBMap version //g')
    END_VERSIONS
    """
}
