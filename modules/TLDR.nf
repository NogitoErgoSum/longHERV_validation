#!/usr/bin/env nextflow

process TLDR {

    publishDir "${params.outdir}/${sample}/TLDR", mode: 'copy'
    // container 'docker://quay.io/sarahbeecroft9/tldr'
    conda '/users/k2140993/.conda/envs/tldr'

    input:
        val sample
        path ref_fasta
        path te_ref_fasta
        path bamdir
    
    output:
        path "${sample}.haplotagged.table.txt"
    
    script:
    """
    tldr\
        -b ${bamdir}/${sample}.haplotagged.bam \
        -e ${te_ref_fasta} \
        -r ${ref_fasta} \
        -p 16
    """
}