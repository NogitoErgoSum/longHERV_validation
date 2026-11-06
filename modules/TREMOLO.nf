#!/usr/bin/env nextflow

process TREMOLO {
    publishDir "${params.outdir}/${fastq.simpleName}/TrEMOLO/", mode: 'copy'

    input:
        val fastq
        path ref_fasta
        path te_ref_fasta
        path tremolo_config
        path tremolo_snk

    output:
        path "${fastq.simpleName}/TE_INFOS.bed", optional: true
        path "${fastq.simpleName}/OUTSIDER/TE_TOWARD_GENOME/SEQUENCE_INDEL_as_TE_READS.fasta", optional: true
    
    script:
    """
    set +e
    snakemake --snakefile ${tremolo_snk} \
        --configfile ${tremolo_config}
    SNAKEMAKE_EXIT_CODE=\$?
    set -e

    echo "Snakemake finished with exit code: \$SNAKEMAKE_EXIT_CODE"

    if find . -type f -name "TE_INFOS.bed" -print -quit | grep -q .; then
        echo "Output found, forcing success."
        exit 0
    else
        echo "Output missing, true failure."
        exit 1
    fi
    """
}