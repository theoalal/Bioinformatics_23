#!/bin/bash
#SBATCH --account=project_2005863
#SBATCH --job-name=read_extraction
#SBATCH --error=errors_virus_read_ric.txt
#SBATCH --output=out_virus_read_ric.txt
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=12:00:00

# Load dependencies
module load biokit
module load seqkit

# Input directories
KRAKEN_DIR="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/ricinus_kraken_results"
FASTQ_DIR="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/I_ricinus_mapped/unmapped"
OUT_DIR="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/extracted_viruses_ricinus"

# Metadata file (tab-delimited): Virus_Name<TAB>TaxID
TAXA_FILE="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/viruses_to_extract.tsv"
# 694009  Severe acute respiratory syndrome-related coronavirus
# 2789412 Sara tick phlebovirus
# 3052230 Hepacivirus hominis
# 2829172 Jilin partiti-like virus 1
# 2304647 Beiji nairovirus
# 2789418 Gakugsa tick virus
# 2789418 Gakugsa tick virus
# 2955291 Alphainfluenzavirus influenzae

# Create output directory
mkdir -p "$OUT_DIR"

# Loop through each virus and taxid in the metadata file
while IFS=$'\t' read -r taxid virus; do

    # Create subdirectory for each virus
    vdir="${OUT_DIR}/${virus// /_}"
    mkdir -p "$vdir"
    echo -e "\n[INFO] Processing virus: $virus (TaxID: $taxid)\n"

    # Loop through Kraken output files
    for k in ${KRAKEN_DIR}/*.kraken.out.gz; do
        s="$(basename "$k" .PE.kraken.out.gz)"  # Extract sample name
        fq1=$(find "$FASTQ_DIR" -type f -name "*${s}*_I_ricinus_unmapped_R1.fastq.gz" | head -n1)
        fq2=$(find "$FASTQ_DIR" -type f -name "*${s}*_I_ricinus_unmapped_R2.fastq.gz" | head -n1)

echo "Filename is:"
echo $k
echo "Sample name is:"
echo $s
echo "Fastq file R1:"
echo $fq1
echo "Fastq file R2:"
echo $fq2

        # Check for paired reads
        if [[ -z "$fq1" || -z "$fq2" ]]; then
            echo "[WARN] FASTQ pair missing for $s; skipping..."
            continue
        fi

        # Extract read IDs matching the taxid
        echo "[INFO] Extracting TaxID $taxid reads from $s"
        zgrep "(taxid ${taxid})" "$k" | awk '{print $2}' > "tmp_${s}_${taxid}_ids.txt"
        if [[ ! -s "tmp_${s}_${taxid}_ids.txt" ]]; then
            echo "[INFO] No reads found for $virus in $s"
            rm -f "tmp_${s}_${taxid}_ids.txt"
            continue
        fi

        # Filter R1 and R2 FASTQs using seqkit
        seqkit grep -f "tmp_${s}_${taxid}_ids.txt" "$fq1" -j 4 \
            -o "${vdir}/${s}_${virus// /_}_R1.fastq.gz"
        seqkit grep -f "tmp_${s}_${taxid}_ids.txt" "$fq2" -j 4 \
            -o "${vdir}/${s}_${virus// /_}_R2.fastq.gz"
        echo "[DONE] Extracted reads for $virus from sample $s"
        rm -f "tmp_${s}_${taxid}_ids.txt"
    done
done < "$TAXA_FILE"
echo -e "\n Extraction complete for all viruses listed in $TAXA_FILE\n"
