#------------------Follow this tutorial------------------------------------------------------------
#https://yiluheihei.github.io/microbiomeMarker/articles/microbiomeMarker-vignette.html
#---------------------------------------------------------------------------------------------------
library(DECIPHER)
library("gsl")
#BiocManager::install("microbiomeMarker")
library(microbiomeMarker)
#----------------------------------------------------------------------------------------------------
library(phyloseq)
library(dplyr)
library(tibble)
#-----------------------------------------------------------------------------------------------------
dir.create("1.Results/D1", recursive = TRUE, showWarnings = FALSE)
dir.create("1.Results/D4", recursive = TRUE, showWarnings = FALSE)
dir.create("1.Results/D180", recursive = TRUE, showWarnings = FALSE)
# ===============================
# METADATA (D-01)
# ===============================
Metadata_D1 <- Merge_Sample_Species %>%filter(TP == "D-01") %>% select(SampleID, Treatmentcode) %>%distinct() %>%column_to_rownames("SampleID")
# ===============================
# ABUNDANCE MATRIX
# ===============================
Abundence_Matrix_D01 <- Merge_Sample_Species %>%filter(TP == "D-01") %>%select(-TP, -Type, -Treatmentcode) %>%column_to_rownames("SampleID") %>%data.matrix()
# ===============================
# IMPORTANT FIX
# ===============================
OTU01 <- otu_table(Abundence_Matrix_D01, taxa_are_rows = FALSE)
META01 <- sample_data(Metadata_D1)
# ===============================
# MATCH SAMPLE ORDER (CRITICAL)
# ===============================
#common_samples <- intersect(rownames(Metadata_D1), rownames(Abundence_Matrix_D01))
#Abundence_Matrix_D01 <- Abundence_Matrix_D01[common_samples, ]
#Metadata_D1 <- Metadata_D1[common_samples, ]
#-- option 2
#Abundence_Matrix_D01 <- Abundence_Matrix_D01[match(rownames(Metadata_D1), rownames(Abundence_Matrix_D01)), , drop = FALSE]
#----- option 3
Abundence_Matrix_D01 <- Abundence_Matrix_D01[rownames(Metadata_D1), , drop = FALSE]
# rebuild after matching
OTU01 <- otu_table(Abundence_Matrix_D01, taxa_are_rows = FALSE)
# ===============================
# BUILD PHYLOSEQ
# ===============================
tax01 <- data.frame(Species = colnames(Abundence_Matrix_D01))
rownames(tax01) <- colnames(Abundence_Matrix_D01)
TAX01<- tax_table(as.matrix(tax01))
Physeq_D01 <- phyloseq(OTU01, META01, TAX01)
#---------------------------------RUN Diff abundence---------------
Result_D01_Lesfe <-run_lefse(Physeq_D01,wilcoxon_cutoff = 0.05, norm = "CPM",group = "Treatmentcode",kw_cutoff = 0.05,multigrp_strat = TRUE,lda_cutoff = 2)
saveRDS(Result_D01_Lesfe, "1.Results/D1/lefse_result_D1.rds")
# ===============================
# PLOTS
# ===============================
p_bar_1<- plot_ef_bar(Result_D01_Lesfe)

ggsave("1.Results/D1/lefse_barplot_D1.png", plot = p_bar_1,width = 8,height = 10,dpi=500)
plot_ef_bar(Result_D01_Lesfe)
plot_ef_dot(Result_D01_Lesfe)
#-------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------Day 04----------------------------------------------------------------

