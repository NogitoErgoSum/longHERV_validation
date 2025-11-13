#!/usr/bin/env nextflow

process BAM2FASTQ {

    input:
        tuple path(bam),path(bai)
    
    output:
        path "${bam.simpleName}.fastq", emit: fastq
    
    script:
    """
    samtools bam2fq ${bam} > ${bam.simpleName}.fastq
    """
}