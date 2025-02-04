# Version: 2.0
#
# Date: January 2024

# Author: Stephanie Saab
# Co-author: Paraskevi Massara (email: massaraevi@yahoo.com),
#
# OBJECTIVES: Analyze CCHS data and extract the reference values
# * Find the IQR, median, and 75th percentile for each nutrient
# * Check normality of each nutrient (by age group)
# * Find the Medians of the nutrients for each age group alone
# * Kruskal-wallis test to find significant differences
# * Compare sex using chi-squared (for each age group)

# NOTE 1:
# NOTE 2:

# RESOURCES: CCHS
#

#TOC> ==========================================================================
#TOC>
#TOC>   Pipeline Section
#TOC> --------------------------------------------------------------------------
#TOC>   1        Packages
#TOC>   2        Data
#TOC>   3        CCHS data exploration
#TOC>   4        Median, IQR, percentiles
#TOC> ==========================================================================

# ====    1  Packages  =========================================================

# Package names
packages <- c("ggplot2", "dplyr", 'sas7bdat', "lubridate")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# ====   2  Data  ==============================================================
cchs <-
  read.csv(
    "~/GitHub/ASA24_MiGrowD/Data/cchs-82M0024-E-2015-nu-side/cchs-82M0024-E-2015-nu-side_F1.csv"
  )

# ====   3  CCHS data exploration  =============================================

#----- a) Filter by age and nutrients-------------------------------------------

# MiGrowD age at diet report min 97 months (~8 years), max 154 months (~13 years)

# Filter by age
#Need to use & instead of | because | is OR and & is AND
cchs_f1 <- cchs[which(cchs$DHH_AGE >= 8 & cchs$DHH_AGE <= 13),]

#How many people that filled out the cchs are in our age range?
n_age <-
  nrow(cchs_f1) #n_age = 3742 out of 40974 if not including 13 years, 4522 if including 13 years

# Nutrient Outliers according to NCI guidelines (Kcal,Protein, Fat, Vitamic C, Beta-carotene)
# and nutrients of interest (energy, total fat, protein, carbohydrates, fiber, sodium,
# total sugars, and added sugars) (TK feasibility paper)

# NOTE: In CCHS data beta-carotene data were not available

keep1 <-
  c(
    "DHH_AGE",
    #Age,
    "DHH_SEX",
    #Sex (1=male, 2=female, 6, 7, 8, 9 had no responses)
    "FSDDEKC",
    # Energy intake from food sources in kilocalories - (D)
    "FSDDCAR",
    # Total carbohydrate intake from food sources - g - (D)
    "FSDDFI",
    # Total dietary fibre intake from food sources - g - (D)
    "FSDDSUG",
    # Total sugars intake from food sources - g - (D)
    "FSDDFAT",
    # Total fat intake from food sources - g - (D)
    "FSDDPRO",
    # Protein intake from food sources - g - (D)
    "FSDDSOD",
    # Sodium intake from food sources - mg - (D)
    "FSDDC", # Vitamin C intake from food sources-MG
    #"FSDDECA", # % total energy intake from carbohydrates - (D)
    #"FSDDELI", # % total energy intake from fat - (D)
    #"FSDDEPR", # % total energy intake from proteins - (D)
    #"BNSD41A", # Gram Weight - Sugars :White/Brown
    #"BNSD41B", # Gram Weight - Jams/Jellies/ Marmalade
    #"BNSD41C",  # Gram Weight - Other Sugars,
    "ADMFSID", # second 24-h recall
    "ADM_RNO", # sequential number
    "VERDATE", # date of file creation
    "SAM_CP"  # sample collection period
  )

cchs_f1 <- cchs_f1[keep1]

# Remove NAs from the dataset

cchs_f1 <- as.data.frame(na.omit(cchs_f1))

#----- b)  Comparing males:females with chi-squared -----------------------------

# Using a chi-squared test to compare the frequency for males vs females to see
# if there are more males vs females

chi_table <- data.frame(age = c(),
                        male = c(),
                        female = c())
