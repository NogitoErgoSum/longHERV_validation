#!/usr/bin/env nextflow

process BAM2FASTQ {
    tag "$sample_id"

    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/samtools:1.9--h91753b0_8'
        : 'quay.io/biocontainers/samtools:1.9--h91753b0_8'}"

    input:
        tuple path(bam),path(bai), val(sample_id)
    
    output:
        path "${bam.simpleName}.fastq", emit: fastq
    
    script:
    """
    samtools bam2fq ${bam} > ${bam.simpleName}.fastq
    """
}