#!/bin/bash -l
#SBATCH --job-name=nf_submit
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00

module load nextflow

nextflow run longHERV_validation.nf -profile test
