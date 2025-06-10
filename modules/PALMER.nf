#!/usr/bin/env nextflow

process PALMER {

    publishDir "${params.outdir}/${bam.simpleName}/PALMER/${te_family}/", mode: 'copy'

    input:
        tuple path(bam),path(bai)
        path ref_fasta
        path te_ref_fasta
        val te_family

    output:
        path "${bam.simpleName}_calls.txt"
        path "${bam.simpleName}_TSD_reads.txt"
    
    script:
    """
    /PALMER/PALMER \
        --input ${bam} \
        --workdir ./ \
        --ref_ver other \
        --ref_fa ${ref_fasta} \
        --output ${bam.simpleName} \
        --type CUSTOMIZED \
        --mode raw \
        --chr ALL \
        --custom_seq ${te_ref_fasta}
    """
}
