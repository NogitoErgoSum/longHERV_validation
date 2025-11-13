#!/usr/bin/env nextflow

process PREP_TREMOLO {

    input:
        val fastq
        path ref_fasta
        path te_ref_fasta
        path tremolo_config
        path tremolo_snk
    
    output:
        path "config_temp.yaml", emit: tremoloConfig
        path "run_temp.snk", emit: tremoloSnk
    
    script:
    """
    # Copy the config to a writable location
    cp -L ${tremolo_config} config_temp.yaml
    cp -L ${tremolo_snk} run_temp.snk

    # Replace FASTQ_INPUT with sample-specific filename
    sed -i "s#/path/to/reference_file.fasta#${ref_fasta}#g" config_temp.yaml
    sed -i "s#/path/to/genome_file.fasta#${ref_fasta}#g" config_temp.yaml
    sed -i "s#/path/to/database_TE.fasta#${te_ref_fasta}#g" config_temp.yaml
    sed -i "s#/path/to/reads_file.fastq#/${fastq}#g" config_temp.yaml
    sed -i "s#TrEMOLO_OUTPUT#${fastq.simpleName}#g" config_temp.yaml

    sed -i "s#config.yaml#config_temp.yaml#g" run_temp.snk
    """
}