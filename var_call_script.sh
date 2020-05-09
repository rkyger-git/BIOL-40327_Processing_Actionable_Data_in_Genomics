#!/usr/bin/bash

# file: var_call_script.sh
# Created by Ryan Kyger
# Tools: bwa 0.7.15-r1140, samtools 1.3.1, bcftools 1.3.1
# Description: This script takes reference and read files as input from the user,
# aligns the files with BWA, sorts the output SAM file, performs variant calling, 
# and provides basic variant calling statisitcs.   

# Usage: bash var_call_script_kyger.sh <path/filename to BWA reference> <filename of 1st set of reads> <filename of 2nd set of reads> <path/filename to Samtools mpileup reference>

# User input of path/filename of BWA reference is stored as bwa_ref
echo "------------------------------------------------------------------------------------------------------"
echo "User input check ..."
echo ""
bwa_ref=$1
echo "BWA reference: $bwa_ref"
echo ""

# User input of filename of 1st set of reads is stored as read_1
read_1=$2
echo "1st read pair: $read_1"
echo ""
# extract basename of input read file
basename=${read_1%_*}

# User input of filename of 2nd set of reads is stored as read_2
read_2=$3
echo "2nd read pair: $read_2"
echo ""

# User input of path/filename of Samtools mpileup reference reference is stored as sam_ref
sam_ref=$4
echo "Samtools reference: $sam_ref"
echo "------------------------------------------------------------------------------------------------------"

# Run BWA alignment
echo "Starting alignment ..."
echo ""
bwa mem $bwa_ref $read_1 $read_2 > ${basename}.sam
echo ""
echo "Alignment complete, output file is" ${basename}.sam
echo "------------------------------------------------------------------------------------------------------"

# Sort SAM file
echo "Starting sort ..."
samtools sort ${basename}.sam > ${basename}_sorted.sam
echo "Sort complete, output file is" ${basename}_sorted.sam
echo "------------------------------------------------------------------------------------------------------"

# Run variant calling
echo "Starting variant calling ..."
samtools mpileup -Ou -f $sam_ref ${basename}_sorted.sam | bcftools call -vmO v -o ${basename}_sorted.vcf
echo ""
echo "Variant calling complete, output file is ${basename}_sorted.vcf"
echo "------------------------------------------------------------------------------------------------------"

# Display number of SNPs
# Use grep to remove headers, wc to count the number of SNPs
echo "The total number of SNPs is:" 
grep -v '^#' ${basename}_sorted.vcf | wc -l
echo "------------------------------------------------------------------------------------------------------"

# Display average SNP QUAL score
# Use grep to remove headers, cut to extract the QUAL column, and awk to get the average. 
echo "The average SNP QUAL is:" 
grep -v '^#' ${basename}_sorted.vcf | cut -f6 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }'
echo "------------------------------------------------------------------------------------------------------"
