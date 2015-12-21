## Create one R script called run_analysis.R that does the following: 
## 1. Merges the training and the test sets to create one data set. 
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set 
## 4. Appropriately labels the data set with descriptive activity names. 
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
 
# Load library
if (!require("data.table")) { 
  install.packages("data.table") 
} 

library(data.table) 


# Download zip file 
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfilename <- "Dataset.zip"
if (!file.exists(zipfilename)) {
  download.file(fileurl, zipfilename)
}


# Extract zip file
dataDir <- "UCI HAR Dataset"
if (!file.exists(dataDir)) {
  unzip(zipfilename)
}

list.files(dataDir, recursive = TRUE)

# Load: activity labels 
activityLabels <- read.table(file.path(dataDir, "activity_labels.txt"))[,2] 
 

# Load: data column names 
features <- read.table(file.path(dataDir, "features.txt"))[,2] 
 

# Extract only the measurements on the mean and standard deviation for each measurement. 
extractFeatures <- grepl("mean\\(\\)|std\\(\\)", features) 
 

# Load and process X_test & y_test data. 
XTest <- read.table(file.path(dataDir, "test/X_test.txt"))
yTest <- read.table(file.path(dataDir, "test/y_test.txt")) 
names(XTest) <- features 

# Load and process X_train & y_train data. 
XTrain <- read.table(file.path(dataDir, "train/X_train.txt") )
yTrain <- read.table(file.path(dataDir, "train/y_train.txt") )
names(XTrain) <- features 


# Merges the training and the test sets to create one data set
subjectTest <- read.table(file.path(dataDir, "test/subject_test.txt") )
names(subjectTest) <- "subject" 
subjectTrain <- read.table(file.path(dataDir, "train/subject_train.txt") )
names(subjectTrain) <- "subject" 
dataTestMerge <- cbind(as.data.table(subjectTest), yTest, XTest)
dataTrainMerge <- cbind(as.data.table(subjectTrain), yTrain, XTrain)
dataAllMerge <- rbind(dataTestMerge, dataTrainMerge) 
 
# Extracting before merging is easier. The steps are as following
# Extract only the measurements on the mean and standard deviation for each measurement. 
XTest <- XTest[,extractFeatures] 
XTrain = XTrain[,extractFeatures] 


# Load activity labels 
yTest[,2] <- activityLabels[yTest[,1]] 
names(yTest) <- c("activityID", "activityLabel") 

yTrain[,2] <- activityLabels[yTrain[,1]] 
names(yTrain) <- c("activityID", "activityLabel") 


# Bind data from y_test.txt and x_test.txt data only with extractFeatures 
subjectTest <- read.table(file.path(dataDir, "test/subject_test.txt") )
names(subjectTest) <- "subject" 
testData <- cbind(as.data.table(subjectTest), yTest, XTest) 


# Bind data from y_train.txt and x_train.txt data only with extractFeatures 
subjectTrain <- read.table(file.path(dataDir, "train/subject_train.txt") )
names(subjectTrain) <- "subject" 
trainData <- cbind(as.data.table(subjectTrain), yTrain, XTrain) 


# Merge test and train data 
dataAll <- rbind(testData, trainData) 


idLabels <- c("subject", "activityID", "activityLabel") 
dataLabels <- setdiff(colnames(dataAll), idLabels) 
meltData <- melt(dataAll, id = idLabels, measure.vars = dataLabels) 


# Apply mean function to dataset using dcast function 
tidyData   = dcast(meltData, subject + activityLabel ~ variable, mean) 

# Ouput tidyDat to tidyData.txt
write.table(tidyData, file = "./tidyData.txt", row.name=FALSE) 

