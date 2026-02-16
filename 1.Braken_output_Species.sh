#!/bin/bash
#Kraken Database
#https://benlangmead.github.io/aws-indexes/k2
# =======================
# PATHS
# =======================
KRAKEN_DB="/data/pam/team216/ma32/scratch/metagenome/caz/kraken2_braken_db"
REPORT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/report_kraken2"
OUT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/bracken_output"

READ_LEN=150
THREADS=8

# Taxonomic level:
# S = species, G = genus, F = family, P = phylum
LEVEL="S"

# =======================
# SETUP OUTPUT FOLDERS
# =======================
mkdir -p "${OUT_DIR}"
mkdir -p "${OUT_DIR}/kraken_reports"

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
        -l "${LEVEL}" \
        -t "${THREADS}"

    # ---- Convert to Kraken-style report ----
    bracken_to_kraken_report \
        -i "${OUT_DIR}/${SAMPLE}.bracken" \
        -o "${OUT_DIR}/kraken_reports/${SAMPLE}.bracken.report"

done

echo "Bracken abundance + Kraken-style reports generated successfully!"

