#!/bin/bash
# Usage: bash preprocess.sh

# Define the directory
fastq_dir="$(dirname "$0")/data/fastq/"
genomeDir="$(dirname "$0")/data/genome/"
genomeFastaFiles="$genomeDir/Homo_sapiens.GRCh38.dna.chromosome.22.fa"
sjdbGTFfile="$genomeDir/Homo_sapiens.GRCh38.110.chr22.gtf"

# remove files not end with .fastq
# find "$fastq_dir" -type f ! -name "*.fastq" -exec rm -f {} \;

# Run STAR on each file
# for file in "$fastq_dir"*.fastq
# do
#   STAR --genomeDir $genomeDir --readFilesIn $file --outFileNamePrefix "$file.fastq"
# done

# Generate quantitative output
# List BAM files in fastq_dir
bamfiles=$(ls $fastq_dir/*.bam)
# Pass BAM files as parameters to featureCounts
featureCounts -T 8 -p -a $genomeDir/Homo_sapiens.GRCh38.110.chr22.gtf \
              -o $fastq_dir/gene_counts.txt -g gene_id -s 1 $bamfiles