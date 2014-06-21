run_analysis<-function()
{

#Part 0 - prepare envirovement and download information
    ## load necessary libraries
    library("reshape")
    library("data.table")
  
    ## define different constant: url, etc.
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

  
    ##prepare environment
    path <- getwd()
    path <- file.path(path,"clean_data")
    if (!file.exists(path))
    {
      dir.create(path)
    }
    setwd(path)
  
    ##download and unzip information: download 60mb may took about minute
    download.file(url, file.path(path, "data.zip"))
  
    ##archive files is in the UCI HAR Dataset directory
    unzip("data.zip")
    path_new <- file.path(path, "UCI HAR Dataset")
  
  
#Part 1 merge training and test files
  
    ##read subject files
    dt_subjet_train   <- fread(file.path(path_new, "train", "subject_train.txt"))
    dt_subjet_test    <- fread(file.path(path_new, "test",  "subject_test.txt"))
  
    ##read activity files
    dt_activity_train <- fread(file.path(path_new, "train", "Y_train.txt"))
    dt_activity_test  <- fread(file.path(path_new, "test", "Y_test.txt"))
    
    ## fread problematic. use read.table + data.table couple
    dt_train <- read.table(file.path(path_new, "train", "X_train.txt"))
    dt_train <- data.table(dt_train)
    dt_test <-  read.table(file.path(path_new, "test", "X_test.txt"))
    dt_test <-  data.table(dt_test)
  
    ## rbind test and train data 
    ##names()<- obselete, need to use setnames
    dt_subject <- rbind(dt_subjet_train, dt_subjet_test)
    setnames(dt_subject, "V1", "subject")
  
    dt_activity <- rbind(dt_activity_train, dt_activity_test)
    setnames(dt_activity, "V1", "activityNum")
    
    dt <- rbind(dt_train, dt_test)
    dt <- cbind(dt_subject,dt_activity,dt)
  
    setkey(dt, subject, activityNum)

#Part 2 Extracts only the measurements on the mean and standard deviation for each measurement.
  
    dt_features <- fread(file.path(path_new, "features.txt"))
    setnames(dt_features, names(dt_features), c("feature_num", "feature_name"))
    dt_features_subset <- dt_features[grepl("mean\\(\\)|std\\(\\)", dt_features$feature_name)]
    
    #add v to feature number. 1->v1. it uses after in select to choose necessary feauters
    dt_features_subset$feature_code <- dt_features_subset[, paste0("V", feature_num)]
    select <- c("subject", "activityNum", dt_features_subset$feature_code)
    dt_subset <- dt[, select, with = FALSE]

  
#Part 3 Uses descriptive activity names to name the activities in the data set

    dt_activity_names <- fread(file.path(path_new, "activity_labels.txt"))
    setnames(dt_activity_names, names(dt_activity_names), c("activityNum", "activity_name"))
  

#Part 4 Appropriately labels the data set with descriptive activity names. 
  
    dt_subset_merged <- merge(dt_subset, dt_activity_names, by = "activityNum", all.x = TRUE)
    setkey(dt_subset_merged, subject, activityNum, activity_name)
    
    #the date is not tidy. We need to melt the table
    dt_melt <- data.table(melt(dt_subset_merged, key(dt_subset_merged), variable="feature_code"))
  
    dt <- merge(dt_melt, dt_features_subset[, list(feature_num, feature_code, feature_name)], by = "feature_code", 
              all.x = TRUE)  
  
    #create variables for activite and features names
    dt$activity <- factor(dt$activity_name)
    dt$feature <- factor(dt$feature_name)
  
  #separate  features from feature_name
    grepthis <- function(regex) {
      grepl(regex, dt$feature)
    }
    ## Features with 2 categories use advise Of Benjamin
    n <- 2
    y <- matrix(seq(1, n), nrow = n)
    x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
    dt$feat_domain <- factor(x %*% y, labels = c("Time", "Freq"))
    x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
    dt$feat_instrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
    x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
    dt$feat_acceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
    x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
    dt$feat_variable <- factor(x %*% y, labels = c("Mean", "SD"))
    ## Features with 1 category
    dt$feat_jerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
    dt$feat_magnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))
    ## Features with 3 categories
    n <- 3
    y <- matrix(seq(1, n), nrow = n)
    x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
    dt$feat_a-xis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))


#Part 5 make new tidy ds with averages of feautres
  
    setkey(dt, subject, activity, feat_domain, feat_acceleration, feat_instrument, 
       feat_Jerk, feat_magnitude, feat_variable, feat_axis)
    dt_tidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]

    write.table(dt_tidy,file=file.path(path_new,"new_tidy.txt"))

  
  
}