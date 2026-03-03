#------------------------------------------load the libraries-------------------------------------#
library(tibble)
library(dplyr)
library(tibble)
library(stringr)
library(tidyr)
library(ggplot2)
library(grid)
library(scales)
library(phyloseq)
#---------------------------------------------------------------------------------------------------------
Merged_Meta_fi<-read.csv("CAZ_Meta_Treatment.csv", check.names = F)
#--------------------------------------------------------------------------------------------------------
#-------------------------------------------------Phylum Analysis---------------------------------------#

Caz_Phylum <-read.csv("D:/2.Caz_Microbiome/1.Data/2.Braken_Phylum_Family/phylum_abundance_matrix.csv", check.names = F)%>%
  column_to_rownames("name") %>%t() %>%as.data.frame()%>%rownames_to_column("SampleID") %>%select(-Chordata)%>%
  mutate(SampleID = str_replace(SampleID,"(DS-)(\\d+)$",function(x) {
    prefix <- str_match(x, "(DS-)")[,2]
    num    <- str_match(x, "(\\d+)$")[,2]
    paste0(prefix, str_pad(num, width = 4, pad = "0"))}))
#write.csv(Caz_Phylum,"Caz_Phylum.csv", row.names = F)
#-------------------------------------------Merging two file with long format---------------------
#----------------------------------------------------------------------------------------------------
Caz_Phylum_merged<- Merged_Meta_fi%>%left_join(Caz_Phylum , by = "SampleID")
write.csv(Caz_Phylum_merged,"D:/2.Caz_Microbiome/1.Data/2.Braken_Phylum_Family/Caz_Phylum_merged.csv",row.names = F)
Metadata_Phyl<- Caz_Phylum_merged %>% select(SampleID,TP,Treatmentcode) %>%distinct() %>%column_to_rownames("SampleID")
#---------------------------Making Phyloseq obj--------------------------------------
# ABUNDANCE MATRIX
# ===============================
colnames(Merged_Meta_fi)
Abundence_Matrix_Phy <- Caz_Phylum_merged %>%select(-TP, -Type,-SampleDescription,-ID,-CAZ_HH,-PID,-TreatID,-Treatmentcode) %>%column_to_rownames("SampleID") %>%data.matrix()
# ===============================
# ===============================
OTU_phy <- otu_table(Abundence_Matrix_Phy, taxa_are_rows = FALSE)
META_phy <- sample_data(Metadata_Phyl)
# ===============================
# MATCH SAMPLE ORDER 
#----- 
Abundence_Matrix_Phy <- Abundence_Matrix_Phy[rownames(META_phy), , drop = FALSE]
# rebuild after matching
OTU_phy <- otu_table(Abundence_Matrix_Phy, taxa_are_rows = FALSE)
# ===============================
# PHYLOSEQ
# ===============================
tax_phy <- data.frame(Phylum = colnames(Abundence_Matrix_Phy))
rownames(tax_phy) <- colnames(Abundence_Matrix_Phy)
TAX_phy <- tax_table(as.matrix(tax_phy))
Physeq_Phy <- phyloseq(OTU_phy, META_phy, TAX_phy)
#--------------------------------------------------------------------------
#---------------------------------------------------------------------------
phy<-Physeq_Phy
#----------------------- look into the web link ----------------
#https://github.com/joey711/phyloseq/issues/1197 ---------------
#-----------------------------------------
### how many taxa I want to see
topN = 11 
topTaxa <- phy %>% psmelt %>% group_by(Phylum) %>% summarise(Abundance=sum(Abundance)) %>% arrange(desc(Abundance)) %>% 
  mutate(aggTaxo=as.factor(case_when(row_number()<=topN~Phylum, row_number()>topN~'Others'))) %>% dplyr::select(-Abundance) %>% head(n=topN+1)

### CREATE an object that will be fed into ggplot
plotData_Phylum<- phy %>%psmelt %>% inner_join(.,topTaxa, by="Phylum") %>% aggregate(Abundance~TP+aggTaxo+Treatmentcode,data=., FUN=sum) %>%
  mutate(Treatmentcode=factor(Treatmentcode,levels=c("Azithromycin","Placebo")))%>%rename(Phylum=aggTaxo)

#---------------Plot the Data--------------------------------------------------------------------------------------------------------------
#Phylum_stacked_bar<-ggplot(plotData_Phylum, aes(x=TP, y=Abundance, fill=Phylum)) +geom_bar(stat="identity", position="fill") +facet_grid(~Treatmentcode, scale="free")

plotData_Phylum$Phylum <- factor(plotData_Phylum$Phylum,levels = plotData_Phylum %>%group_by(Phylum) %>%summarise(total = sum(Abundance)) %>%arrange(desc(total)) %>%pull(Phylum))

Phylum_stacked_bar <- ggplot(plotData_Phylum,aes(x = TP, y = Abundance, fill = Phylum)) +
  geom_bar(stat = "identity",position = "fill",width = 0.9,color = "black",size = 0.1) +
  facet_grid(~Treatmentcode, scales = "fixed", space = "fixed") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),expand = c(0, 0)) +
  scale_x_discrete(expand = c(0, 0)) + 
  scale_fill_brewer(palette = "Set3") +
  labs(title = "Phylum-Level Microbial Composition",x = "Time Point",y = "Relative Abundance (%)",fill = "Phylum") +
  theme_classic(base_size = 14) +
  theme(panel.spacing.x = unit(0.4, "lines"),axis.text.x = element_text(angle = 45, hjust = 1),strip.background = element_rect(fill = "grey90", color = NA),
    strip.text = element_text(face = "bold"),plot.title = element_text(hjust = 0.5, face = "bold"),legend.position = "right",legend.title = element_text(face = "bold"))

