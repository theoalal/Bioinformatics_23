#!/bin/bash
#SBATCH --job-name=pers_map
#SBATCH --account=project_2005863
#SBATCH --time 72:00:00
#SBATCH --mem=32G
#SBATCH --partition=small
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH -o output_pers_map_%j.txt
#SBATCH -e errors_pers_map_%j.txt
#SBATCH --gres=nvme:500

module load biokit

GENOME=/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis/I_pers_ref_genome/I_pers_index
INPUTDIR=/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis/trimmed_merged_data/I_persul_trimmed
OUTPUTDIR=/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis/I_pers_mapped

mkdir -p $OUTPUTDIR/unmapped


# --rna-strandness FR First read (R1) aligns to forward strand — MOST COMMON for dUTP kits like NEB Ultra II. 
# Library preparation and indexing using New England Biolabs kits.
# E7760L NEBNext® Ultra™ II Directional RNA Library Prep Kit for Illumina.


for file in $INPUTDIR/*_filtered_1P.fastq.gz

do
withpath="${file}"
filename=${withpath##*/}
base="${filename%*_filtered_1P.fastq.gz}"
dir=$(dirname ${file})/$base
prefix=$(echo $file | awk 'BEGIN { FS = "/" } ; {print $(NF)}' | cut -d"_" -f1)

echo "${dir}"
echo "$prefix"

srun hisat2 -p $SLURM_CPUS_PER_TASK \
-x $GENOME \
--rg-id "${prefix}" \
--rg SM:"${prefix}" \
--rg LB:Transcriptomic \
--rg PL:ILLUMINA \
--rg DS:I_pers \
--rna-strandness FR \
-1 $INPUTDIR/"${prefix}"_filtered_1P.fastq.gz \
-2 $INPUTDIR/"${prefix}"_filtered_2P.fastq.gz \
--un-conc-gz $OUTPUTDIR/unmapped/"${prefix}"_I_pers_unmapped \
-S $LOCAL_SCRATCH/"${prefix}"_I_pers_mapped.sam \
--summary-file $OUTPUTDIR/"${prefix}"_I_pers_hisat2_summary.txt

mv $OUTPUTDIR/unmapped/"${prefix}"_I_pers_unmapped.1 \
   $OUTPUTDIR/unmapped/"${prefix}"_I_pers_unmapped_R1.fastq.gz

mv $OUTPUTDIR/unmapped/"${prefix}"_I_pers_unmapped.2 \
   $OUTPUTDIR/unmapped/"${prefix}"_I_pers_unmapped_R2.fastq.gz


srun samtools view -@ $SLURM_CPUS_PER_TASK -bS \
$LOCAL_SCRATCH/"${prefix}"_I_pers_mapped.sam > \
$LOCAL_SCRATCH/"${prefix}"_I_pers_mapped.bam

# keep primary mapped reads only
srun samtools view -@ $SLURM_CPUS_PER_TASK -F260 \
$LOCAL_SCRATCH/"${prefix}"_I_pers_mapped.bam \
-o  $LOCAL_SCRATCH/"${prefix}"_I_pers.uniq_mapped.bam

srun samtools sort  -@ $SLURM_CPUS_PER_TASK \
$LOCAL_SCRATCH/"${prefix}"_I_pers.uniq_mapped.bam \
-o $OUTPUTDIR/"${prefix}"_I_pers.uniq_mapped.sorted.bam

srun samtools index -@ $SLURM_CPUS_PER_TASK \
$OUTPUTDIR/"${prefix}"_I_pers.uniq_mapped.sorted.bam

rm $LOCAL_SCRATCH/"${prefix}"_I_pers_mapped.sam
rm $LOCAL_SCRATCH/"${prefix}"_I_pers_mapped.bam
rm $LOCAL_SCRATCH/"${prefix}"_I_pers.uniq_mapped.bam

done


