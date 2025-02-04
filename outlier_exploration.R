


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
packages <- c("caret", "dplyr", "rpart", "rpart.plot", "xgboost")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# source("~/GitHub/ASA24_MiGrowD/Code/3.NCI&literature.R")

# ====    2  Data  =============================================================


subject2 <-
  read.sas7bdat("E:/Growth analysis/Growth2/Raw3_Oct2023/instance_2023_10_30.sas7bdat")

# ====    3 Outlier exploration  ===============================================


outliers <- final[which(final$outlier == "Y"), ]
ids_outliers <- outliers$subject
unique_cases <- unique(outliers$subject)
zbmi_out <- subject2[which(total$subject %in% ids_outliers), ]
user_name_outliers <- outliers$UserName
out_exp <- out_exp[which(out_exp$UserName %in% user_name_outliers), ]
zbmi_out2 <- distinct(zbmi_out, subject, .keep_all = TRUE)
View(zbmi_out2)
zbmi_out <- subject2[which(subject2$subject %in% ids_outliers), ]
average_zbmi_subject <-
  group_by(zbmi_out, subject) %>% summarize(m = mean(ZBMI))
View(average_zbmi_subject)
average_zbmi_subject <-
  group_by(zbmi_out, subject) %>% summarize(mean_zbmi = mean(ZBMI))
zbmi_out[is.nan(zbmi_out)] <- NA


#------- Rule mining -----------------------------------------------------------




final <- mutate(final, outlier = "N")
for (i in 1:nrow(final)) {
  if (any(final[i, c(136:143)] == "Y")) {
    final[i,]$outlier <- "Y"
  }
  else {
    final[i,]$outlier <- "N"
  }
}


#final<-rowwise(mutate(final, outlier=ifelse(any(final[,c(136:143)]=="Y"),"Y","N")))
class_data <- final[, c(78:114, 144)]
class_data$outlier <- as.factor(class_data$outlier)

set.seed(7)
inTraining <-
  createDataPartition(class_data$outlier, p = .75, list = FALSE)
training <- class_data[inTraining,]
testing  <- class_data[-inTraining,]

control <-
  trainControl(
    method = "repeatedcv",
    number = 10,
    repeats = 3,
    classProbs = T,
    summaryFunction = twoClassSummary
  )

# rpart Tree
set.seed(7)
fit.rpart <-
  train(outlier ~ .,
        data = training,
        method = "rpart",
        trControl = control)

rpart.rules(fit.rpart$finalModel, cover = T, nn = T)

training$outlier <- ifelse(training$outlier == "Y", 1, 0)
# XGBoost Tree
set.seed(7)
fit.xgb <-
  train(
    outlier ~ .,
    data = training,
    method = "xgbTree",
    verbosity = 0,
    trControl = control
  )

xgb.plot.shap(fit.xgb$finalModel)

xgb.plot.shap.summary(fit.xgb$finalModel)