Phylum_stacked_bar
ggsave("D:/2.Caz_Microbiome/1.Data/2.Braken_Phylum_Family//Phylum_stacked_bar.png", plot = Phylum_stacked_bar,width = 9,height = 8,dpi=800)
#-------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------#

#-------------------------Family Analysis--------------------------------#

Caz_Family <-read.csv("D:/2.Caz_Microbiome/1.Data/2.Braken_Phylum_Family/family_abundance_matrix.csv", check.names = F)%>%
  column_to_rownames("name") %>%t() %>%as.data.frame() %>%rownames_to_column("SampleID") %>%select(-Hominidae)%>%
  mutate(SampleID = str_replace(SampleID,"(DS-)(\\d+)$",function(x) {
    prefix <- str_match(x, "(DS-)")[,2]
    num    <- str_match(x, "(\\d+)$")[,2]
    paste0(prefix, str_pad(num, width = 4, pad = "0"))}))

Caz_Family_merged<- Merged_Meta_fi%>%left_join(Caz_Family , by = "SampleID")
write.csv(Caz_Family_merged,"D:/2.Caz_Microbiome/1.Data/2.Braken_Phylum_Family/Caz_Family_merged.csv",row.names = F)
Metadata_Family<- Caz_Family_merged %>% select(SampleID,TP,Treatmentcode) %>%distinct() %>%column_to_rownames("SampleID")
# ===============================
# ABUNDANCE MATRIX
# ===============================
colnames(Merged_Meta_fi)
Abundence_Matrix_Family<- Caz_Family_merged %>%select(-TP, -Type,-SampleDescription,-ID,-CAZ_HH,-PID,-TreatID,-Treatmentcode) %>%column_to_rownames("SampleID") %>%data.matrix()
# ===============================
# IMPORTANT FIX
# ===============================
OTU_Family <- otu_table(Abundence_Matrix_Family, taxa_are_rows = FALSE)
META_Family <- sample_data(Metadata_Family)
# ===============================
# MATCH SAMPLE ORDER (CRITICAL)
#----- option 3
Abundence_Matrix_Family <- Abundence_Matrix_Family[rownames(META_Family), , drop = FALSE]
# rebuild after matching
OTU_Family <- otu_table(Abundence_Matrix_Family, taxa_are_rows = FALSE)
# ===============================
# BUILD PHYLOSEQ
# ===============================
tax_family <- data.frame(Family = colnames(Abundence_Matrix_Family))
rownames(tax_family) <- colnames(Abundence_Matrix_Family)
tax_family <- tax_table(as.matrix(tax_family))
Physeq_family <- phyloseq(OTU_Family, META_Family, tax_family)
#--------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Convert to relative abundance
#Physeq_rel <- transform_sample_counts(Physeq_Phy, function(x) x / sum(x))
#my_phyla <- tax_glom(Physeq_rel, taxrank = "Phylum")
##my_phyla
familyy<-Physeq_family

### DECIDE how many taxa you want to see
topN = 11 #
topfamily <- Physeq_family %>% psmelt %>% group_by(Family) %>% summarise(Abundance=sum(Abundance)) %>% arrange(desc(Abundance)) %>% 
  mutate(aggFamily=as.factor(case_when( row_number()<=topN~Family, row_number()>topN~'Others'))) %>% dplyr::select(-Abundance) %>%head(n=topN+1)  
### CREATE an object that will be fed into ggplot
plotData_family <- Physeq_family %>% psmelt %>% inner_join(.,topfamily, by="Family") %>% aggregate(Abundance~TP+aggFamily+Treatmentcode,data=., FUN=sum) %>% 
  mutate(Treatmentcode=factor(Treatmentcode,levels=c("Placebo","Azithromycin")))%>%rename(Family=aggFamily)

#Family_stacked_bar<-ggplot(plotData_family, aes(x=TP, y=Abundance, fill=Family)) +geom_bar(stat="identity", position="fill") +facet_grid(~Treatmentcode, scale="free")

plotData_family$Family <- factor(plotData_family$Family,levels = plotData_family %>%
    group_by(Family) %>%summarise(total = sum(Abundance)) %>%arrange(desc(total)) %>%pull(Family))

#------------------------------------------------------------------------------------------------------------------------------------------
Family_stacked_bar <- ggplot(plotData_family,aes(x = TP, y = Abundance, fill = Family)) +
  geom_bar(stat = "identity",position = "fill",width = 0.9,color = "black",size = 0.1) +
  facet_grid(~Treatmentcode, scales = "fixed", space = "fixed") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),expand = c(0, 0)) +
  scale_x_discrete(expand = c(0, 0)) +scale_fill_brewer(palette = "Set3") +
  labs(title = "Family-Level Microbial Composition",x = "Time Point",y = "Relative Abundance (%)",fill = "Family") +
  theme_classic(base_size = 14) +
  theme(panel.spacing.x = unit(0.4, "lines"),axis.text.x = element_text(angle = 45, hjust = 1),
  strip.background = element_rect(fill = "grey90", color = NA),strip.text = element_text(face = "bold"),
  plot.title = element_text(hjust = 0.5, face = "bold"),legend.position = "right",legend.title = element_text(face = "bold"))
#--------------------------------------------------------------------------------------------------------------------------------------------
Family_stacked_bar
ggsave("D:/2.Caz_Microbiome/1.Data/2.Braken_Phylum_Family//Family_stacked_bar.png", plot = Family_stacked_bar,width = 9,height = 8,dpi=800)
#------------------------------------------------------The End-----------------------------------------------------------------------------#
