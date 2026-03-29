#!/bin/bash
#SBATCH --account=project_2005863
#SBATCH --job-name=unmapped_fastq_metrics
#SBATCH --output=slurm_logs/unmapped_fastq_metrics_%j.out
#SBATCH -e errors_pers_metrics_%j.txt
#SBATCH --partition=small
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=01:00:00

module load seqkit

SAMPLE_LIST="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/metadata/persulcatus_sample_list.txt"
RAW_DIR="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/trimmed_merged_data/I_persul_trimmed"             # raw reads (original before host removal)
UNMAPPED_DIR="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/I_pers_mapped/unmapped"    # or folder with *_I_pers_unmapped_R1.fastq.gz
OUT="/scratch/project_2005863/metatranscriptomics_2025/Theo_analysis_metatranscriptomics/viral_analysis/unmapped_fastq_metrics.tsv"

echo -e "Sample\traw_pairs\tunmapped_pairs\tunmapped_pct_pairs\traw_reads\tunmapped_reads\tunmapped_pct_reads" > "$OUT"
while read -r SAMPLE; do
  raw_r1=$(find "$RAW_DIR" -type f -name "*${SAMPLE}*_filtered_1P*.fastq.gz" | head -n1)
  raw_r2=$(find "$RAW_DIR" -type f -name "*${SAMPLE}*_filtered_2P*.fastq.gz" | head -n1)
  unm_r1=$(find "$UNMAPPED_DIR" -type f -name "*${SAMPLE}*I_pers_unmapped_R1.fastq.gz" | head -n1)
  unm_r2=$(find "$UNMAPPED_DIR" -type f -name "*${SAMPLE}*I_pers_unmapped_R2.fastq.gz" | head -n1)
  if [[ -z "$raw_r1" || -z "$raw_r2" ]]; then

    echo "[WARN] Raw FASTQs missing for $SAMPLE; skipping" >&2
    continue
  fi


  # Use seqkit stats (fast) - fields: file, format, type, num_seqs, ...
  raw_pairs=$(seqkit stats -a "$raw_r1" | awk 'NR==2{print int($4/2)}')   # num_seqs/2 = pairs
  unm_pairs=0
  if [[ -s "$unm_r1" ]]; then

    unm_pairs=$(seqkit stats -a "$unm_r1" | awk 'NR==2{print int($4/2)}')
  fi
  raw_reads=$(seqkit stats -a "$raw_r1" | awk 'NR==2{print $4*2}') # quick approach: r1 seqs *2 approx
  unm_reads=$(seqkit stats -a "$unm_r1" | awk 'NR==2{print $4*2}')


  if [[ "$raw_pairs" -gt 0 ]]; then
    unmapped_pct_pairs=$(awk -v a=$unm_pairs -v b=$raw_pairs 'BEGIN{printf "%.4f", 100*a/b}')
  else
    unmapped_pct_pairs="NA"
  fi
  echo -e "${SAMPLE}\t${raw_pairs}\t${unm_pairs}\t${unmapped_pct_pairs}\t${raw_reads}\t${unm_reads}\t${unmapped_pct_pairs}" >> "$OUT"
done < "$SAMPLE_LIST"

