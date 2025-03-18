#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */
params.sample = 'samples.txt'

workflow {

    ref_file    = file(params.ref_fasta)
    te_ref_file = file(params.te_ref)

    // create a channel for inputs from a CSV file
    sample_ch = Channel.fromPath(params.sample)
                        .splitCsv()
                        .view {sample -> "Before split: $sample"}
                        .map { line -> line[0] }
                        .view {sample -> "After split: $sample"}
    
    // Run sTELLeR on each sample
    STELLER(sample_ch)
}