## -----------------------------------------Merging all bracken files-------------------------------------------

# Activate Python environment
source ~/bracken_env/bin/activate

# Go to folder with Bracken outputs
cd /data/pam/team216/ma32/scratch/metagenome/caz/bracken_all_level/F
## nano merge_bracken.py 
# Run merge script
python merge_bracken.py
#--------------------------------------------------------------------
###!/bin/bash
import glob
import pandas as pd

def merge_level(pattern, level_name, output_name):
    files = glob.glob(pattern)
    if not files:
        print(f"No {level_name} files found.")
        return
    print(f"Merging {len(files)} {level_name} files...")
    tables = []
    for f in files:
        sample = f.replace(pattern.replace("*", ""), "")
        df = pd.read_csv(f, sep="\t")
        df = df[["name", "new_est_reads"]]
        df = df.rename(columns={"new_est_reads": sample})
        tables.append(df)
    merged = tables[0]
    for t in tables[1:]:
        merged = merged.merge(t, on="name", how="outer")

    merged = merged.fillna(0)

    merged.to_csv(output_name, index=False)

    print(f"{level_name} merged → {output_name}")

# ===============================
# Run for all levels
# ===============================

merge_level("*.P.bracken", "Phylum", "phylum_abundance_matrix.csv")
merge_level("*.F.bracken", "Family", "family_abundance_matrix.csv")
merge_level("*.S.bracken", "Species", "species_abundance_matrix.csv")

print("\n All available Bracken levels merged successfully!")

# Deactivate environment
deactivate


