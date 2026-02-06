#Set Directory
setwd("D:/2.Caz_Microbiome")
getwd()
#----------------------------------------------
#load packages
#----------------------------------------------
library(dplyr)
list.files()
#-------remove existing files--------------------
rm(list = ls());gc()
#-------------------#-Read MetaDataFiles---------------------------------------------------
Treatment_Data_A <-read.csv("Treatmentcode_A.csv",check.names = F)
Treatment_Data_B <-read.csv("Treatmentcode_B.csv",check.names = F)
Treatment_Data <- Treatment_Data_A %>%inner_join(Treatment_Data_B, by='PID')
head(Treatment_Data)
#-----------------------------------------------------------------------------------------------
Treatment_Data_P <- Treatment_Data %>%
  # 1. Flag TreatIDs as Unique or Multiple
  group_by(TreatID) %>%
  mutate(Type = ifelse(n() == 1, "Unique", "Multiple")) %>%
  ungroup() %>%
  # 2. Keep only the first occurrence per TreatID
  distinct(TreatID, .keep_all = TRUE) %>%
  # 3. Extract the Household ID (e.g., CAZ-001)
  mutate(CAZ_HH = sub("^(CAZ-[^-]+)-.*$", "\\1", PID))
#Treatment_Data_P <- Treatment_Data%>%distinct(TreatID, .keep_all = TRUE) %>%mutate(CAZ_HH = sub("^(CAZ-[^-]+)-.*$", "\\1", PID))
#-------------------------------------------------------------------------------------------------
table(Treatment_Data_P$Type)
dim(Treatment_Data_P)
#-----------------------------------------------------------------------------------------------------
Caz_Meta_Data <- read.csv("CAZ-metadata-simple.csv",check.names = F) %>%filter(!TP %in% c("NC", "EC"))
#-----------------------------------------------------------------------------------------------------
Merged_Meta<-  Caz_Meta_Data %>%inner_join(Treatment_Data_P,by="CAZ_HH")
write.csv(Merged_Meta,"Merged_CAZ_Meta.csv",row.names = F)
table(Merged_Meta$TP)
table(Merged_Meta$TP,Merged_Meta$Treatmentcode)
#--------------------------------------------------------------------------------------------------------
Merged_Meta_fi <-Merged_Meta %>%select(SampleID,SampleDescription,ID,CAZ_HH,TP,PID,TreatID,Treatmentcode)
write.csv(Merged_Meta_fi,"CAZ_Meta_Treatment.csv",row.names = F)
