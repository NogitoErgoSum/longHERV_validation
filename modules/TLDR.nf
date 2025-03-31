#!/usr/bin/env nextflow

process TLDR {

    publishDir "${params.outdir}/${bam.simpleName}/TLDR", mode: 'copy'
    container 'docker://quay.io/sarahbeecroft9/tldr'

    input:
        tuple path(bam),path(bai)
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
        -p 8
    """
}