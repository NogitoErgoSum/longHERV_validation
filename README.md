# Systematic comparative benchmarking of computational methods for the detection of transposable elements in long-read sequencing data
[![CI](https://github.com/NogitoErgoSum/longHERV_validation/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/NogitoErgoSum/longHERV_validation/actions/workflows/ci.yml)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A525.04.0-23aa62.svg)](https://www.nextflow.io/)
[![License: MIT](https://img.shields.io/github/license/NogitoErgoSum/longHERV_validation)](LICENSE)
![Repo Size](https://img.shields.io/github/repo-size/Sulstice/global-chem)
[![bioRxiv](https://img.shields.io/badge/bioRxiv-10.1101%2F2025.09.29.679192-b31b1b)](https://doi.org/10.1101/2025.09.29.679192)

A Nextflow pipeline that runs several long-read transposable element (TE) insertion callers on the same aligned BAM files, so their calls can be compared side by side. It was used to benchmark non-reference TE detection (Alu, L1, SVA and HERV) on simulated ONT reads, GIAB HG002 and post-mortem brain samples in the accompanying preprint.

![250918_nf_workflow_noTREMOLO](https://github.com/user-attachments/assets/6cc2d1ca-16ed-424f-b819-bf017b5007ab)

Tools
Tool	--mode	Container
sTELLeR	steller	kristinebilgrav/steller
TLDR	tldr	quay.io/sarahbeecroft9/tldr
PALMER	palmer_alu, palmer_l1, palmer_sva, palmer_herv, or palmer for all four	quay.io/ymostovoy/lr-palmer
xTea	xtea	quay.io/ymostovoy/lr-xtea
TELR	telr	Conda (telr), see the note in modules/TELR.nf
TrEMOLO	tremolo	Singularity image only; BAMs are converted to FASTQ first
LOCATE	locate	huzr14830/locate

The default mode, all, runs every tool except LOCATE.

Requirements
Nextflow ≥ 25.04.0
Singularity/Apptainer (HPC) or Docker (local and CI)
Conda or Mamba, for TELR only
Quick start

Run one tool on the small chr22 test dataset bundled in tests/data/:

bash
git clone https://github.com/NogitoErgoSum/longHERV_validation.git
cd longHERV_validation
nextflow run longHERV_validation.nf -profile test,docker --mode steller

Results are written to results_test/.

Usage
bash
nextflow run longHERV_validation.nf \
    -profile cluster \
    --samplefile samples.txt \
    --mode all \
    --outdir results/
Input

--samplefile is a text file with one coordinate-sorted, indexed BAM per line:

/path/to/sample1.bam
/path/to/sample2.bam

Each BAM needs a .bai index next to it (sample1.bam.bai). The sample name is taken from the BAM file name.

Reference files
Parameter	Description
--ref_fasta	Reference genome FASTA (GRCh38), with .fai index
--te_ref	TE consensus sequences for all families (Alu, L1, SVA, HERV)
--alu_ref, --l1_ref, --sva_ref, --herv_ref	One TE consensus FASTA per family, used by PALMER
--tremolo_config, --tremolo_snk	TrEMOLO config and Snakemake file (templates in resources/tremolo/)
--locate_resource_dir	LOCATE GRCh38 resource directory

TE FASTA headers follow the >Family:subfamily format, e.g. >L1:L1HS or >Alu:AluYa5. See tests/data/TEsequences_SVA_HERV_ALU_L1.fasta for an example.

The defaults in nextflow.config point to our HPC. Override them on the command line or in your own config with -c my.config.

Profiles
Profile	Use
cluster	Full runs on SLURM with Singularity, with per-tool resources and retries
test	Small chr22 test data in tests/data/, run on the local executor
docker	Use Docker instead of Singularity/Conda
Output

Results are grouped by sample, then by tool:

results/
└── <sample>/
    ├── sTELLeR/          # <sample>_repeats.vcf, fasta/
    ├── TLDR/             # <sample>.haplotagged.table.txt
    ├── TELR/             # VCF, BED, JSON and FASTA outputs
    ├── PALMER/
    │   ├── ALU/          # <sample>_calls.txt, <sample>_TSD_reads.txt
    │   ├── L1/
    │   ├── SVA/
    │   └── HERV/
    ├── XTEA/             # per-family merged results
    ├── TrEMOLO/
    └── LOCATE/           # result.tsv, result.vcf
Testing

On every push to main, GitHub Actions runs each tool on the test data with -profile test,docker. TrEMOLO, LOCATE and TELR are not part of CI because they need a Singularity-only image, a large external resource directory and a patched Conda environment, respectively.

Citation

If you use this pipeline, please cite:

Systematic comparative benchmarking of computational methods for the detection of transposable elements in long-read sequencing data. bioRxiv (2025). doi:10.1101/2025.09.29.679192

Please also cite the individual tools you run.

License

MIT
