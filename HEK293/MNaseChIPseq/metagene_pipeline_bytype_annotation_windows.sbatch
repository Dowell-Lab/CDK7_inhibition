#!/bin/bash
#SBATCH --job-name=metagene_bytype_annotation      # Job name
#SBATCH --mail-type=NONE         # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=<email> # Where to send mail
#SBATCH --nodes=1
#SBATCH --ntasks=1               # Number of CPU (processer cores i.e. tasks)
#SBATCH --time=00:05:00         # Time limit hrs:min:sec
#SBATCH --partition=short
#SBATCH --mem=8gb               # Memory limit
#SBATCH --output=<path_to_eo>/%x_%j.out
#SBATCH --error=<path_to_eo>/%x_%j.err


##### OUTPUT RUN PARAMETERS #######################

# Calculate the number of processors allocated to this run.
NPROCS=$SLURM_CPUS_ON_NODE

### Display the job context
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Using ${NPROCS} processors

##### LOAD MODULES AND RLIB LOCATION ##############

module load bedtools/2.28.0

##### SPECIFY VARIABLES ###########################

scratch=$1
annotationbase=$2
annotationfile=$3
annotation5=$4
up5=$5
down5=$6
genome=<path_to>/hg38.fa
chromsizes=<path_to>/hg38.chrom.sizes
fullgene_annotation=hg38_refseq_genenames_included.bed

###################################################

######## 5' metagene annotation creation ########

# Pad window to each side and make sure no overlap with other genes or TSS
bedtools slop -l "$up5" -r "$down5" -s \
    -i "$annotationfile" \
    -g "$chromsizes" \
    > "$scratch"/tmp.bed

grep -v -- -1 "$scratch"/tmp.bed \
    > "$scratch"/tmp2.bed

bedtools intersect -wa \
    -a "$scratch"/"$fullgene_annotation" \
    -b "$annotationfile" \
    > "$scratch"/"$fullgene_annotation"_subtract.bed

bedtools intersect -wa -v \
    -a "$scratch"/"$fullgene_annotation" \
    -b "$scratch"/"$fullgene_annotation"_subtract.bed \
    > "$scratch"/rest_of_genes_tocompare.bed

bedtools intersect -wa -v \
    -a "$scratch"/tmp2.bed \
    -b "$scratch"/rest_of_genes_tocompare.bed \
    > "$annotation5"

rm "$scratch"/tmp*
rm "$scratch"/"$fullgene_annotation"*
rm "$scratch"/rest_of_genes_tocompare.bed
rm "$annotationfile"


# Final time stamp
echo Time is `date`