#For each age group
for (age in 8:13) {
  cchs_age <- na.omit(cchs_f1[which(cchs_f1$DHH_AGE == age),])
  male_freq <- nrow(cchs_age[which(cchs_age$DHH_SEX == 1),])
  female_freq <- nrow(cchs_age[which(cchs_age$DHH_SEX == 2),])
  chi_table <- rbind(chi_table,
                     data.frame(
                       age = age,
                       male = male_freq,
                       female = female_freq
                     ))
}
chisq <- chisq.test(chi_table)

#------------c) Normality (Shapiro test) ---------------------------------------

#If p-value is less than 0.05 = don't assume normality

# Normality test for each age and nutrient
shapiro.res <- {
}
for (i in unique(cchs_f1$DHH_AGE)) {
  age_group <- cchs_f1[which(cchs_f1$DHH_AGE == i), ]
  print(i)
  for (j in 3:10) {
    test.res <- shapiro.test(as.numeric(age_group[, j]))
    shapiro.res <-
      rbind(shapiro.res, c(i, colnames(age_group)[j], test.res$p.value))
  }
  
}
shapiro.res <- as.data.frame(shapiro.res)
colnames(shapiro.res) <- c("age", "nutrient", "p-value")


# The results are printed for each age all nutrients, then n+1 age all nutrients ect


##------------d) MANN WHITNEY TESTING-------------------------------------------

# Check if we can merge ages or use each age separately
wilcox.res <- {
}
for (i in unique(cchs_f1$DHH_AGE)) {
  age_group <- cchs_f1[which(cchs_f1$DHH_AGE == i), ]
  print(i)
  for (j in 3:10) {
    test.res <-
      wilcox.test(as.numeric(age_group[, j]), as.numeric(cchs_f1[, j]))
    wilcox.res <-
      rbind(wilcox.res, c(i, colnames(age_group)[j], test.res$p.value))
  }
  
}
wilcox.res <- as.data.frame(wilcox.res)
colnames(wilcox.res) <- c("age", "nutrient", "p-value")

#====   4 Median IQR Percentile ================================================

# Nutrient info (for each age, IQR, Q3, Medians)
df_RefVals <- {
}
#Creating a loop to collect the values for each age (8-13)

for (i in unique(cchs_f1$DHH_AGE)) {
  age_group <- cchs_f1[which(cchs_f1$DHH_AGE == i), ]
  print(i)
  for (j in 3:10) {
    medians <- median(as.numeric(age_group[, j]))
    IQR <- IQR(as.numeric(age_group[, j]))
    percentile5 <-
      quantile(as.numeric(age_group[, j]), probs = c(0.05))
    percentile75 <-
      quantile(as.numeric(age_group[, j]), probs = c(0.75))
    percentile95 <-
      quantile(as.numeric(age_group[, j]), probs = c(0.95))
    df_RefVals <-
      rbind(
        df_RefVals,
        c(
          i,
          colnames(age_group)[j],
          medians,
          IQR,
          percentile5,
          percentile75,
          percentile95
        )
      )
  }
  
}
df_RefVals <- as.data.frame(df_RefVals)
colnames(df_RefVals) <-
  c("age",
    "nutrient",
    "median",
    "IQR",
    "5_percentile",
    "75_percentile",
    "95_percentile")


df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDEKC")] <- "KCAL"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDCAR")] <- "CARB"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDFI")] <- "FIBE"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDSUG")] <- "SUGR"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDFAT")] <- "TFAT"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDSOD")] <- "SODI"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDC")] <- "VC"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDPRO")] <- "PROT"

saveRDS(df_RefVals, "~/GitHub/ASA24_MiGrowD/Results/ref_vals.rds")

#====   5 Create the validation dataset ========================================

# Keep cases with 2 recalls completed succesfully (ADMFSID=1)

short_cchs_f1 <- cchs_f1[which(cchs_f1$ADMFSID==1),]

# saveRDS(short_cchs_f1,
#      "~/GitHub/ASA24_MiGrowD/Data/validation_dataset.csv"
#   )




