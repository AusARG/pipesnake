process RAXML {
    tag "${ fasta_ls.size() > 1 ? 'batch of ' + fasta_ls.size() + ' fasta files' : fasta_ls[0].getSimpleName()}"

    conda "bioconda::raxml=8.2.12"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/raxml:8.2.9--hec16e2b_5' :
        'quay.io/biocontainers/raxml:8.2.9--h516909a_3' }"

      

    input:
    path(fasta_ls)
    
    output:
    path("RAxML_info.*"), emit: tree_info
    path("RAxML_bootstrap.*"), emit: tree_bootstrap
    path("RAxML_bipartitionsBranchLabels.*"), emit: tree_bipartitions_branch_labels
    path("RAxML_bipartitions.*"), emit: tree_bipartitions
    path("RAxML_bestTree.*"), emit: best_tree
    path "versions.yml", emit: versions

    script:
    //locus = fasta.getBaseName().split('.')[0]
    

    def raxml_runs = task.ext.raxml_runs ?: 100  

    """
     for fasta in ${fasta_ls.join(' ')}; do
        file_lines=\$(cat \$fasta | wc -l)
        if [ \$file_lines -gt 0 ]
        then
            sp_cnt=\$(cat \$fasta | grep \\> | wc -l)
            if [ \$sp_cnt -lt 4 ]
            then
                echo "\$fasta" >> fasta_few_specieis.txt
            else
                locus="\$(basename -- "\$fasta" | sed 's/\\(.*\\)\\..*/\\1/')"
                rand1=\$[ ( \$RANDOM % 1000 )  + 1 ]
                rand2=\$[ ( \$RANDOM % 1000 )  + 1 ]
                
                raxmlHPC -x \$rand1 -# $raxml_runs -T ${task.cpus} -p \$rand2  ${task.ext.args} \${locus} -s \${fasta}
                
            fi
        else
            echo "\$fasta" >> empty_fastq.txt
        fi       
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        raxml : \$(raxmlHPC -v | sed -n '3 p' | sed 's/This is RAxML version //g' | sed 's/ released by Alexandros Stamatakis on July 20 2016.//' )
    END_VERSIONS
    """
}
