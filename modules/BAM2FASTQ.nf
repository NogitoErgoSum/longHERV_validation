#!/usr/bin/env nextflow

process BAM2FASTQ {
    tag "$sample_id"

    input:
        tuple path(bam),path(bai), val(sample_id)
    
    output:
        path "${bam.simpleName}.fastq", emit: fastq
    
    script:
    """
    samtools bam2fq ${bam} > ${bam.simpleName}.fastq
    """
}