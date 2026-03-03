
#---------------------------------------Beta------------------------------------------------------------
# ===============================
library(dplyr)
library(tidyr)
Merge_Sample_Species <- read.csv("Merge_Sample_Species.csv", check.names = FALSE)
dim(Merge_Sample_Species)
head(Merge_Sample_Species)
#-------------------------------------------------------------------------------------------------------
#https://rpubs.com/mrgambero/taxa_alpha_beta
rm(list = setdiff(ls(), "Merge_Sample_Species")); gc()
Metadata_All <-Merge_Sample_Species%>%select(SampleID, TP, Type, Treatmentcode)
#---------------------------------------------------------------------------------------------------------
species_matrix <- Merge_Sample_Species %>%select(-TP, -Type, -Treatmentcode) %>%column_to_rownames("SampleID") %>%data.matrix()
# ---------------------------------------------------------------------------------------------------------





#-----------------------------------------------------------------------------------------------------------
