# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
# setwd("C:/Users/RussS/Documents/Coursera/Data Science Specialization Certificate/Course 3 - Getting and Cleaning Data/Week4/Course Project/UCI HAR Dataset")
#
# Each activity has many variables (features).
#

# Get library so that we can easily query for distinct values
library(sqldf)

# Get dplyr library
library(dplyr)

# load data.table package - required for setnames function
library(data.table)

##
## 1. Merge the training and the test sets to create one data set.
##

# load activity labels into a dataframe
activity_labels_file = "activity_labels.txt"
activity_labels <- read.table(activity_labels_file,sep = "",header = FALSE)
# str(activity_labels)
# activity_labels
# V1                 V2
# 1  1            WALKING
# 2  2   WALKING_UPSTAIRS
# 3  3 WALKING_DOWNSTAIRS
# 4  4            SITTING
# 5  5           STANDING
# 6  6             LAYING

# rename activity labels columns to something meaningful
activity_labels  <- rename(activity_labels, activityid = V1, activityname = V2)

# load feature labels into a dataframe
feature_labels_file = "features.txt"
feature_labels <- read.table(feature_labels_file,sep = "",header = FALSE)
#str(feature_labels)

#
# Training data
#

# get subject info
subject_train_file <- "train/subject_train.txt"
subject_train <- read.table(subject_train_file,sep = "",header = FALSE)
#str(subject_train)
#head(subject_train)
 # 'data.frame':	7352 obs. of  1 variable:
 #   $ V1: int  1 1 1 1 1 1 1 1 1 1 ...

# rename subject_train column to subject
subject_train <- rename(subject_train, subject = V1)

# confirm what the data looks like
subject_train_distinct <- sqldf("select distinct subject from subject_train")
#subject_train_distinct
# 21 distinct values (one for each subject)

# y_train.txt
# these are ids for each of the 6 activities
y_train_file <- "train/y_train.txt"
y_train <- read.table(y_train_file,sep = "",header = FALSE)
#str(y_train)
# 'data.frame':	7352 obs. of  1 variable:
#   $ V1: int  5 5 5 5 5 5 5 5 5 5 ...

# confirm what the data looks like
y_train_distinct <- sqldf("select distinct V1 from y_train")
# y_train_distinct
# 6 distinct values - one for each activity

# rename y_train column to activityid
y_train <- rename(y_train, activityid = V1)
#str(y_train)

x_train_file <- "train/X_train.txt"
x_train <- read.table(x_train_file,sep = "",header = FALSE)
#str(x_train)
# 'data.frame':	7352 obs. of  561 variables:

# Data frame with column name substitutions
x_train_colnames_lookup = data.frame(old=names(x_train), new=feature_labels["V2"], stringsAsFactors=FALSE)
#x_train_colnames_lookup

# replace V1, V2, ... column names with readable ones
names(x_train)[match(x_train_colnames_lookup[,"old"], names(x_train))] = x_train_colnames_lookup[,"V2"]
#str(x_train)

# cbind the data together 
full_train <- cbind(subject_train,y_train,x_train)
#str(full_train)

#
# Test data
#

# get subject info
subject_test_file <- "test/subject_test.txt"
subject_test <- read.table(subject_test_file,sep = "",header = FALSE)
#str(subject_test)
#head(subject_test)
# 'data.frame':	2947 obs. of  1 variable:
# $ V1: int  2 2 2 2 2 2 2 2 2 2 ...

# rename subject_test column to subject
subject_test <- rename(subject_test, subject = V1)
#str(subject_test)

# confirm what the data looks like
subject_test_distinct <- sqldf("select distinct subject from subject_test")
#subject_test_distinct
# 9 distinct values (one for each subject)

# y_test.txt
# these are ids for each of the 6 activities
y_test_file <- "test/y_test.txt"
y_test <- read.table(y_test_file,sep = "",header = FALSE)
#str(y_test)
# 'data.frame':	2947 obs. of  1 variable:
# $ V1: int  5 5 5 5 5 5 5 5 5 5 ...

# confirm what the data looks like
y_test_distinct <- sqldf("select distinct V1 from y_test")
# y_test_distinct
# 6 distinct values - one for each activity

# rename y_test column to activityid
y_test <- rename(y_test, activityid = V1)
#str(y_test)
# 'data.frame':	2947 obs. of  1 variable:
#   $ activityid: int  5 5 5 5 5 5 5 5 5 5 ...

x_test_file <- "test/X_test.txt"
x_test <- read.table(x_test_file,sep = "",header = FALSE)
#str(x_test)
# 'data.frame':	2947 obs. of  561 variables:

# Data frame with column name substitutions
x_test_colnames_lookup = data.frame(old=names(x_test), new=feature_labels["V2"], stringsAsFactors=FALSE)
#x_test_colnames_lookup

names(x_test)[match(x_test_colnames_lookup[,"old"], names(x_test))] = x_test_colnames_lookup[,"V2"]
#str(x_test)

# cbind the data together 
full_test <- cbind(subject_test,y_test,x_test)
#str(full_test)

fullset <- rbind(full_train, full_test)
# str(fullset)
# 'data.frame':	10299 obs. of  563 variables:

##
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 
# use grep on the column names that that you want.
# Week 4 stuff
fullset_colnames <- names(fullset)
subset <- fullset[ grepl("subject|activityid|mean()|std()",fullset_colnames) & !grepl("meanFreq()", fullset_colnames) ]
#str(subset)
# 'data.frame':	10299 obs. of  68 variables:

##
## 3. Uses descriptive activity names to name the activities in the data set
##

# join to activity_labels data frame to get the actual activity name
activitylabelset <- arrange(inner_join(activity_labels,subset,by="activityid"),activityid)

# remove activityid column
activitylabelset <- subset( activitylabelset, select = -activityid )
#activitylabelset
#str(activitylabelset)
##
## 4. Appropriately labels the data set with descriptive variable names. 
## 

# a) replace as follows:
# ^f - frequency
# ^t - time
# Acc - Accelerometer
# Gyro - Gyroscope
# Mag - Magnitude
# mean()
# std() - StandardDeviation

sub("^f","frequency",names(activitylabelset))

# create a new set of decriptive variable names
oldcolnames <- names(activitylabelset)
#oldcolnames

newcolnames <- sub("^f","frequency",oldcolnames,)
newcolnames <- sub("^t","time",newcolnames,)
newcolnames <- sub("Acc","Accelerometer",newcolnames,)
newcolnames <- sub("Gyro","Gyroscope",newcolnames,)
newcolnames <- sub("Mag","Magnitude",newcolnames,)
newcolnames <- sub("std\\(\\)","StandardDeviation",newcolnames,)
newcolnames <- sub("mean\\(\\)","Mean",newcolnames,)

# set the old names to the new ones
setnames(activitylabelset, old=oldcolnames, new=newcolnames)
#str(activitylabelset)
#names(activitylabelset)

##
## 5. From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.
## 

tidyaggdata <- activitylabelset %>%
  group_by(subject, activityname) %>%
  summarize_all(funs(mean))

View(tidyaggdata)

write.table(tidyaggdata, "tidyaggdata", row.name=FALSE)

# Code to transpose into columns for documentation
#
# tidyaggdatacolnames <- data.frame(as.list(names(tidyaggdata))) 
# tidyaggdatacolnames <- transpose(tidyaggdatacolnames)
# 
# tidyaggdatacolnames
