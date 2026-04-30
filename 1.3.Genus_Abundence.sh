#!/bin/bash

# =======================
# PATHS
# =======================
KRAKEN_DB="/data/pam/team216/ma32/scratch/metagenome/caz/kraken2_braken_db"
REPORT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/report_kraken2"
OUT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/brackenGenus_output"

READ_LEN=150
LEVEL="G"   # S=species, G=genus, etc.

# =======================
# SETUP OUTPUT FOLDERS
# =======================
mkdir -p "${OUT_DIR}"
mkdir -p "${OUT_DIR}/kraken_reports"

# Prevent empty loop issue
shopt -s nullglob

# =======================
# LOOP THROUGH REPORTS
# =======================
for REPORT in "${REPORT_DIR}"/*.kreport; do

    SAMPLE=$(basename "${REPORT}" .kreport)

    echo "Running Bracken for ${SAMPLE} ..."

    # ---- Run Bracken ----
    bracken \
        -d "${KRAKEN_DB}" \
        -i "${REPORT}" \
        -o "${OUT_DIR}/${SAMPLE}.bracken" \
        -r "${READ_LEN}" \
        -l "${LEVEL}"

    # ---- Convert to Kraken-style report ----
    bracken_to_kraken_report \
        -i "${OUT_DIR}/${SAMPLE}.bracken" \
        -o "${OUT_DIR}/kraken_reports/${SAMPLE}.bracken.report"

done

echo "Bracken abundance + Kraken-style reports generated successfully!"
