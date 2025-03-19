#!/usr/bin/env nextflow

include { STELLER } from './modules/STELLER.nf'
include { TLDR } from './modules/TLDR.nf'

/*
 * Pipeline parameters
 */
params.samplefile = 'samples.txt'

workflow {

    ref_file    = file(params.ref_fasta)
    te_ref_file = file(params.te_ref)

    // create a channel for inputs from a CSV file
    sample_ch = Channel.fromPath(params.samplefile)
                        .splitCsv()
                        .map { line -> line[0] }
    
    // Run sTELLeR on each sample
    STELLER(sample_ch, ref_file, te_ref_file, params.bamdir)
    // Run TLDR on each sample
    TLDR(sample_ch, ref_file, te_ref_file, params.bamdir)
}