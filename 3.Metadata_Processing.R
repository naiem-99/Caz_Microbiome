# ===============================
# 0. SETUP
# ===============================
setwd("D:/2.Caz_Microbiome")
getwd()

rm(list = ls());gc()
library(dplyr)

# ===============================
# 1. READ & MERGE TREATMENT FILES
# ===============================
read_and_merge_treatment <- function(file_a, file_b) {
  ta <- read.csv(file_a, check.names = FALSE)
  tb <- read.csv(file_b, check.names = FALSE)
  inner_join(ta, tb, by = "PID")}

# ===============================
# 2. PROCESS TREATMENT DATA
# ===============================
process_treatment_data <- function(treatment_df) {
  treatment_df %>%
    group_by(TreatID) %>%
    mutate(Type = ifelse(n() == 1, "Unique", "Multiple")) %>%
    ungroup() %>%
    distinct(TreatID, .keep_all = TRUE) %>%
    mutate(
      CAZ_HH = sub("^(CAZ-[^-]+)-.*$", "\\1", PID))}

# ===============================
# 3. READ & FILTER CAZ METADATA
# ===============================
read_caz_metadata <- function(metadata_file) {
  read.csv(metadata_file, check.names = FALSE) %>%
    filter(!TP %in% c("NC", "EC"))}

# ===============================
# 4. MERGE METADATA + TREATMENT
# ===============================
merge_metadata_treatment <- function(meta_df, treatment_df) {
  inner_join(meta_df, treatment_df, by = "CAZ_HH")}

# ===============================
# 5. MAIN PIPELINE
# ===============================

# Treatment data
Treatment_Data <- read_and_merge_treatment(
  "Treatmentcode_A.csv",
  "Treatmentcode_B.csv")

Treatment_Data_P <- process_treatment_data(Treatment_Data)

table(Treatment_Data_P$Type)
dim(Treatment_Data_P)

# CAZ metadata
Caz_Meta_Data <- read_caz_metadata("CAZ-metadata-simple.csv")

# Merge metadata + treatment
Merged_Meta <- merge_metadata_treatment(
  Caz_Meta_Data,
  Treatment_Data_P)

write.csv(Merged_Meta, "Merged_CAZ_Meta.csv", row.names = FALSE)

table(Merged_Meta$TP)
table(Merged_Meta$TP, Merged_Meta$Treatmentcode)

# Final cleaned metadata
write.csv(Merged_Meta %>% select(SampleID, SampleDescription, ID, CAZ_HH, TP, PID, TreatID, Treatmentcode),"CAZ_Meta_Treatment.csv", row.names = FALSE)

