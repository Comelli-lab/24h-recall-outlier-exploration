# Version: 2.0
# Date: January 2024

# Author: Stephanie Saab
# Co-author: Paraskevi Massara (email: massaraevi@yahoo.com)

# OBJECTIVES: Analyze CCHS data and extract the reference values
# * Find the IQR, median, and 75th percentile for each nutrient
)

# RESOURCES: CCHS

# TOC> ==========================================================================
# TOC>
# TOC>   Pipeline Section
# TOC> --------------------------------------------------------------------------
# TOC>   1        Packages
# TOC>   2        Data
# TOC>   3        CCHS data exploration
# TOC>   4        Median, IQR, percentiles
# TOC> ==========================================================================

# ====    1  Packages  =========================================================
# see install_packages.R

# ====   2  Data  ==============================================================
# Load the CCHS data
cchs <- read.csv("cchs-82M0024-E-2015-nu-side_F1.csv")

# ====   3  CCHS data exploration  =============================================
# Filter by age and nutrients

# MiGrowD age at diet report min 97 months (~8 years), max 154 months (~13 years)
# Adjust age range if necessary

# Filter by age
cchs_f1 <- cchs[which(cchs$DHH_AGE >= 8 & cchs$DHH_AGE <= 13),]

# Nutrient Outliers according to NCI guidelines and nutrients of interest
# Note: Beta-carotene data were not available in CCHS data

# Select relevant columns
keep1 <- c("DHH_AGE", "DHH_SEX", "FSDDEKC", "FSDDCAR", "FSDDFI", "FSDDSUG", 
           "FSDDFAT", "FSDDPRO", "FSDDSOD", "FSDDC", "ADMFSID", "ADM_RNO", 
           "VERDATE", "SAM_CP")

cchs_f1 <- cchs_f1[keep1]

# Remove NAs from the dataset
cchs_f1 <- as.data.frame(na.omit(cchs_f1))

# ====   4 Median IQR Percentile ================================================
# Compute nutrient info (IQR, Q3, Medians) for each age

df_RefVals <- data.frame()

# Loop through each age group and compute statistics for each nutrient
for (i in unique(cchs_f1$DHH_AGE)) {
    age_group <- cchs_f1[which(cchs_f1$DHH_AGE == i), ]
    for (j in 3:10) {
        medians <- median(as.numeric(age_group[, j]))
        IQR <- IQR(as.numeric(age_group[, j]))
        percentile5 <- quantile(as.numeric(age_group[, j]), probs = c(0.05))
        percentile75 <- quantile(as.numeric(age_group[, j]), probs = c(0.75))
        percentile95 <- quantile(as.numeric(age_group[, j]), probs = c(0.95))
        df_RefVals <- rbind(df_RefVals, c(i, colnames(age_group)[j], medians, IQR, percentile5, percentile75, percentile95))
    }
}

df_RefVals <- as.data.frame(df_RefVals)
colnames(df_RefVals) <- c("age", "nutrient", "median", "IQR", "5_percentile", "75_percentile", "95_percentile")

# Rename nutrient columns for clarity
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDEKC")] <- "KCAL"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDCAR")] <- "CARB"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDFI")] <- "FIBE"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDSUG")] <- "SUGR"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDFAT")] <- "TFAT"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDSOD")] <- "SODI"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDC")] <- "VC"
df_RefVals$nutrient[which(df_RefVals$nutrient=="FSDDPRO")] <- "PROT"

# Save the reference values dataframe
saveRDS(df_RefVals, "~/GitHub/ref_vals.rds")

# ====   5 Create the validation dataset ========================================
# Keep cases with 2 recalls completed successfully (ADMFSID=1)

short_cchs_f1 <- cchs_f1[which(cchs_f1$ADMFSID==1),]


