#!/usr/bin/env nextflow

process PALMER {
    publishDir path: { "${params.outdir}/${bam.simpleName}/PALMER/${te_family}/" }, mode: 'copy'
    
    tag "$sample_id"

    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'docker://quay.io/ymostovoy/lr-palmer'
        : 'quay.io/ymostovoy/lr-palmer'}"

    input:
        tuple path(bam),path(bai), val(sample_id)
        path ref_fasta
        path te_ref_fasta
        val te_family

    output:
        path "${bam.simpleName}_calls.txt"
        path "${bam.simpleName}_TSD_reads.txt"
    
    script:
    """
    te_len=\$(( \$(wc -c < ${te_ref_fasta}) / \$(grep -o '>' ${te_ref_fasta} | wc -l) ))
    
    /PALMER/PALMER \
        --input ${bam} \
        --workdir ./ \
        --ref_ver other \
        --ref_fa ${ref_fasta} \
        --output ${bam.simpleName} \
        --type CUSTOMIZED \
        --TSD_finding TRUE \
        --len_custom_seq \$te_len \
        --thread ${task.cpus ?: 1} \
        --mode raw \
        --chr ALL \
        --custom_seq ${te_ref_fasta} \
        --intermediate 0
    """
}
