#!/usr/bin/env nextflow

process STELLER {
    publishDir "${params.outdir}/${bam.simpleName}/sTELLeR", mode: 'copy', pattern: '*.vcf'
    publishDir "${params.outdir}/${bam.simpleName}/sTELLeR/fasta", mode: 'copy', pattern: '*.fasta'
    
    tag "$sample_id"

    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'docker://kristinebilgrav/steller'
        : 'kristinebilgrav/steller'}"

    input:
        tuple path(bam),path(bai), val(sample_id)
        path ref_fasta
        path te_ref_fasta
    
    output:
        path "${bam.simpleName}_repeats.vcf"  
        path "${bam.simpleName}_*_reads.fasta"
    
    script:
    """
    python /sTELLeR/steller/steller.py \
        --ref ${ref_fasta} \
        --bam ${bam} \
        --TE_fasta ${te_ref_fasta} \
        --style ont \
        --keep_intermediates \
        --output ${bam.simpleName}
    """
}
