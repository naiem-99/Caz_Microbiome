#---------------------------Submit the bash script---------------------------------------------
# script name: run_bracken_all_level.sh
bsub.py 5 brac2 -G team216f ./run_bracken_all_level.sh 

## Bracken run for Phylum using multiple kraken2 report files
#!/bin/bash

# =======================
# ----------------------------Setting the PATHS---------------------------------
# =======================
KRAKEN_DB="/data/pam/team216/ma32/scratch/metagenome/caz/kraken2_braken_db"
REPORT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/report_kraken2"
OUT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/bracken_all_level"

READ_LEN=150
THREADS=8
# --------------------------Taxonomic levels to run-------------------------------------
LEVELS=("S" "F" "P")

# =======================
# --------------------------SETUP OUTPUT FOLDERS-----------------------------------------
# =======================
mkdir -p "${OUT_DIR}"
mkdir -p "${OUT_DIR}/kraken_reports"

# =======================
# -------------------------LOOP THROUGH Each LEVELS---------------------------------------
# =======================
for LEVEL in "${LEVELS[@]}"; do

    echo "====================================="
    echo "Running Bracken at taxonomic level: ${LEVEL}"
    echo "====================================="

    mkdir -p "${OUT_DIR}/${LEVEL}"
    mkdir -p "${OUT_DIR}/kraken_reports/${LEVEL}"

    # =======================
    # LOOP THROUGH .kreport FILES
    # =======================
    for REPORT in "${REPORT_DIR}"/*.kreport; do

        SAMPLE=$(basename "${REPORT}" .kreport)

        echo "Running Bracken for ${SAMPLE} at level ${LEVEL} ..."

        # ---- Run Bracken ----
        bracken \
            -d "${KRAKEN_DB}" \
            -i "${REPORT}" \
            -o "${OUT_DIR}/${LEVEL}/${SAMPLE}.${LEVEL}.bracken" \
            -r "${READ_LEN}" \
            -l "${LEVEL}" \
            -t "${THREADS}"

        # ---- Convert to Kraken-style report ----
        bracken_to_kraken_report \
            -i "${OUT_DIR}/${LEVEL}/${SAMPLE}.${LEVEL}.bracken" \
            -o "${OUT_DIR}/kraken_reports/${LEVEL}/${SAMPLE}.${LEVEL}.bracken.report"

    done

    # =======================
    # -------------------------------Combine Outputs Per Level------------------------------
    # =======================
    echo "Combining Bracken outputs for level ${LEVEL}..."

    bracken_combine_outputs.py \
        --files "${OUT_DIR}/${LEVEL}"/*.bracken \
        -o "${OUT_DIR}/combined_${LEVEL}.txt"

done

echo "All Bracken levels processed successfully!"

