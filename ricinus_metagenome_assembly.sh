#!/bin/bash
#SBATCH --job-name=SPADES_ricinus
#SBATCH --account=project_2005863
#SBATCH --time 14-00:00:00
#SBATCH --mem=100G
#SBATCH --partition=longrun
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH -o output_ricinus_SPADES1_%j.txt
#SBATCH -e errors_ricinus_SPADES1_%j.txt
#SBATCH --gres=nvme:500
#SBATCH --mail-type=BEGIN # Uncomment to enable mail


echo "Job starts"
echo $(date +%d%b%Y_%H%m)

module load biokit spades

INPUTDIR=/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis/I_ricinus_mapped/unmapped

OUTPUTDIR=/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis/I_ricinus_metagenome

# Create output directories (if they don’t exist)
mkdir -p $OUTPUTDIR

for f in $INPUTDIR/*_I_ricinus_unmapped_R1.fastq.gz
do
    echo "Processing $f"

    # Extract file name without path
    withpath="${f}"
    filename="${withpath##*/}" # Extract filename from path

    # Remove "_filtered_1P.fastq.gz" to get the sample base name
    base="${filename%*_I_ricinus_unmapped_R1.fastq.gz}"

    # Extract the prefix (assumed to be the first part of the file name before an underscore)
    prfx=$(cut -d_ -f1 <<< "$filename")

    # Define directory for paired reads
    dir=$(dirname ${f})/$base

    echo "File Path: $withpath"
    echo "File Name: $filename"
    echo "Sample Prefix: $prfx"
    echo "Sample Directory: $dir"


mkdir -p $OUTPUTDIR/"${prfx}"


metaspades.py -1 $INPUTDIR/"${prfx}"_I_ricinus_unmapped_R1.fastq.gz -2 $INPUTDIR/"${prfx}"_I_ricinus_unmapped_R2.fastq.gz -o $OUTPUTDIR/"${prfx}" -t $SLURM_CPUS_PER_TASK -m $SLURM_MEM_PER_NODE

done

echo "Job efficiency"
seff $SLURM_JOBID
echo "Time and memory usage:"
sacct -o reqmem,maxrss,averss,elapsed,alloccpus -j $SLURM_JOBID
echo $(date +%d%b%Y_%H%m)
echo "Job finished"
