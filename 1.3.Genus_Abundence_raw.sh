#!/bin/bash

export PATH="/nfs/users/nfs_m/ma32/tools/Bracken:$PATH"

KRAKEN_DB="/data/pam/team216/ma32/scratch/metagenome/caz/kraken2_braken_db"
REPORT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/report_kraken2"
OUT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/brackenGenus_output"

READ_LEN=150
LEVEL="G"

mkdir -p "${OUT_DIR}"

shopt -s nullglob

for REPORT in "${REPORT_DIR}"/*.kreport; do

    SAMPLE=$(basename "${REPORT}" .kreport)

    echo "Running Bracken for ${SAMPLE} ..."

    bracken \
        -d "${KRAKEN_DB}" \
        -i "${REPORT}" \
        -o "${OUT_DIR}/${SAMPLE}.bracken" \
        -r "${READ_LEN}" \
        -l "${LEVEL}"

done

echo "Bracken genus abundance completed!"
