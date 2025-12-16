#!/usr/bin/env nextflow

include { STELLER } from './modules/STELLER.nf'
include { TLDR } from './modules/TLDR.nf'
include { PALMER as PALMER_L1; PALMER as PALMER_ALU; PALMER as PALMER_HERV; PALMER as PALMER_SVA} from './modules/PALMER.nf'
include { XTEA } from './modules/XTEA.nf'
include { BAM2FASTQ } from './modules/BAM2FASTQ.nf'
include { TREMOLO } from './modules/TREMOLO.nf'
include { PREP_TREMOLO } from './modules/PREP_TREMOLO.nf'

/*
 * Pipeline parameters
 */
params.samplefile = 'samples.txt'
params.mode = 'all'

workflow {

    ref_file                = file(params.ref_fasta)
    te_ref_file             = file(params.te_ref)
    alu_ref_file            = file(params.alu_ref)
    herv_ref_file           = file(params.herv_ref)
    sva_ref_file            = file(params.sva_ref)
    l1_ref_file             = file(params.l1_ref)
    tremolo_config_file     = file(params.tremolo_config)
    tremolo_snk_file        = file(params.tremolo_snk)

    // create a channel for inputs from a CSV file
    sample_ch = Channel.fromPath(params.samplefile)
                        .splitCsv()
                        .map { line -> 
                            def bam = file(line[0])             // BAM file
                            def bai = file(line[0] + ".bai")    // BAM index file
                            def sample_id = bam.baseName
                            tuple(bam, bai, sample_id)
                       }
    
    if ( params.mode == "steller") {
        // Run sTELLeR on each sample
        STELLER(sample_ch, ref_file, te_ref_file)
    }
    
    else if ( params.mode == "tldr") {
        // Run TLDR on each sample
        TLDR(sample_ch, ref_file, te_ref_file)
    }

    else if ( params.mode == "palmer_alu") {
        // Run PALMER for ALUs on each sample
        PALMER_ALU(sample_ch, ref_file, alu_ref_file, "ALU")
    }

    else if ( params.mode == "palmer_l1") {
        // Run PALMER for L1s on each sample
        PALMER_L1(sample_ch, ref_file, l1_ref_file, "L1")
    }

    else if ( params.mode == "palmer_sva") {
        // Run PALMER for SVAs on each sample
        PALMER_SVA(sample_ch, ref_file, l1_ref_file, "SVA")
    }

    else if ( params.mode == "palmer_herv") {
        // Run PALMER for HERVs on each sample
        PALMER_HERV(sample_ch, ref_file, l1_ref_file, "HERV")
    }

    else if ( params.mode == "xtea") {
        // Run XTEA on each sample
        XTEA(sample_ch, ref_file, te_ref_file)
    }

    else if ( params.mode == "tremolo") {
        // Convert bams to fastq
        BAM2FASTQ(sample_ch)
        // Create config and yaml files
        PREP_TREMOLO(BAM2FASTQ.out.fastq, ref_file, te_ref_file, tremolo_config_file, tremolo_snk_file)
        // Run TREMOLO on each sample
        TREMOLO(BAM2FASTQ.out.fastq, ref_file, te_ref_file, PREP_TREMOLO.out.tremoloConfig, PREP_TREMOLO.out.tremoloSnk)
    }

    else {
        // Run sTELLeR on each sample
        STELLER(sample_ch, ref_file, te_ref_file)
        // Run TLDR on each sample
        TLDR(sample_ch, ref_file, te_ref_file)
        // Run PALMER for ALUs on each sample
        PALMER_ALU(sample_ch, ref_file, alu_ref_file, "ALU")
        // Run PALMER for L1s on each sample
        PALMER_L1(sample_ch, ref_file, l1_ref_file, "L1")
        // Run PALMER for SVAs on each sample
        PALMER_SVA(sample_ch, ref_file, sva_ref_file, "SVA")
        // Run PALMER for HERVs on each sample
        PALMER_HERV(sample_ch, ref_file, herv_ref_file, "HERV")
        // Run XTEA on each sample
        XTEA(sample_ch, ref_file, te_ref_file)
        // Run bam to fastq conversion for each file
        BAM2FASTQ(sample_ch)
        // Create config and yaml files
        PREP_TREMOLO(BAM2FASTQ.out.fastq, ref_file, te_ref_file, tremolo_config_file, tremolo_snk_file)
        // Run TREMOLO on each sample
        TREMOLO(BAM2FASTQ.out.fastq, ref_file, te_ref_file, PREP_TREMOLO.out.tremoloConfig, PREP_TREMOLO.out.tremoloSnk)
    }
}