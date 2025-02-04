# Version: 1.0
#
# Date: January, 2024

# Authors: Paraskevi Massara (email: massaraevi@yahoo.com),
#
# OBJECTIVES: Apply NCI guidelines and other cleaning processes described in the literature

# NOTE 1:
# NOTE 2:

# RESOURCES:
#https://pilotfeasibilitystudies.biomedcentral.com/articles/10.1186/s40814-021-00864-6


#TOC> ==========================================================================
#TOC>
#TOC>   Pipeline Section
#TOC> --------------------------------------------------------------------------
#TOC>   1        Packages
#TOC>   2        Data
#TOC>   3
#TOC> ==========================================================================

# ====    1  Dependencies  =====================================================

# Package names
packages <- c("naniar")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

source("~/GitHub/cleaning_functions.R")
source("~/GitHub/1.cchs_data_analysis.R")

# ====   2  Data  ==============================================================

# Creatw a file (here "total" that includes the ASA24 responses file export)

colRange <-  # take that food items/nutrients that are needed for the analysis

thresholds <- readRDS("~/GitHub/ref_vals.rds") # here created for ages 8-13
food_names <-
  read.csv("~/GitHub/ASA24_MiGrowD/Data/cnf-fcen-csv/FOOD NAME.csv",
           header = T) # this is the food name file from CCHS
food_groups <-
  read.csv("~/GitHub/cnf-fcen-csv/FOOD GROUP.csv",
           header = T) # this is the food group file from CCHS

# ====   3  NCI Guidelines  ====================================================


# ----- 3.1 Missingness --------------------------------------------------------

missing_cases <- getHighMissingCases(total, 10, colRange = colRange)

# Broken Entries

broken_entries <- getBrokenEntries(total, "RecallStatus", 5)
final<-dplyr::setdiff(total, broken_entries)
duplicates<-total[duplicated(total[,colRange]),]
final<-dplyr::setdiff(final, duplicates)


# ----- 3.2 Text entries -------------------------------------------------------

total_sub<-total[,c("UserName", "RecallNo")]
responses$RecallNo<-as.numeric(responses$RecallNo)
responses2<-inner_join(total_sub, responses, by=c("UserName", "RecallNo"))

textOutliers <- findTextOutliers(dataframe=total, responses=responses2)


# ------3.3 Outlier review (NCI step 3 & 5) ------------------------------------

# Nutrient Outliers (Appendix A)


colnames(thresholds) <-
  c("age", "nutrient", "median", "IQR", "perc5", "perc75", "perc95")

for (col in c(3:7)) {
  thresholds[, col] <- as.numeric(thresholds[, col])
}
total2 <- dplyr::setdiff(total, missing_cases)
outliers595 <-
  findOutliers5_95(dplyr::setdiff(total, missing_cases),
                   "age_diet_report",
                   thresholds)

outliersIQR_3 <-
  findOutliersIQR(dplyr::setdiff(total, missing_cases),
                  "age_diet_report",
                  thresholds,
                  3)
outliersIQR_2 <-
  findOutliersIQR(dplyr::setdiff(total, missing_cases),
                  "age_diet_report",
                  thresholds,
                  2)

# Examplesfor Portion Outliers

beverage_outliers <-
  getFoodGroupOutliers(food_names, ASA24_items, c(14), 1892.5)
meat_outliers <-
  getFoodGroupOutliers(food_names, ASA24_items, c(5, 7, 10, 13, 15, 17), 342)
mixed_outliers <-
  getFoodGroupOutliers(food_names, ASA24_items, c(22), 1440)
snack_outliers <-
  getFoodGroupOutliers(food_names, ASA24_items, c(25), 226)


#=========================== 4. High Alcohol and Caffeine ======================

alcoholAndCaffeineErrors <-
  getAlcoholAndCaffeineErrors(final, "CAFF", 50, "ALC", 1)

#=========================== 5. Duplicates =====================================
duplicates <- total[duplicated(final[, colRange]), ]


#===================== 6. Find all outliers ====================================

final <- getAlcoholAndCaffeineErrors(final, "CAFF", 50, "ALC", 1)
final <- findOutliers5_95(final, "age_diet_report", thresholds)
final <- findOutliersIQR(final, "age_diet_report", thresholds, 2)
final <- findTextOutliers(final, responses)


