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
# NCI outlier detection guide (see Manuals folder)

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

source("~/GitHub/ASA24_MiGrowD/Code/cleaning_functions.R")


# ====   2  Data  ==============================================================

#total<-readRDS("E:/ASA24/totals_FB_only.rds")
colRange <-
  c(12:76)# take that food items/nutrients that are needed for the analysis
thresholds <- readRDS("~/GitHub/ASA24_MiGrowD/Data/ref_vals.rds")
#v16_items <- read.csv("E:/ASA24/ASA24v2016_export/v16_items_filtered.csv", header=T)
food_names <-
  read.csv("~/GitHub/ASA24_MiGrowD/Data/cnf-fcen-csv/FOOD NAME.csv",
           header = T)
#v18_items <- read.csv("E:/ASA24/ASA24v2018_export/TKT_2022-02-14_52444_Items_MiGrowD Filtered.csv", header=T)
food_groups <-
  read.csv("~/GitHub/ASA24_MiGrowD/Data/cnf-fcen-csv/FOOD GROUP.csv",
           header = T)
# v18_responses <-
#   read.csv(
#     "E:/ASA24/ASA24v2018_export/TKT_2022-02-14_52444_Responses_MiGrowD Filtered.csv",
#     header = T
#   )

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

# Portion Outliers

beverage_outliers <-
  getFoodGroupOutliers(food_names, v16_items, c(14), 1892.5)
meat_outliers <-
  getFoodGroupOutliers(food_names, v16_items, c(5, 7, 10, 13, 15, 17), 342)
mixed_outliers <-
  getFoodGroupOutliers(food_names, v16_items, c(22), 1440)
snack_outliers <-
  getFoodGroupOutliers(food_names, v16_items, c(25), 226)

beverage_outliers <-
  getFoodGroupOutliers(food_names, v18_items, c(14), 1892.5)
meat_outliers <-
  getFoodGroupOutliers(food_names, v18_items, c(5, 7, 10, 13, 15, 17), 342)
mixed_outliers <-
  getFoodGroupOutliers(food_names, v18_items, c(22), 1440)
snack_outliers <-
  getFoodGroupOutliers(food_names, v18_items, c(25), 226)

#=========================== 4. High Alcohol and Caffeine ======================

alcoholAndCaffeineErrors <-
  getAlcoholAndCaffeineErrors(final, "CAFF", 50, "ALC", 1)

#=========================== 5. Duplicates =====================================
duplicates <- total[duplicated(final[, colRange]), ]


#===================== 6. Find all outliers ====================================

final <- getAlcoholAndCaffeineErrors(final, "CAFF", 50, "ALC", 1)
final <- findOutliers5_95(final, "age_diet_report", thresholds)
final <- findOutliersIQR(final, "age_diet_report", thresholds, 2)
write.csv(final, "Results/outliers_table.csv")
final <- findTextOutliers(final, responses)



# #======================= 7. Missing, Broken, Alc/Caf, NutrOutlier ==============
# missing_cases <- getHighMissingCases(total, 10, colRange = colRange)
# broken_entries <- getBrokenEntries(total, "RecallStatus", 5)
# duplicates <- total[duplicated(total[, colRange]), ]
# alcoholAndCaffeineErrors <-
#   getAlcoholAndCaffeineErrors(final, "CAFF", 50, "ALC", 1)
# outliers595 <-
#   findOutliers5_95(dplyr::setdiff(total, missing_cases),
#                    "age_diet_report",
#                    thresholds)
# outliersIQR_3 <-
#   findOutliersIQR(dplyr::setdiff(total, missing_cases),
#                   "age_diet_report",
#                   thresholds,
#                   3)
# outliersIQR_2 <-
#   findOutliersIQR(dplyr::setdiff(total, missing_cases),
#                   "age_diet_report",
#                   thresholds,
#                   2)
# beverage_outliers.v16 <-
#   getFoodGroupOutliers(food_names, v16_items, c(14), 1892.5)
# beverage_outliers.v18 <-
#   getFoodGroupOutliers(food_names, v18_items, c(14), 1892.5)
# meat_outliers.v16 <-
#   getFoodGroupOutliers(food_names, v16_items, c(5, 7, 10, 13, 15, 17), 342)
# meat_outliers.v18 <-
#   getFoodGroupOutliers(food_names, v18_items, c(5, 7, 10, 13, 15, 17), 342)
# mixed_outliers.v16 <-
#   getFoodGroupOutliers(food_names, v16_items, c(22), 1440)
# mixed_outliers.v18 <-
#   getFoodGroupOutliers(food_names, v18_items, c(22), 1440)
# snack_outliers.16 <-
#   getFoodGroupOutliers(food_names, v16_items, c(25), 226)
# snack_outliers.16 <-
#   getFoodGroupOutliers(food_names, v18_items, c(25), 226)
# 
# common <- dplyr::intersect(missing_cases, broken_entries) #8
# common <- dplyr::intersect(missing_cases, duplicates) #7
# common <- dplyr::intersect(missing_cases, textOutliers) #0
# common <-
#   dplyr::intersect(broken_entries, alcoholAndCaffeineErrors) #2
# common <- dplyr::intersect(broken_entries, duplicates) #7
# common <- dplyr::intersect(broken_entries, outliers595) #6
# common <- dplyr::intersect(broken_entries, outliersIQR_3) #1
# common <- dplyr::intersect(broken_entries, outliersIQR_2) #2
# common <- dplyr::intersect(broken_entries, textOutliers) #1
# common <- dplyr::intersect(alcoholAndCaffeineErrors, outliers595) #2
# common <- dplyr::intersect(alcoholAndCaffeineErrors, outliersIQR_3) #0
# common <- dplyr::intersect(alcoholAndCaffeineErrors, outliersIQR_2) #0
# common <- dplyr::intersect(alcoholAndCaffeineErrors, textOutliers) #2
# common <- dplyr::intersect(outliers595, outliersIQR_3) #5
# common <- dplyr::intersect(outliers595, outliersIQR_2) #13
# common <- dplyr::intersect(outliers595, textOutliers) #16
# common <- dplyr::intersect(duplicates, textOutliers) #0
# 
# 
# to_study <- dplyr::union(missing_cases, broken_entries) #18 +10
# to_study <- dplyr::union(to_study, duplicates) #25, +7
# to_study <- dplyr::union(to_study, alcoholAndCaffeineErrors) #32, +7
# to_study <- dplyr::union(to_study, outliers595) #92, +59
# to_study <- dplyr::union(to_study, outliersIQR_3) #92, 0
# to_study <- dplyr::union(to_study, outliersIQR_2) #92, 0
# to_study <- dplyr::union(to_study, textOutliers) #106, +14
# #===============================================================================
# final <- total
# 
# missing_cases <- getHighMissingCases(total, 10, colRange = colRange)
# final <- dplyr::setdiff(final, missing_cases)
# 
# broken_entries <- getBrokenEntries(final, "RecallStatus", 5)
# final <- dplyr::setdiff(final, broken_entries)
