#!/bin/bash
# Usage: bash preprocess.sh


# read fastq files in fastq folder and output the row number, reads number and sequence length
# Define the directory
fastq_dir="$(dirname "$0")/data/fastq/"
log_file="$(dirname "$0")/data/fastq/data_overview.txt"

# Loop over each file in the directory
for file in "$fastq_dir"*.fastq
do
  # Extract the required information and print it
  echo $file >> $log_file
  awk '{if(NR==2) {printf "Seq length: %s\n", length($0)}}' $file >> $log_file
  echo "Row Number: $(awk 'END {print NR}' $file)" >> $log_file
  echo "Reads Number: $(awk 'END {print NR/4}' $file)" >> $log_file
done


# Loop over each unique pair of files in the directory
for file in "$fastq_dir"*_1.fastq
do
  # Get the base name without the _1.fastq suffix
  base_name="${file%_1.fastq}"

  # Define the names of the two files in the pair
  file1="${base_name}_1.fastq"
  file2="${base_name}_2.fastq"

  # Run the desired command on the pair of files
  fastqc $file1 $file2
done


# use STAR to align the reads to the genome
# Define the paths
genomeFastaFiles="$genomeDir/Homo_sapiens.GRCh38.dna.chromosome.22.fa"
sjdbGTFfile="$genomeDir/Homo_sapiens.GRCh38.110.chr22.gtf"
genomeDir="$(dirname "$0")/data/genome/"

# generate index
STAR --runMode genomeGenerate --genomeDir $genomeDir\
     --genomeFastaFiles $genomeFastaFiles --sjdbGTFfile $sjdbGTFfile --genomeSAindexNbases 11

# Run STAR on each file
for file in "$fastq_dir"*_1.fastq
do
  # Get the base name without the _1.fastq suffix
  base_name="${file%_1.fastq}"

  # Define the names of the two files in the pair
  file1="${base_name}_1.fastq"
  file2="${base_name}_2.fastq"
  STAR --runThreadN 12 --genomeDir $genomeDir --readFilesIn $file1 $file2\
  --outFileNamePrefix $base_name'_star' --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts
done


# Generate quantitative output
# List BAM files in fastq_dir
bamfiles=$(ls $fastq_dir/*.bam)
# Pass BAM files as parameters to featureCounts
featureCounts -T 8 -a -p $genomeDir/Homo_sapiens.GRCh38.110.chr22.gtf \
              -o $fastq_dir/gene_counts.txt -g gene_id -s 1 $bamfiles
