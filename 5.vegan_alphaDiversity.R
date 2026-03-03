
#---------------------------------Alternative Option (R Script vegan Package)-------------------------------

#---------------------------------alpha -----------------------------------------------------------------
#-------------------------Calculate alpha and beta diversity--------------------------
library(dplyr)
library(vegan)
library(tibble)
library(tidyverse)
library(ggplot2)
library(rstatix)
library(scales)
library(ggpubr)
#https://www.youtube.com/watch?v=wq1SXGQYgCs
#https://github.com/riffomonas/distances/blob/64df17d165f28fc283a0f892c90f482650af07e7/code/alpha.R
list.files()
# READ DATA
# ===============================
Merge_Sample_Species <- read.csv("Merge_Sample_Species_2nd.csv", check.names = FALSE)
library(dplyr)
library(tidyr)
dim(Merge_Sample_Species)
head(Merge_Sample_Species)
#------------------------------------------------------------------------------------------------
#https://rpubs.com/mrgambero/taxa_alpha_beta
rm(list = setdiff(ls(), "Merge_Sample_Species")); gc()
Metadata_All <-Merge_Sample_Species%>%select(SampleID, TP, Type, Treatmentcode)
#----------------------------------------------------------------------------------------------
species_matrix <- Merge_Sample_Species %>%select(-TP, -Type, -Treatmentcode) %>%column_to_rownames("SampleID") %>%data.matrix()
# ===============================
# ------------------------REMOVE ZERO SPECIES------------------------------
# ===============================
species_matrix <- species_matrix[, colSums(species_matrix) > 0]
#------ calculation of alpha diversity--------------------------------------
alpha.data <- data.frame(SampleID = rownames(species_matrix),
                         richness = specnumber(species_matrix), 
                         shannon = diversity(species_matrix),
                         simpson = diversity(species_matrix, index = "simpson"),
                         invsimpson = diversity(species_matrix, index = "invsimpson"), 
                         n = rowSums(species_matrix))
# ===============================
# MERGE METADATA (SAFE)
# ===============================
alpha.data <- alpha.data %>%left_join(Metadata_All, by = "SampleID")
# ===============================
# Create stat.test with correct shifts
#stat.test <- alpha.data %>%group_by(TP) %>% wilcox_test(invsimpson ~ Treatmentcode) %>%
  #t_test(invsimpson ~ Treatmentcode, ref.group = "Placebo") %>%
 # use either one # adjust_pvalue(method = "fdr") %>%add_significance() %>%add_xy_position(x = "Treatmentcode")

#invsimpson +stat_pvalue_manual(stat.test,label = "p.adj.signif",tip.length = 0.01,hide.ns = F)
####################################################################
#------------------------ Ensuring correct factor order------------------------------------------
alpha.data$Treatmentcode <- factor(alpha.data$Treatmentcode,levels = c("Placebo", "Azithromycin"))
alpha.data$TP <- factor(alpha.data$TP,levels = c("D-01", "D-04", "D-180"))
# -----------------------------------------------------------------------------------------------
# Statistical test
# -----------------------------------------------------------------------------------------------
stat.test <- alpha.data %>%group_by(TP) %>%wilcox_test(invsimpson ~ Treatmentcode) %>%adjust_pvalue(method = "fdr") %>%add_significance() %>%add_xy_position(x = "Treatmentcode")
#  ----------------------------------------------------------------------------------------------
# Plot
# -----------------------------------------------------------------------------------------------
invsimpson_plot <- ggplot(alpha.data,aes(x = Treatmentcode,y = invsimpson,fill = Treatmentcode)) +
  geom_boxplot(width = 0.55,outlier.shape = NA,color = "black",alpha = 0.85) +
  #geom_jitter(width = 0.12,size = 1.6,alpha = 0.4,color = "black") +
  facet_wrap(~TP, nrow = 1) +
  scale_fill_manual(values = c("Placebo" = "#00BFC4","Azithromycin" = "#F8766D" ))+  
  labs(title = "Inverse Simpson Diversity",x = NULL,y = "Inverse Simpson Index") +
  stat_pvalue_manual(stat.test,label = "p.adj.signif",tip.length = 0.01,hide.ns = FALSE,size = 5) +
  theme_bw()+theme(legend.position = "none",
     strip.background = element_blank(),
    strip.text = element_text(face = "bold", size = 16),  # facet titles bigger
    axis.text.x = element_text(size = 14, color = "black"),  # X tick labels
    axis.text.y = element_text(size = 14, color = "black"),  # Y tick labels
    axis.title.x = element_text(size = 16, face = "bold"),   # X axis title
    axis.title.y = element_text(size = 16, face = "bold"),   # Y axis title
    plot.title = element_text(face = "bold", size = 20, hjust = 0.5),
    panel.spacing = unit(1.2, "lines"))
  #theme_classic(base_size = 14) +
  #theme(legend.position = "none",strip.background = element_blank(),strip.text = element_text(face = "bold", size = 12),axis.text = element_text(color = "black"),axis.title = element_text(face = "bold"),plot.title = element_text(face = "bold", size = 16, hjust = 0.5),panel.spacing = unit(1, "lines"))
invsimpson_plot
#------------------------------------------------------------------------------------------------------
ggsave("alpha_diversity_invsimpson_plot.png", plot = invsimpson_plot,width = 7.8,height = 7.8,dpi = 800)

#The rest of the plots are same (richness,shannon,simpson),so just change y axis values an title
#------------------------------------The End-----------------------------------------------------------

#--------------------------------------------------------------------------------------------------------
