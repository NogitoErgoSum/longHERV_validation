#!/usr/bin/env nextflow

process TLDR {
    publishDir path: { "${params.outdir}/${bam.simpleName}/TLDR" }, mode: 'copy'
    
    tag "$sample_id"

    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'docker://quay.io/sarahbeecroft9/tldr'
        : 'quay.io/sarahbeecroft9/tldr'}"

    input:
        tuple path(bam),path(bai), val(sample_id)
        path ref_fasta
        path te_ref_fasta
    
    output:
        path "${bam.simpleName}.haplotagged.table.txt"
    
    script:
    """
    tldr\
        -b ${bam} \
        -e ${te_ref_fasta} \
        -r ${ref_fasta} \
        -p ${task.cpus}
    """
}