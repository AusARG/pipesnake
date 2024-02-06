process PREPARE_ADAPTOR {
    tag "adaptor"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    val(samples_info)

    output:
    path ("*.fa") , emit: adaptor
    path "versions.yml", emit: versions

    script:
    """
	#!/usr/bin/env python
	import sys
	seq_dict = {'A':'T','T':'A','G':'C','C':'G'}
	for sample_info in ${samples_info.collect{"[${it.collect{x -> "\"$x\""}.join(", ")}]"}.toString()}:
        f_adaptor_1 = sample_info[1].replace("*", sample_info[3])
        f_adaptor_2 = sample_info[2].replace("*", sample_info[4])
        with open (sample_info[0] + ".fa", "w") as fa_file:
            fa_file.write(">ad1\\n{}\\n>ad1_rc\\n{}\\n".format(f_adaptor_1, "".join([seq_dict[base] for base in reversed(f_adaptor_1)])))
            fa_file.write(">ad1\\n{}\\n>ad1_rc\\n{}\\n".format(f_adaptor_2, "".join([seq_dict[base] for base in reversed(f_adaptor_2)])))
	with open ("versions.yml", "w") as version_file:
	    version_file.write("\\"${task.process}\\":\\n    python: {}\\n".format(sys.version.split()[0].strip()))
    
    """
}

