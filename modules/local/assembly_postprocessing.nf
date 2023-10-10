process ASSEMBLY_POSTPROCESSING {
    tag "$sample_id"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'biocontainers/python:3.8.3' }"

    input:
    tuple val(sample_id), path(assembly_input)
    
    output:
    tuple val(sample_id), path ("${sample_id}_assembly_processed.fasta"), emit: processed
    path "versions.yml", emit: versions


    script:
    """
    #!/usr/bin/env python
    import sys
    with open ("${assembly_input}", "r") as assembly_input:
        with open ("${sample_id}_assembly_processed.fasta", "w") as assembly_processed:
            contig_cntr = 1
            for line in assembly_input:
                if line[0] == ">":
                    line = ">${sample_id}_${task.ext.assembly_header}{}\\n".format(contig_cntr)
                    contig_cntr += 1
                assembly_processed.write(line)
    
    with open ("versions.yml", "w") as version_file:
	    version_file.write("\\"${task.process}\\":\\n    python: {}\\n".format(sys.version.split()[0].strip()))
    
    """
}
