#!/usr/bin/env nextflow

process STELLER {

    publishDir "${params.outdir}/${sample_ch}/sTELLeR/", mode: 'copy'
    container 'docker://kristinebilgrav/steller'

    input:
        val sample
        path outdir
        path ref_fasta
    
    output:
        path "${sample}_repeats.vcf", emit: steller_out
    
    script:
    """
    python /sTELLeR/steller/steller.py \
        --ref $ref_fasta \
        --bam /bams/${sample}.haplotagged.bam \
        --TE_fasta /te_ref/TEsequences_SVA_HERV_ALU_L1.fasta \
        --style ont \
        --output /output/${sample}
    """
}
