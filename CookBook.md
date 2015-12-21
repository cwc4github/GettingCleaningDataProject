# CookBook for Getting and Cleaning Data Course Project
# Variables in the Tidy Data Set and Their Descriptions
* subject: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30
* activityLabel: Activities, including WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
* Extract features: The details are described below

## Details of the extract features:
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

* tBodyAcc-XYZ
* tGravityAcc-XYZ
* tBodyAccJerk-XYZ
* tBodyGyro-XYZ
* tBodyGyroJerk-XYZ
* tBodyAccMag
* tGravityAccMag
* tBodyAccJerkMag
* tBodyGyroMag
* tBodyGyroJerkMag
* fBodyAcc-XYZ
* fBodyAccJerk-XYZ
* fBodyGyro-XYZ
* fBodyAccMag
* fBodyAccJerkMag
* fBodyGyroMag
* fBodyGyroJerkMag


The set of variables that were estimated from these signals are: 

* mean(): Mean value
* std(): Standard deviation
* meanFreq(): Weighted average of the frequency components to obtain a mean frequency






# The Important R Code Used in `run_analysis.R`

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
extractFeatures <- grepl("mean\\(\\)|std\\(\\)", features)
```

## 1. Loading data

Load and process X_test & y_test data. 
```
XTest <- read.table(file.path(dataDir, "test/X_test.txt"))
yTest <- read.table(file.path(dataDir, "test/y_test.txt")) 
names(XTest) <- features 
```

Load and process X_train & y_train data. 
```
XTrain <- read.table(file.path(dataDir, "train/X_train.txt") )
yTrain <- read.table(file.path(dataDir, "train/y_train.txt") )
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

yTrain[,2] <- activityLabels[yTrain[,1]] 
names(yTrain) <- c("activityID", "activityLabel") 
```

## 4. Merge to a data set with appropriate labels and descriptive variable names.
Bind data from y_test.txt and x_test.txt data only with extractFeatures 
```
subjectTest <- read.table(file.path(dataDir, "test/subject_test.txt") )
names(subjectTest) <- "subject" 
testData <- cbind(as.data.table(subjectTest), yTest, XTest) 
```

Bind data from y_train.txt and x_train.txt data only with extractFeatures 
```
subjectTrain <- read.table(file.path(dataDir, "train/subject_train.txt") )
names(subjectTrain) <- "subject" 
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

