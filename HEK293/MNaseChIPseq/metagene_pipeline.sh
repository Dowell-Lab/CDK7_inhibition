#!/bin/bash

######## Define variables ########

### Main input variables

annotationbase=nonifn
up5=1000 #upstream window for 5' metagene
down5=1000 #downstream window for 5' metagene
full5=2001 #full window size for 5' metagene (up + down + 1)
projectdir=<project_directory>
annotationdir="$projectdir"/processing_files
scriptdir="$projectdir"/scripts/metagene

### I/O variables - uncomment correct set

indir=<input_directory>
outdir="$projectdir"/metagenes/"$annotationbase"
sizefactors="$annotationdir"/MNase_norm_factors_rseqc_unassigned.txt
expt=total_metagene

scratch=<working_directory>

### Variables set based on above variables

fullannotation="$annotationdir"/annotations/hg38_refseq_genenames_included.bed
annotation5="$scratch"/regions/"$annotationbase"_5prime_"$full5".bed

######## Run scripts ########
### Run annotation creation script to generate correct windows for 5' metagenes
### (happens once for all samples)

# Set up initial files and directories
mkdir -p "$scratch"/regions "$outdir"
rsync "$annotationdir"/annotations/"$annotationbase"_* "$scratch"/regions/
rsync "$fullannotation" "$scratch"/regions/

sbatch "$scriptdir"/metagene_pipeline_annotation_windows.sbatch \
  "$scratch"/regions \
  "$annotationbase" \
  "$annotation5" \
  "$up5" \
  "$down5"

# Annotation creation is fast, so make sure it finishes
sleep 30
rsync "$annotation5" "$outdir"/

### Run 5' metagene script
sbatch "$scriptdir"/metagene_pipeline_5prime.sbatch \
  "$scratch" \
  "$indir" \
  "$sizefactors" \
  "$annotation5" \
  "$full5" \
  "$projectdir" \
  "$outdir"

