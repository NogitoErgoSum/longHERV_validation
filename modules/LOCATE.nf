#!/usr/bin/env nextflow

process LOCATE {
    publishDir path: { "${params.outdir}/${bam.simpleName}/LOCATE" }, mode: 'copy', saveAs: { filename -> "${sample_id}_${filename}" }
    
    tag "$sample_id"

    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'docker://huzr14830/locate'
        : 'huzr14830/locate'}"

    input:
        tuple path(bam),path(bai), val(sample_id)
        path ref_fasta
    
    output:
        path "${bam.simpleName}/result.tsv"
        path "${bam.simpleName}/result.vcf"
    
    script:
    """
    source /opt/conda/etc/profile.d/conda.sh
    conda activate locate
    
    locate \
        -b ${bam} \
        -C /GRCh38/GRCh38_steller.class \
        -T /GRCh38/GRCh38_steller.fa \
        -R ${ref_fasta} \
        -H /GRCh38/GRCh38_HighFreq \
        -L /GRCh38/GRCh38_LowFreq \
        -r /GRCh38/GRCh38.rmsk.bed \
        -g /GRCh38/GRCh38.gap.bed \
        -B /GRCh38/GRCh38.blacklist.bed \
        -t ${task.cpus ?: 1} \
        -F both \
        -o ${bam.simpleName}
    """
}
