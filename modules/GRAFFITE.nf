#!/usr/bin/env nextflow

process GRAFFITE {
	tag "$sample_id"
	publishDir "${params.outdir}/${bam.simpleName}/GRAFFITE", mode: 'copy'

	input:
		tuple path(bam),path(bai), val(sample_id)
		path ref_fasta
		path te_ref_fasta

	output:
        

	script:
	"""
	
	"""
}
