#!/usr/bin/env nextflow

include { STELLER } from './modules/STELLER.nf'
include { TLDR } from './modules/TLDR.nf'
include { PALMER } from './modules/PALMER.nf'
include { XTEA } from './modules/XTEA.nf'

/*
 * Pipeline parameters
 */
params.samplefile = 'samples.txt'

workflow {

    ref_file        = file(params.ref_fasta)
    te_ref_file     = file(params.te_ref)

    // create a channel for inputs from a CSV file
    sample_ch = Channel.fromPath(params.samplefile)
                        .splitCsv()
                        .map { line -> 
                            def bam = file(line[0])             // BAM file
                            def bai = file(line[0] + ".bai")    // BAM index file
                            tuple(bam, bai)
                       }
    
    // Run sTELLeR on each sample
    STELLER(sample_ch, ref_file, te_ref_file)
    // Run TLDR on each sample
    TLDR(sample_ch, ref_file, te_ref_file)
    // Run PALMER on each sample
    PALMER(sample_ch, ref_file, te_ref_file)
    // Run XTEA on each sample
    XTEA(sample_ch, ref_file, te_ref_file)
}