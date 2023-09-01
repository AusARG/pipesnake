process PREPARE_ADAPTOR {
    tag "adaptor"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    tuple val(sample_id), val(meta_info)

    output:
    tuple val(sample_id), path ("${sample_id}.fa") , emit: adaptor
    path "versions.yml", emit: versions

    
    script:
    """
	#!/usr/bin/env python
	import sys
	seq_dict = {'A':'T','T':'A','G':'C','C':'G'}
	f_adaptor_1 = "${meta_info[0]}".replace("*", "${meta_info[2]}")
	f_adaptor_2 = "${meta_info[1]}".replace("*", "${meta_info[3]}")
	with open ("${sample_id}.fa", "w") as fa_file:
	    fa_file.write(">ad1\\n{}\\n>ad1_rc\\n{}\\n".format(f_adaptor_1, "".join([seq_dict[base] for base in reversed(f_adaptor_1)])))
	    fa_file.write(">ad1\\n{}\\n>ad1_rc\\n{}\\n".format(f_adaptor_2, "".join([seq_dict[base] for base in reversed(f_adaptor_2)])))
	with open ("versions.yml", "w") as version_file:
	    version_file.write("${task.process}:\\n\\tpython: " + sys.version.split()[0].strip())
    
    """
}
