process CONVERT_PHYML {
    tag "adaptor"

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    path (fasta_path)

    output:
    path ("*.aln.phy") , emit: converted_phyml
    path "versions.yml", emit: versions

    
    script:
    """
    #!/usr/bin/env python
    from pathlib import Path

    file_nm = Path("${fasta_path}").stem
    with open("${fasta_path}", 'r') as in_f:
        if True:
            seq = {}
            id = ''
            for line in in_f:
                if re.search('>', l):
                    id = re.search('>(\\S+)', l.rstrip()).group(1)
                    if re.search('^_R_', id):
                        id = re.sub('^_R_', '', id)
                    seq[id] = ''
                else:
                    seq[id] += l.rstrip()

    with open(file_nm + '.aln.phy', 'w') as out_file:
        for sp, s in seq.items():
            # get rid of white spaces from gblocks
            s = re.sub('\\s+', '', s)
            seq[sp] = s

        out_file.write(' %s %s\\n' % (len(seq), len(seq.values()[0])))
        for sp, s in seq.items():
            out_file.write('%s   %s\\n' % (sp, s))    
    
    
    with open ("versions.yml", "w") as version_file:
        version_file.write("${task.process}:\\n\\tpython: " + sys.version.split()[0].strip())
    
    """
}
