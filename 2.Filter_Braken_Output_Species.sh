#---- download the necessary files for run KrakenTools
#git clone https://github.com/jenniferlu717/KrakenTools.git

module avail python
module load PaM/environment
module load python-3.9.18
#--------------------------------------------------------------
#before running the script 'run dos2unix braken_filtered_v2.sh
#then run as bash braken_filtered_v2.sh
#-------------------------------------------------------------------------
#!/bin/bash
# ===============================
# LOAD MODULE (if needed)
# ===============================
module load python-3.9.18

# ===============================
# PATHS
# ===============================
IN_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/bracken_output"
OUT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/filtered_bracken"
SCRIPT="/data/pam/team216/ma32/scratch/metagenome/caz/krakentools_output/KrakenTools/filter_bracken.out.py"

# ===============================
# CREATE OUTPUT DIRECTORY
# ===============================
mkdir -p "$OUT_DIR"

# ===============================
# RUN FILTER
# ===============================
echo "Starting Bracken filtering..."

for f in "$IN_DIR"/*.bracken; do
  base=$(basename "$f" .bracken)

  echo "Processing $base ..."

  python3 "$SCRIPT" \
    -i "$f" \
    -o "$OUT_DIR/${base}.filtered.bracken" \
    --exclude 9606
done

echo "Filtering completed!"
#--------------------------------------------------------------
