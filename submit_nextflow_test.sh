#!/bin/bash -l
#SBATCH --job-name=nf_test
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --partition=celgene_cpu
#SBATCH --ntasks=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00

module load nextflow

#nextflow run longHERV_validation.nf -profile test --mode locate

#nextflow run longHERV_validation.nf -profile test --mode telr \
# --te_ref /scratch/prj/ppn_als_longread/HERV_detection/telr_test_data/library.fasta \
# --ref_fasta /scratch/prj/ppn_als_longread/HERV_detection/telr_test_data/ref_38kb.fasta \
# --samplefile telr_test_samples.txt

nextflow run longHERV_validation.nf -profile test,singularity,create