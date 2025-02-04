

getBrokenEntries <- function(dataframe, statusCol, brokenCode) {
    removed<-dataframe[which(dataframe[,statusCol]==brokenCode),]
    return(removed)
}

getDuplicateEntries <- function(dataframe, colRange=c(1:ncol(dataframe))) {
    duplicates<-dataframe[duplicated(dataframe[,colRange]),]
    return(duplicated)
}

getAlcoholAndCaffeineErrors <- function(dataframe, cafCol, cafLimit, alcCol, alcLimit) {
    dataframe<-mutate(dataframe, outliers_alcohol=rep("N", nrow(dataframe)))
    dataframe<-mutate(dataframe, outliers_caffeine=rep("N", nrow(dataframe)))
    for(i in 1:nrow(dataframe)) {
        if(dataframe[i,alcCol] > alcLimit) {
            dataframe[i,]$outliers_alcohol<-"Y"
        }
        if(dataframe[i,cafCol] > cafLimit) {
            dataframe[i,]$outliers_caffeine<-"Y"
        }
    }
    return(dataframe)
}

getHighMissingCases <- function(dataframe, pct_miss, colRange=c(1:ncol(dataframe))) {
    library(naniar)
    missing_cases<-dataframe[miss_case_summary(dataframe[,colRange])[which(miss_case_summary(dataframe[,colRange])$pct_miss>pct_miss),]$case,]
    return(missing_cases)
}

findOutliers5_95 <- function(dataframe, ageCol, thresholds) {
    original_nrow<-nrow(dataframe)
    for(j in unique(thresholds$nutrient)) {
        colname<-paste0("outlier_", j,"_5_95")
        dataframe<-mutate(dataframe, !!colname:=rep("N", nrow(dataframe)))
    }
    for(i in 1:nrow(dataframe)) {
        for (age in unique(thresholds$age)) {
            if (round(dataframe[i, ageCol]/12) == age) {
                for (j in unique(thresholds$nutrient)) {
                    if (dataframe[i, j] < thresholds[which(thresholds$nutrient == j &
                                                        thresholds$age == age), ]$perc5 ||
                        dataframe[i, j] > thresholds[which(thresholds$nutrient == j &
                                                        thresholds$age == age), ]$perc95) {
                        dataframe[i,paste0("outlier_", j,"_5_95")] <-"Y"
                    }
                }
            }
        }
    }
    return(dataframe)
}

findOutliersIQR <- function(dataframe, ageCol, thresholds, IQR_times) {
    for(j in unique(thresholds$nutrient)) {
        colname<-paste0("outlier_", j,"_IQR_", IQR_times)
        dataframe<-mutate(dataframe, !!colname:=rep("N", nrow(dataframe)))
    }
    for(i in 1:nrow(dataframe)) {
        for (age in unique(thresholds$age)) {
            if (round(dataframe[i, ageCol]/12) == age) {
                for (j in unique(thresholds$nutrient)) {
                    if (dataframe[i, j] > thresholds[which(thresholds$nutrient ==
                                                                j &
                                                                thresholds$age == age), ]$perc75 + IQR_times * thresholds[which(thresholds$nutrient ==
                                                                                                                        j & thresholds$age == age), ]$IQR) {
                        dataframe[[colname]][i] <-"Y"
                    }
                }
            }
        }
    }
    return(dataframe)
}

getFoodGroupOutliers <- function(food_names, items, foodGroups, limit) {

    colname<-paste0("outlier_", foodGroups[1])
    names<-food_names[which(food_names$FoodGroupID %in% foodGroups),]
    food_items<-items[which(items$FoodCode %in% names$FoodCode),]
    
    outliers<-food_items[which(food_items$FoodAmt>=limit),]
}

findTextOutliers <- function(dataframe, responses) {
    dataframe<-mutate(dataframe, text_outliers=rep('N', nrow(dataframe)))
    textOutliers<-{}
    for(j in 1:ncol(responses)) {
        if(class(responses[,j])=="character") {
            for(i in 1:nrow(responses)) {
              #print(paste0("[i,j]=[",i,",",j,"], response=", responses[i,j]))
                if(grepl("\\bOther\\b", gsub(" ", "", responses[i,j], useBytes = TRUE))) {
                    dataframe[which(dataframe$UserName==responses[i,]$UserName & dataframe$RecallNo==responses[i,]$RecallNo),]$text_outliers<-"Y"
                    textOutliers<-rbind(textOutliers, dataframe[which(dataframe$UserName==responses[i,]$UserName & dataframe$RecallNo==responses[i,]$RecallNo),])
                    #print(paste0("[i,j]=[",i,",",j,"], response=", responses[i,j]))
                }
                else if(grepl("Match not found", responses[i,j])) {
                    dataframe[which(dataframe$UserName==responses[i,]$UserName & dataframe$RecallNo==responses[i,]$RecallNo),]$text_outliers<-"Y"
                    textOutliers<-rbind(textOutliers, dataframe[which(dataframe$UserName==responses[i,]$UserName & dataframe$RecallNo==responses[i,]$RecallNo),])
                    #print(paste0("[i,j]=[",i,",",j,"], response=", responses[i,j]))
                }
            }
        }
    }
    return(dataframe)
}
