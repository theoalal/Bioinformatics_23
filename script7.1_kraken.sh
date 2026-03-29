#!/bin/bash
#SBATCH --job-name=KRKN_ricinus
#SBATCH --account=project_2005863
#SBATCH --time 24:00:00
#SBATCH --mem=260G
#SBATCH --partition=small
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH -o output_ricinus_KRAKEN_%j.txt
#SBATCH -e errors_ricinus_KRAKEN_%j.txt
#SBATCH --gres=nvme:500
##SBATCH --mail-type=username@server.fi # Uncomment to enable mail

echo "Job starts"
echo $(date +%d%b%Y_%H%m)

# Load necessary modules for taxonomic classification and abundance estimation
module load biokit kraken bracken

# --------------------------------------------------------------
# Set paths to databases used by Kraken2 and Bracken
# --------------------------------------------------------------

# Kraken2 database path
# We use the complete Kraken2 database (core_nt Database),
# which includes sequences from NCBI RefSeq and GenBank.
# Other available Kraken2 databases can be found at:
# https://benlangmead.github.io/aws-indexes/k2

KRAKEN_DB=/scratch/project_2005451/krknnt.db

# Bracken database path
# Bracken is used to **estimate species-level abundance**
# from Kraken2 classification results using k-mer distributions.
 BRACKEN_DB=/scratch/project_2005451/krknnt.db/database150mers.kmer_distrib

# To make script run faster, copy the database to LOCAL_SCRATCH:
cp /scratch/project_2005451/krknnt.db/* $LOCAL_SCRATCH
echo "This is local scratch"
ls $LOCAL_SCRATCH
KRAKEN_DB=$LOCAL_SCRATCH
echo "This is KRAKEN_DB"
ls $KRAKEN_DB

echo "local scratch size"
du -sh $LOCAL_SCRATCH

# --------------------------------------------------------------
# Set input and output directories
# --------------------------------------------------------------

# Use $USER to personalize input and output directories
# Trimmed sequencing reads are stored in "$USER/trimmed_data"
INPUTDIR=/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis/I_ricinus_mapped/unmapped

# Results from Kraken2 and Bracken will be stored in "$USER/kraken_results"
OUTPUTDIR=/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis/ricinus_kraken_results

# Create output directories (if they don’t exist)
mkdir -p $OUTPUTDIR
mkdir -p $OUTPUTDIR/braken

# --------------------------------------------------------------
# Process each paired-end FASTQ file in the input directory
# --------------------------------------------------------------

for f in $INPUTDIR/*_unmapped_R1.fastq.gz
do
    echo "Processing $f"

    # Extract file name without path
    withpath="${f}"
    filename="${withpath##*/}" # Extract filename from path

    # Remove "_filtered_1P.fastq.gz" to get the sample base name
    base="${filename%*_unmapped_R1.fastq.gz}"

    # Extract the prefix (assumed to be the first part of the file name before an underscore)
    prfx=$(cut -d_ -f1 <<< "$filename")

    # Define directory for paired reads
    dir=$(dirname ${f})/$base

    echo "File Path: $withpath"
    echo "File Name: $filename"
    echo "Sample Prefix: $prfx"
    echo "Sample Directory: $dir"

    # --------------------------------------------------------------
    # Run Kraken2 for taxonomic classification
    # --------------------------------------------------------------

	# Kraken2: Classify reads based on k-mer matches against the Kraken2 database.
	#
	# Kraken2 Algorithm Summary:
	# 1. Splits each read into k-mers and matches them against the Kraken2 database.
	# 2. Assigns taxonomy based on the lowest common ancestor (LCA) approach.
	# 3. Generates a classification report listing the taxonomic assignments of each read.
	#
	# Kraken2 Options:
	# --gzip-compressed : Input files are in compressed (.gz) format.
	# --db : Specifies the Kraken2 database to use.
	# --threads : Uses the number of CPU cores allocated by SLURM.
	# --use-names : Displays taxonomic names instead of just taxonomic IDs.
	# --paired : Indicates paired-end sequencing data.
	# --report : Saves a summary report with read classifications at different taxonomic levels.
	# --output : Stores full classification results for each read.

    kraken2 --gzip-compressed \
	--db $KRAKEN_DB \
	--threads $SLURM_CPUS_PER_TASK \
	--use-names \
	--paired \
	--report $OUTPUTDIR/"${prfx}".PE.rep.txt \
	--output $OUTPUTDIR/"${prfx}".PE.kraken.out \
    	"${dir}"_unmapped_R1.fastq.gz \
		"${dir}"_unmapped_R2.fastq.gz

    # --------------------------------------------------------------
    # Estimate species-level abundance using Bracken
    # --------------------------------------------------------------


	# Bracken: Re-estimate species abundance from Kraken2 output.
	#
	# Why Bracken?
	# - Kraken2 classifies reads but does not provide accurate abundance estimates.
	# - Bracken redistributes reads assigned at higher taxonomic levels to species level.
	# - Uses k-mer distributions to estimate the true abundance of each species.
	#
	# Bracken Options:
	# -i : Input Kraken2 report.
	# -k : Bracken k-mer distribution database.
	# -t : Minimum number of reads needed for species-level assignment (default: 20).
	# -o : Output file for estimated species-level abundance.
	# > : Redirects output to a separate report file.
    # Bracken refines Kraken2 results by estimating **true species abundance**
    # It does this by re-distributing reads across the taxonomic tree
    # -t 20: Only consider taxa with at least 20 reads assigned

    est_abundance.py -i $OUTPUTDIR/"${prfx}".PE.rep.txt \
	-k $BRACKEN_DB \
	-t 20 \
	-o $OUTPUTDIR/braken/"${prfx}".PE.standard.150.bracken.S.out \
	> $OUTPUTDIR/braken/"${prfx}".PE.bracken.150.report.S.txt

    # --------------------------------------------------------------
    # Compress Kraken2 output to save space
    # --------------------------------------------------------------

    module load pigz  # Load pigz for fast compression

    pigz -p $SLURM_CPUS_PER_TASK $OUTPUTDIR/"${prfx}".PE.kraken.out

done

echo "Job efficiency"
seff $SLURM_JOBID
echo "Time and memory usage:"
sacct -o reqmem,maxrss,averss,elapsed,alloccpus -j $SLURM_JOBID
echo $(date +%d%b%Y_%H%m)
echo "Job finished"
