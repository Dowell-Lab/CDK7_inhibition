#!/bin/bash

######## Define variables ########

### Main input variables

annotationbase=enhancer_peaks
up5=1000 #upstream window for 5' metagene
down5=1000 #downstream window for 5' metagene
full5=2001 #full window size for 5' metagene (up + down + 1)
projectdir=<project_directory>
pfilesdir="$projectdir"/processing_files
scriptdir="$projectdir"/scripts/metagene_bytype

### I/O variables - uncomment correct set
indir=input_directory
outdir="$projectdir"/metagenes/"$annotationbase"
sizefactors="$pfilesdir"/MNase_norm_factors_rseqc_unassigned.txt
peakdir="$pfilesdir"/annotations
annotationfile=HEK293_enhancer_peak_overlap_center.bed
expt=by_type

scratch=working_directory

### Variables set based on above variables

annotation5="$scratch"/regions/"$annotationbase"_5prime_"$full5".bed

######## Run scripts ########
### Run annotation creation script to generate correct windows for 5' and 3' metagenes
### (happens once for all samples)

# Set up initial files and directories
mkdir -p "$scratch"/regions "$outdir"
rsync "$peakdir"/"$annotationfile" "$scratch"/regions/
rsync "$pfilesdir"/annotations/hg38_refseq_genenames_included.bed "$scratch"/regions/

sbatch "$scriptdir"/metagene_pipeline_bytype_annotation_windows.sbatch \
  "$scratch"/regions \
  "$annotationbase" \
  "$scratch"/regions/"$annotationfile" \
  "$annotation5" \
  "$up5" \
  "$down5"

# Annotation creation is fast, so make sure it finishes
sleep 30
rsync "$annotation5" "$outdir"/

### Run 5' metagene script
sbatch "$scriptdir"/metagene_pipeline_bytype_5prime.sbatch \
  "$scratch" \
  "$indir" \
  "$sizefactors" \
  "$annotation5" \
  "$full5" \
  "$projectdir" \
  "$outdir"
