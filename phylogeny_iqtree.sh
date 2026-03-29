module load biokit
module load iq-tree

# Align sequences
mafft --auto putative_rdrp_contigs.fa > aligned_rdrp_sequences.fa

# Build a tree with IQ-TREE

iqtree -s aligned_rdrp_sequences.fa -m MFP -bb 1000 -nt AUTO

# -m MFP: Find best model automatically
# -bb 1000: Perform 1000 ultrafast bootstraps

# -nt AUTO: Use all available cores
