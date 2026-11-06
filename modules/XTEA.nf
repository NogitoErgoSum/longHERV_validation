#!/usr/bin/env nextflow

process XTEA {
    publishDir "${params.outdir}/${bam.simpleName}/XTEA", mode: 'copy'
    
    tag "$sample_id"

    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'docker://quay.io/ymostovoy/lr-xtea'
        : 'quay.io/ymostovoy/lr-xtea'}"

    input:
        tuple path(bam),path(bai), val(sample_id)
        path ref_fasta
        path te_ref_fasta
    
    output:
        path "${bam.simpleName}classified_results.txt.merged_HERV.txt"
        path "${bam.simpleName}classified_results.txt.merged_ALU.txt"
        path "${bam.simpleName}classified_results.txt.merged_LINE1.txt"
        path "${bam.simpleName}classified_results.txt.merged_SVA.txt"
    
    script:
    """
    mkdir output
    mkdir output/tmp
    mkdir output/tmp/cns
    mkdir output/tmp/clip
    mkdir output/tmp/ghost
    mkdir output/tmp/classification
    mkdir output/pub_clip

    export XTEA_PATH=/xTea/xtea_long/
    export REP_LIB=/rep_lib_annotation/
    export PREFIX=output
    export TMP="\${PREFIX}/tmp/"
    export BAM_LIST=output/bam_list.txt
    export SVA_REF_COPY=null

    echo "${bam}" > output/bam_list.txt
    echo "${bam.simpleName}\t${bam}" > output/bam_list1.txt
    echo "${bam.simpleName}" > output/sample_id.txt
    echo "REF ${ref_fasta}" > output/xtea.config
    echo "XTEA_PATH /xTea/xtea_long/" >> output/xtea.config
    echo "BAM_LIST \${PREFIX}"bam_list.txt"" >> output/xtea.config
    echo "TMP \${PREFIX}"tmp/"" >> output/xtea.config
    echo "REP_LIB /rep_lib_annotation/" >> output/xtea.config
    echo "SVA_REF_COPY null" >> output/xtea.config

    python \${XTEA_PATH}"l_main.py" -C \
        -b \${BAM_LIST} \
        -r ${ref_fasta} \
        -p \${TMP} \
        -o ${bam.simpleName}"candidate_list_from_clip.txt"  \
        -n ${task.cpus} \
        -w 75 
    python \${XTEA_PATH}"l_main.py" -A \
        -b \${BAM_LIST} \
        -r ${ref_fasta} \
        -p \${TMP} \
        -i ${bam.simpleName}"candidate_list_from_clip.txt" \
        -o ${bam.simpleName}"all_ins_seqs.fa" \
        --rep \${REP_LIB} \
        -n ${task.cpus}
    python \${XTEA_PATH}"l_main.py" -N \
        -b \${BAM_LIST} \
        -r ${ref_fasta} \
        -p \${TMP}"ghost" \
        -o ${bam.simpleName}"ghost_reads.fa" \
        --rmsk \${REP_LIB}/LINE/hg38/hg38_L1_larger_500_with_all_L1HS.out \
        --cns \${REP_LIB}/consensus/LINE1.fa \
        --min 4000 \
        -n ${task.cpus}
    python \${XTEA_PATH}"l_main.py" -Y \
        -i ${bam.simpleName}"all_ins_seqs.fa" \
        -r ${ref_fasta} \
        -p \${TMP}"classification" \
        --rep \${REP_LIB} \
        -y 15 \
        -o ${bam.simpleName}"classified_results.txt" \
        -n ${task.cpus}
    python \${XTEA_PATH}"l_main.py" --clean \
        -b \${BAM_LIST} \
        -r ${ref_fasta} \
        -p \${TMP} \
        -i ${bam.simpleName}"candidate_list_from_clip.txt"  \
        -n ${task.cpus}
    """
}