Metadata_D4 <- Merge_Sample_Species %>%filter(TP == "D-04") %>% select(SampleID, Treatmentcode) %>%distinct() %>%column_to_rownames("SampleID")
Abundence_Matrix_D04 <- Merge_Sample_Species %>%filter(TP == "D-04") %>%select(-TP, -Type, -Treatmentcode) %>%column_to_rownames("SampleID") %>%data.matrix()
# ===============================
# IMPORTANT FIX
# ===============================
OTU4<- otu_table(Abundence_Matrix_D04, taxa_are_rows = FALSE)
META4<- sample_data(Metadata_D4)
# ===============================
# MATCH SAMPLE ORDER (CRITICAL)
# ===============================
#----- option 3
Abundence_Matrix_D04 <- Abundence_Matrix_D04[rownames(Metadata_D4), , drop = FALSE]
# rebuild after matching
OTU4 <- otu_table(Abundence_Matrix_D04, taxa_are_rows = FALSE)
# ===============================
# BUILD PHYLOSEQ
# ===============================
tax4<- data.frame(Species = colnames(Abundence_Matrix_D04))
rownames(tax4) <- colnames(Abundence_Matrix_D04)
TAX4<- tax_table(as.matrix(tax4))
Physeq_D04 <- phyloseq(OTU4, META4, TAX4)
#---------------------------------RUN Diff abundence---------------
Result_D04_Lesfe <-run_lefse(Physeq_D04,wilcoxon_cutoff = 0.05, norm = "CPM",group = "Treatmentcode",kw_cutoff = 0.05,multigrp_strat = TRUE,lda_cutoff = 2)
saveRDS(Result_D04_Lesfe, "1.Results/D4/lefse_result_D4.rds")
# ===============================
# PLOTS
# ===============================
p_bar_4<- plot_ef_bar(Result_D04_Lesfe)
ggsave("1.Results/D4/lefse_barplot_D4.png", plot = p_bar_4,width = 8,height = 10,dpi=500)
plot_ef_bar(Result_D04_Lesfe)
plot_ef_dot(Result_D04_Lesfe)
#------------------------------------------------------------------------------------------------
#----------------------------------Day 180-------------------------------------------------------
# ===============================
# METADATA (D180)
# ===============================
Metadata_D180 <- Merge_Sample_Species %>%filter(TP == "D-180") %>%select(SampleID, Treatmentcode) %>%distinct() %>%column_to_rownames("SampleID")
# ===============================
# ABUNDANCE MATRIX (D180)
# ===============================
Abundence_Matrix_D180 <- Merge_Sample_Species %>%filter(TP == "D-180") %>%select(-TP, -Type, -Treatmentcode) %>%column_to_rownames("SampleID") %>%data.matrix()
# ===============================
# BUILD OTU + META
# ===============================
OTU180 <- otu_table(Abundence_Matrix_D180, taxa_are_rows = FALSE)
META180 <- sample_data(Metadata_D180)
# ===============================
# MATCH SAMPLE ORDER (CRITICAL)
# ===============================
all(rownames(Metadata_D180) %in% rownames(Abundence_Matrix_D180))
Abundence_Matrix_D180 <- Abundence_Matrix_D180[rownames(Metadata_D180),,drop = FALSE]
# Rebuild OTU after matching
OTU180 <- otu_table(Abundence_Matrix_D180, taxa_are_rows = FALSE)
# ===============================
# BUILD PHYLOSEQ
# ===============================
tax180 <- data.frame(Species = colnames(Abundence_Matrix_D180))
rownames(tax180) <- colnames(Abundence_Matrix_D180)
TAX180 <- tax_table(as.matrix(tax180))
Physeq_D180 <- phyloseq(OTU180, META180, TAX180)
# ===============================
# RUN LEFSE
# ===============================
Result_D180_Lesfe <- run_lefse(Physeq_D180,wilcoxon_cutoff = 0.05,norm = "CPM",group = "Treatmentcode",kw_cutoff = 0.05,multigrp_strat = TRUE,lda_cutoff = 2)
saveRDS(Result_D180_Lesfe, "1.Results/D180/lefse_result_D180.rds")
# ===============================
# PLOTS
# ===============================
p_bar_180 <- plot_ef_bar(Result_D180_Lesfe)
ggsave("1.Results/D180/lefse_barplot_D180.png", plot = p_bar_180,width = 8,height = 10,dpi=500)
#-----------------------------------------------------------------------------------------------
