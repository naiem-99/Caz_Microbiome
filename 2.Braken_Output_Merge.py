#--------------------Run this scipt where all filtered.braken out exists
#as ------------python3 merge_braken.py-------------------------------------

import glob
import pandas as pd

files = glob.glob("*filtered.bracken")

tables = []

for f in files:
    sample = f.replace("fitered.bracken","")
    df = pd.read_csv(f, sep="\t")
    df = df[["name","new_est_reads"]]
    df = df.rename(columns={"new_est_reads": sample})
    tables.append(df)

merged = tables[0]
for t in tables[1:]:
    merged = merged.merge(t, on="name", how="outer")

merged = merged.fillna(0)
merged.to_csv("species_abundance_matrix.tsv", sep="\t", index=False)
#----------------------------------------------------------------------------------------------------
