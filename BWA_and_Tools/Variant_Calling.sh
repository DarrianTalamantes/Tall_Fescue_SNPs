#!/bin/bash

# Objective: Create a pipline using BWA and sam/bam tools to extract SNPs from joined paired read data.

# Inputs are joined paired read data, a refrence genome 
# Outputs is a VCF file.

# Activating necessary envirnment
# conda activate Alignment

# Setting Directory variables
Data="/home/drt06/Documents/Tall_fescue/Tall_Fescue_SNPS/Tall_Fescue_SNPs/Data/Practice_Data"
Bam_Files="$Data/Bam_Files"
Bcf_Files="$Data/Bcf_Files"
Progeny_Reads="$Data/Merged_Progeny_Reads"
Population_Info="$Data/Population_Info"
# Seting file variables
RefGenome="/home/drt06/Documents/Tall_fescue/Tall_Fescue_SNPS/Tall_Fescue_SNPs/Data/Practice_Data/Ref_Genome/LoliP01.fa"

########## Code Start ##########
# #indexes genome for BWA 
# bwa index $RefGenome

# >$Population_Info/Progeny_List.txt
# # # Make file for list of progeny
# for file in $(ls $Progeny_Reads)
# do
#     arrIN=(${file//./ }) # makes the variable into an array that I sepetate by "."
#     prog=${arrIN[0]}
#     echo $prog >> $Population_Info/Progeny_List.txt
# done

# # # aligns my files to genome

# for file in $(cat $Population_Info/Progeny_List.txt)
# do
# bwa mem -t 4 $RefGenome $Progeny_Reads/$file.fq.gz > $Bam_Files/$file.sam
# done
# echo "*********** bwa mem done ***********"

# #compresses .sam file to .bam file
> $Bam_Files/ListOfBams.txt
for file in $(cat $Population_Info/Progeny_List.txt)
do
samtools view -S -b $Bam_Files/$file.sam > $Bam_Files/$file.bam
samtools sort $Bam_Files/$file.bam -o $Bam_Files/${file}_sorted.bam 
TrueName=$(cat $Population_Info/progeny_key.csv | grep "$file" | cut -d "," -f 1)
echo $TrueName
samtools markdup $Bam_Files/${file}_sorted.bam $Bam_Files/${TrueName}_marked_sorted.bam
echo "$Bam_Files/$Bam_Files/${TrueName}_marked_sorted.bam" >> $Bam_Files/ListOfBams.txt
done
echo "*********** samtools sort and markdups done ***********"

# #indexes the ref genome for mpileup to use 
# samtools faidx $RefGenome
# echo "*********** samtools faidx done ***********"

# # actually find snps now
# # This step can combine multiple bam files into one big bcf files. 
# # combining at this step will let us visualize individual files better to see if there are any problems
bcftools mpileup -f $RefGenome -b $Bam_Files/ListOfBams.txt | bcftools call -mv -Ob -o $Bcf_Files/variants.bcf
echo "*********** samtools mpileup done ***********"



