#!/bin/bash
#HEADER FOR SUBMITTED SCRIPTS
#SBATCH --job-name=Variant_Calling
#SBATCH --partition=batch 
#SBATCH  --nodes=1 
#SBATCH --ntasks-per-node=32
#SBATCH --time=100:00:00
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
ml SAMtools/0.1.20-GCC-10.2.0
ml BCFtools/1.6-foss-2019b
ml parallel/20190922-GCCcore-8.3.0

# # setting directories
Home=/scratch/drt83172/Wallace_lab/SNP_Finder/Data
Scripts=/scratch/drt83172/Wallace_lab/SNP_Finder/Scripts
RawProgenyMerged=/scratch/drt83172/Wallace_lab/TallFescue/Data/RawProgenyData_Merged
RawParentsMerged=/scratch/drt83172/Wallace_lab/TallFescue/Data/RawParentData_Merged
Inter=$Home/Inter
VCFs=$Home/VCFs
Lists=$Home/Lists


if [ ! -e $parenteny_KMERS ] ; then mkdir $parenteny_KMERS; fi
if [ ! -e $InterFiles ] ; then mkdir $InterFiles; fi
if [ ! -e $RawProgenyMerged ] ; then mkdir $RawProgenyMerged; fi
if [ ! -e $RawParentsMerged ] ; then mkdir $RawParentsMerged; fi
if [ ! -e $Inter ] ; then mkdir $Inter; fi
if [ ! -e $VCFs ] ; then mkdir $VCFs; fi
if [ ! -e $Lists ] ; then mkdir $Lists; fi



# # Setting file variables
RefGenome=/scratch/drt83172/Wallace_lab/TallFescue/Data/Refrence/Lolium_pernne/Loliumpernne_genome.fasta


############### Code Start ################
# #indexes genome for BWA (should be indexed)
# bwa index $RefGenome

# # aligns my files to genome
> $Inter/BWAcommands2.sh
> $Lists/parents.txt
for file in $(ls $RawParentsMerged) 
    do 
    arrIN=(${file//./ }) # makes the variable into an array that I sepetate by "."
    prog=${arrIN[0]}
    echo "$parent" >> $Lists/parents.txt
    echo "bwa mem -t 15 $RefGenome $RawParentsMerged/$file > $Inter/$parent.sam" >> $Inter/BWAcommands2.sh
done
cat $Inter/BWAcommands2.sh | parallel --jobs 2 --progress
echo "*********** bwa mem done ***********"

# #compresses .sam file to .bam file
touch $Inter/Sam2BamCommands2.sh
for prog in $(cat $Lists/parents.txt)
do
  echo "samtools view -S -b $Inter/$parent.sam > $Inter/$parent.bam" >> $Inter/Sam2BamCommands2.sh
done
cat $Inter/Sam2BamCommands2.sh | parallel --jobs 5 --progress
echo "*********** samtools view 1 done ***********"

# # Removing files you dont need
# rm $Inter/*.sam

# #sorts .bam file and then marks duplicates
> $Inter/SamSortCommands2.sh
> $Inter/SamDupesCommands2.sh
for prog in $(cat $Lists/parents.txt)
do
    echo "samtools sort $Inter/$parent.bam -o $Inter/${parent}_sorted.bam" >> $Inter/SamSortCommands2.sh
    echo "samtools markdup $Inter/${parent}_sorted.bam $Inter/${parent}_align_marked_sorted.bam" >> $Inter/SamDupesCommands2.sh
done
cat $Inter/SamSortCommands2.sh | parallel --jobs 5 --progress
cat $Inter/SamDupesCommands2.sh | parallel --jobs 5 --progress
echo "*********** samtools sort and markdups done ***********"

# # Removing files you dont need
for prog in $(cat $Lists/parents.txt)
do
    rm $Inter/$parent.bam
    rm $Inter/${parent}_sorted.bam
done

# #indexes the ref genome for mpileup to use 
# samtools faidx $RefGenome
# echo "*********** samtools faidx done ***********"







