#Before run dox2unix script.sh

#!/bin/bash

set -euo pipefail
shopt -s nullglob

module load python-3.9.18

IN_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/brackenGenus_output"
OUT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/filtered_genus_bracken"

SCRIPT="/nfs/users/nfs_m/ma32/tools/KrakenTools/filter_bracken.out.py"

mkdir -p "$OUT_DIR"

echo "Starting Bracken filtering..."

for f in "$IN_DIR"/*.bracken; do

  base=$(basename "$f" .bracken)

  echo "Processing $base ..."

  python3 "$SCRIPT" \
    -i "$f" \
    -o "$OUT_DIR/${base}.filtered.bracken" \
    --exclude 9605

done

echo "Filtering completed!"
