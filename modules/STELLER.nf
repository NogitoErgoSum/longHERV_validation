#!/usr/bin/env nextflow

process STELLER {

    publishDir "${params.outdir}/${sample}/sTELLeR", mode: 'copy'
    container 'docker://kristinebilgrav/steller'

    input:
        val sample
        path ref_fasta
        path te_ref_fasta
        path bamdir
    
    output:
        path "${sample}_repeats.vcf"
    
    script:
    """
    python /sTELLeR/steller/steller.py \
        --ref ${ref_fasta} \
        --bam ${bamdir}/${sample}.haplotagged.bam \
        --TE_fasta ${te_ref_fasta} \
        --style ont \
        --output ${sample}
    """
}
