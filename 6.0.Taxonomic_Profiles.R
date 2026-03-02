#-----------------Phylum Analysis---------------------------------------#
#----------------load the libraries-------------------------------------#
library(tibble)
library(phyloseq)
library(dplyr)
library(tibble)
library(stringr)
library(tidyr)
library(ggplot2)
#---------------------------------------------------------------------------
library(phyloseq)
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
#-----------------------------------------------------------------------------
#https://github.com/joey711/phyloseq/issues/1197    - 01
#---------------------------------------------------------------------------
phy<-Physeq_Phy
#----------------------- look into the web link ----------------
#https://github.com/joey711/phyloseq/issues/1197 -----02
#-----------------------------------------
### how many taxa I want to see
topN = 11 
topTaxa <- phy %>% psmelt %>% group_by(Phylum) %>% 
  summarise(Abundance=sum(Abundance)) %>% arrange(desc(Abundance)) %>% 
  mutate(aggTaxo=as.factor(case_when(row_number()<=topN~Phylum, row_number()>topN~'Others'))) %>% 
  dplyr::select(-Abundance) %>% head(n=topN+1)

### CREATE an object that will be fed into ggplot
plotData<- phy %>%psmelt %>% inner_join(.,topTaxa, by="Phylum") %>% 
  aggregate(Abundance~TP+aggTaxo+Treatmentcode,data=., FUN=sum) %>%
  mutate(Treatmentcode=factor(Treatmentcode,levels=c("Azithromycin","Placebo")))%>%rename(Phylum=aggTaxo)

#---------------Plot the Data--------------------------------------------------------------------------------------------------------------
Phylum_stacked_bar<-ggplot(plotData, aes(x=TP, y=Abundance, fill=Phylum)) +geom_bar(stat="identity", position="fill") +facet_grid(~Treatmentcode, scale="free")
ggsave("D:/2.Caz_Microbiome/1.Data/2.Braken_Phylum_Family//Phylum_stacked_bar.png", plot = Phylum_stacked_bar,width = 10,height = 8,dpi=500)
#--------------------------------------------------------------------------



#------------------------------------------------------------------------#

#-------------------------Family Analysis--------------------------------#







#-------------------------------------------------------------------------#
