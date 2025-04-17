#!/usr/bin/env nextflow

process STELLER {

    publishDir "${params.outdir}/${bam.simpleName}/sTELLeR", mode: 'copy'

    input:
        tuple path(bam),path(bai)
        path ref_fasta
        path te_ref_fasta
    
    output:
        path "${bam.simpleName}_repeats.vcf"
    
    script:
    """
    python /sTELLeR/steller/steller.py \
        --ref ${ref_fasta} \
        --bam ${bam} \
        --TE_fasta ${te_ref_fasta} \
        --style ont \
        --output ${bam.simpleName}
    """
}
