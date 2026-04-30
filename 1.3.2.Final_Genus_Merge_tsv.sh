#!/bin/bash

set -euo pipefail
shopt -s nullglob

# ===============================
# LOAD PYTHON
# ===============================
module load python-3.9.18

# ===============================
# PATHS
# ===============================
IN_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/filtered_genus_bracken"
SCRIPT="/nfs/users/nfs_m/ma32/tools/Bracken/analysis_scripts/combine_bracken_outputs.py"

OUT_FILE="${IN_DIR}/genus_filtered_matrix.tsv"

# ===============================
# CHECK INPUT
# ===============================
cd "$IN_DIR"

FILES=(*.filtered.bracken)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "❌ No .filtered.bracken files found!"
    exit 1
fi

echo "Found ${#FILES[@]} files"

# ===============================
# RUN COMBINE
# ===============================
echo "Combining Bracken outputs..."

python3 "$SCRIPT" \
    --files *.filtered.bracken \
    -o "$OUT_FILE"

echo "✅ Matrix generated: $OUT_FILE"
