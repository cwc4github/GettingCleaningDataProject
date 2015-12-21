# CookBook for Getting and Cleaning Data Course Project


## 0. Preprocess
Load library
```
if (!require("data.table")) { 
  install.packages("data.table") 
} 

library(data.table) 
```

Download zip file 
```
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfilename <- "Dataset.zip"
if (!file.exists(zipfilename)) {
  download.file(fileurl, zipfilename)
}
```

Extract zip file
```
dataDir <- "UCI HAR Dataset"
if (!file.exists(dataDir)) {
  unzip(zipfilename)
}
```

Load: activity labels 
```
activityLabels <- read.table(file.path(dataDir, "activity_labels.txt"))[,2] 
```


Load: data column names 
```
features <- read.table(file.path(dataDir, "features.txt"))[,2] 
```

Extract only the measurements on the mean and standard deviation for each measurement. 
```
extractFeatures <- grepl("mean|std", features) 
```

## 1. Loading data

Load and process X_test & y_test data. 
```
XTest <- read.table(file.path(dataDir, "test/X_test.txt"))
yTest <- read.table(file.path(dataDir, "test/y_test.txt")) 
subjectTest <- read.table(file.path(dataDir, "test/subject_test.txt") )
names(XTest) <- features 
```

Load and process X_train & y_train data. 
```
XTrain <- read.table(file.path(dataDir, "train/X_train.txt") )
yTrain <- read.table(file.path(dataDir, "train/y_train.txt") )
subjectTrain <- read.table(file.path(dataDir, "train/subject_train.txt") )
names(XTrain) <- features 
```

## 2. Extract only the measurements on the mean and standard deviation for each measurement
```
XTest <- XTest[,extractFeatures] 
XTrain = XTrain[,extractFeatures] 
```

## 3. Uses descriptive activity names to name the activities in the data sets
Load activity labels 
```
yTest[,2] <- activityLabels[yTest[,1]] 
names(yTest) <- c("activityID", "activityLabel") 
names(subjectTest) <- "subject" 

yTrain[,2] <- activityLabels[yTrain[,1]] 
names(yTrain) <- c("activityID", "activityLabel") 
names(subjectTrain) <- "subject" 
```

## 4. Merge to a data set with appropriate labels and descriptive variable names.
Bind data from y_test.txt and x_test.txt data only with extractFeatures 
```
testData <- cbind(as.data.table(subjectTest), yTest, XTest) 
```

Bind data from y_train.txt and x_train.txt data only with extractFeatures 
```
trainData <- cbind(as.data.table(subjectTrain), yTrain, XTrain) 
```

Bind the test and train data
```
dataAll <- rbind(testData, trainData) 
```

## 5. Preprocess for creating a tidy data set 
```
idLabels <- c("subject", "activityID", "activityLabel") 
dataLabels <- setdiff(colnames(dataAll), idLabels) 
meltData <- melt(dataAll, id = idLabels, measure.vars = dataLabels) 
```

## 6. Generate a tidy data set
Apply mean function to each variable for each activity and each subject and use dcast function to reorder the tidy data set 
```
tidyData   = dcast(meltData, subject + activityLabel ~ variable, mean) 
```

## 7. Ouput tidyDat to tidyData.txt
```
write.table(tidyData, file = "./tidyData.txt", row.name=FALSE) 
```

