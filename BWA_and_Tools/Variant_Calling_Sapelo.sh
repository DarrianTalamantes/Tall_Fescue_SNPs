#!/bin/bash
#HEADER FOR SUBMITTED SCRIPTS
#SBATCH --job-name=Variant_Calling
#SBATCH --partition=batch 
#SBATCH  --nodes=1 
#SBATCH --ntasks-per-node=32
#SBATCH --time=80:00:00
#SBATCH --export=NONE
#SBATCH --mem=100gb
#SBATCH --mail-user=drt83172@uga.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/scratch/drt83172/Wallace_lab/SNP_Finder/Out_Files/%x_%j.out 
#SBATCH --error=/scratch/drt83172/Wallace_lab/SNP_Finder/Out_Files/%x_%j.err 

# echo
# echo "Job ID: $PBS_JOBID"
# echo "Queue:  $PBS_QUEUE"
# echo "Cores:  $PBS_NP"
# echo "Nodes:  $(cat $PBS_NODEFILE | sort -u | tr '\n' ' ')"
# echo "mpirun: $(which mpirun)"
# echo

# cd $PBS_O_WORKDIR #to use the directory from which the job is submitted as the working directory (where to find input files or binaries)

# # loaidng modules
ml BWA/0.7.17-GCC-10.3.0
ml SAMtools/1.16.1-GCC-10.2.0
ml BCFtools/1.15.1-GCC-10.2.0
ml parallel/20210322-GCCcore-10.2.0
ml numpy/1.17.1-intel-2019b-Python-3.7.4
ml 
# # setting directories
Home=/scratch/drt83172/Wallace_lab/SNP_Finder/Data
Scripts=/scratch/drt83172/Wallace_lab/SNP_Finder/Scripts
RawProgenyMerged=/scratch/drt83172/Wallace_lab/TallFescue/Data/SubsetRawProgenyData_Merged   
RawParentsMerged=/scratch/drt83172/Wallace_lab/TallFescue/Data/RawParentData_Merged
Inter=$Home/Inter
VCFs=$Home/VCFs
Lists=$Home/Lists
PopInfo=$Home/PopInfo


if [ ! -e $Progeny_KMERS ] ; then mkdir $Progeny_KMERS; fi
if [ ! -e $InterFiles ] ; then mkdir $InterFiles; fi
if [ ! -e $RawParentsMerged ] ; then mkdir $RawParentsMerged; fi
if [ ! -e $RawPareRawParentsMergednts ] ; then mkdir $RawParentsMerged; fi
if [ ! -e $Inter ] ; then mkdir $Inter; fi
if [ ! -e $VCFs ] ; then mkdir $VCFs; fi
if [ ! -e $Lists ] ; then mkdir $Lists; fi


# # Setting file variables
RefGenome=/scratch/drt83172/Wallace_lab/TallFescue/Data/Refrence/Lolium_pernne/Loliumpernne_genome.fasta
NameKey=$PopInfo/progeny_key.csv

############### Code Start ################
# #indexes genome for BWA 
# bwa index $RefGenome

# # # aligns my files to genome
# > $Inter/BWAcommands.sh
# > $Lists/progenies.txt
# for file in $(ls $RawProgenyMerged) 
#     do 
#     arrIN=(${file//./ }) # makes the variable into an array that I sepetate by "."
#     prog=${arrIN[0]}
#     echo $prog >> $Lists/progenies.txt
#     echo "bwa mem -t 8 $RefGenome $RawProgenyMerged/$file > $Inter/$prog.sam" >> $Inter/BWAcommands.sh
# done
# cat $Inter/BWAcommands.sh | parallel --jobs 4 --progress
# echo "*********** bwa mem done ***********"

# # #compresses .sam file to .bam file
# > $Inter/Sam2BamCommands.sh
# for prog in $(cat $Lists/progenies.txt)
# do
#     echo "samtools view -S -b $Inter/$prog.sam > $Inter/$prog.bam"
#     echo "samtools view -S -b $Inter/$prog.sam > $Inter/$prog.bam" >> $Inter/Sam2BamCommands.sh
# done
# cat $Inter/Sam2BamCommands.sh | parallel --jobs 10 --progress
# echo "*********** samtools view 1 done ***********"

# # # Removing files you dont need
# # rm $Inter/*.sam

# #sorts .bam file and then marks duplicates
# > $Inter/SamSortCommands.sh
# > $Inter/SamDupesCommands.sh
# for prog in $(cat $Lists/progenies.txt)
# do
#     TrueName=$(cat $NameKey | grep "$prog" | cut -d "," -f 1)
#     echo $TrueName
#     echo "samtools sort $Inter/$prog.bam -o $Inter/${prog}_sorted.bam" >> $Inter/SamSortCommands.sh
#     echo "samtools markdup $Inter/${prog}_sorted.bam $Inter/${TrueName}_align_marked_sorted.bam" >> $Inter/SamDupesCommands.sh
# done
# cat $Inter/SamSortCommands.sh | parallel --jobs 20 --progress
# cat $Inter/SamDupesCommands.sh | parallel --jobs 20 --progress
# echo "*********** samtools sort and markdups done ***********"

# # # Removing files you dont need
# for prog in $(cat $Lists/progenies.txt)
# do
#     rm $Inter/${prog}_sorted.bam
# done

# # #indexes the ref genome for mpileup to use 
# samtools faidx $RefGenome
# echo "*********** samtools faidx done ***********"

# #Make VCF file for every cross
cat $PopInfo/usable_predicted_parents_double.csv | cut -d "," -f 2,3 | sort | uniq > $Lists/All_Crosses.txt
rm $Lists*_bams.txt 
for cross in $(cat $Lists/All_Crosses.txt)
do 
    echo "current cross is $cross"
    cat $PopInfo/usable_predicted_parents_double.csv | grep $cross | cut -d "," -f 1 > $Lists/${cross}_bams.txt
    >$Lists/${cross}_bams2.txt
    for prog in $(cat $Lists/${cross}_bams.txt)
    do
        echo "$Inter/${prog}_align_marked_sorted.bam" >> $Lists/${cross}_bams2.txt
    done
    a=$(cat $Lists/${cross}_bams.txt | wc -l)
    echo "a is $a" 
    if [ $a -ge 1 ];
    then
        echo "cross $cross has more than 1 progeny"
        bcftools mpileup -f $RefGenome -b $Lists/${cross}_bams2.txt| bcftools call -mv -Ob -o $Bcf_Files/variants.bcf
    else 
        echo "cross $cross has less than 1 progeny"
    fi

done






# Objective: Use list of known corsses to create bam lists for every cross. These bam lists then used to create VCF files
# create a hapmap file from the VCF file using tassel




