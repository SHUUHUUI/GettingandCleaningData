setwd("~/Desktop/Data Sience Course")

#let's download and unzip the file.

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./Dataset.zip", method="curl")
unzip(zipfile="Dataset.zip")

#Read tables.

features <- read.table("UCI HAR Dataset/features.txt", col.names = c("number", "signal"))
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("number", "label"))

head(features)

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names ="subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$signal)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names ="label")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names ="subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$signal)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names ="label")


# 1. Merges the training and the test sets to create one data set.

x_merge <- rbind(x_test, x_train)
y_merge <- rbind(y_test, y_train)
subject_merge <- rbind(subject_test, subject_train)
merge <- cbind(subject_merge, y_merge, x_merge)

head(merge)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#We will download dplyr first. The code is : install.packages("dplyr")

library(dplyr)
extract <- merge%>%select(subject, label, contains("mean"), contains("std"))

#Use another method:
extract2 <- select(merge, subject, label, contains("mean"), contains("std"))


# 3. Uses descriptive activity names to name the activities in the data set

activity_labels$label <- gsub("_"," ",tolower(activity_labels$label))
extract$label <- activity_labels[extract$label, 2]

# 4. Appropriately labels the data set with descriptive variable names. 

names(extract)[2] = "activity"

names(extract) <- gsub("^t","time", names(extract))
names(extract) <- gsub("^f","frequency", names(extract))

names(extract)<-gsub("Acc", "Accelerometer", names(extract))
names(extract)<-gsub("Gyro", "Gyroscope", names(extract))
names(extract)<-gsub("BodyBody", "Body", names(extract))
names(extract)<-gsub("Mag", "Magnitude", names(extract))

names(extract)<-gsub("tBody", "timeBody", names(extract))
names(extract)<-gsub("-mean()", "Mean", names(extract), ignore.case = TRUE)
names(extract)<-gsub("-std()", "std", names(extract), ignore.case = TRUE)
names(extract)<-gsub("-freq()", "frequency", names(extract), ignore.case = TRUE)
names(extract)<-gsub("angle", "Angle", names(extract))
names(extract)<-gsub("gravity", "Gravity", names(extract))

colnames(extract)

# 5. From the data set in step 4, creates a second, independent tidy data set with
# the average of each variable for each activity and each subject.

tidydata <- aggregate(.~subject+activity, extract, mean)
View(tidydata)
write.table(tidydata, file="tidy data.txt", row.name=FALSE)