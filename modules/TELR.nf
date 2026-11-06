#!/usr/bin/env nextflow

/*
 * TELR module
 *
 * KNOWN ISSUE (TELR 1.1 + conda >= 25):
 * At the very end of a run, TELR calls export_env(), which runs
 * `conda env export` into "conda_env.yml.tmp". Newer conda refuses the
 * ".tmp" filename, so TELR crashes with FileNotFoundError AFTER all
 * results have been written. The task then fails and nothing is published.
 *
 * FIX: disable that call in the cached conda env (one-off, but must be
 * re-applied whenever the env is rebuilt, e.g. new conda_cache or a
 * changed `conda` directive, which changes the env hash):
 *
 *   ENV=/scratch/prj/ppn_als_longread/HERV_detection/conda_cache/env-<hash>
 *   TELR_PY=$ENV/lib/python3.6/site-packages/telr/telr.py
 *   cp $TELR_PY ${TELR_PY}.bak
 *   sed -i 's/^\(\s*\)export_env(env_file)/\1pass  # export_env disabled: incompatible with conda >=25/' $TELR_PY
 *   grep -n "export_env" $TELR_PY   # check the call is now disabled
 *
 * Symptom if the patch is missing:
 *   "EnvironmentExporterNotDetected: ... 'conda_env.yml.tmp'" in .command.err
 */

process TELR {
    conda 'telr'

    tag "$sample_id"

    publishDir path: { "${params.outdir}/${bam.simpleName}/TELR" }, mode: 'copy'

    input:
        tuple path(bam),path(bai), val(sample_id)
        path ref_fasta
        path te_ref_fasta
    
    output:
        path "${bam.simpleName}.telr.vcf"
        path "${bam.simpleName}.telr.json"
        path "${bam.simpleName}.telr.expanded.json"
        path "${bam.simpleName}.telr.bed"
        path "${bam.simpleName}.telr.te.fasta"
        path "${bam.simpleName}.telr.contig.fasta"
    
    script:
    """
    telr\
        --reads ${bam} \
        --library ${te_ref_fasta} \
        --reference ${ref_fasta} \
        --thread ${task.cpus}
    """
}