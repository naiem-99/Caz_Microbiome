
#---------------------------------Alternative Option (R Script vegan Package)-------------------------------

#---------------------------------alpha -----------------------------------------------------------------
#-------------------------Calculate alpha diversity--------------------------
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
#--------------------------------------------------------------------------------
Species_ab_m <-read.csv("species_abundance_matrix_filtered.csv", check.names = F)
# Corrected syntax
colnames(Species_ab_m) <- gsub("\\.", "", colnames(Species_ab_m))
head(Species_ab_m)
Species_ab_m_t <- Species_ab_m %>%
  column_to_rownames("Name") %>%   # species → rownames
  t() %>%                          # transpose
  as.data.frame() %>%              # matrix → data.frame
  rownames_to_column("SampleID") %>%
  mutate(SampleID = str_replace(SampleID,"(DS-)(\\d+)$",function(x) {
        prefix <- str_match(x, "(DS-)")[,2]
        num    <- str_match(x, "(\\d+)$")[,2]
        paste0(prefix, str_pad(num, width = 4, pad = "0"))}))
# rownames → SampleID column
head(Species_ab_m_t) [1:10,1:10]
write.csv(Species_ab_m_t,"Species_ab_m_t.csv",row.names = F)
#--------------------------------Merge the data----------------------------------------------------
Merged_Meta_fi<-read.csv("CAZ_Meta_Treatment.csv", check.names = F)
Species_ab_m_t<-read.csv("Species_ab_m_t.csv", check.names = F)
Merge_Sample_Species <- Species_ab_m_t %>%inner_join(Merged_Meta_fi, by = "SampleID") %>%select(-c(SampleDescription, ID, CAZ_HH, PID, TreatID))
#write.csv(Merge_Sample_Species,"Merge_Sample_Species.csv",row.names = F)
#--------------------------------------------------------------------
#Merge_Sample_Species_2nd <- Species_ab_m_t %>%inner_join(Merged_Meta_fi, by = "SampleID")# %>%select(-c(SampleDescription, ID, CAZ_HH, PID, TreatID))
#write.csv(Merge_Sample_Species_2nd,"Merge_Sample_Species_2nd.csv",row.names = F)
#-------------------------------------------------------------------
tail(colnames(Merge_Sample_Species), 10)
head(colnames(Merge_Sample_Species), 10)
#------------------
#--------------------------------------------------------------------------------
# READ DATA
# ===============================
Merge_Sample_Species <- read.csv("Merge_Sample_Species.csv", check.names = FALSE)
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
