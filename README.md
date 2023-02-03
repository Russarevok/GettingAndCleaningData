# Getting And Cleaning Data Readme

## Files

#### CodeBook.md  
Code that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.

#### run_analysis.R

##### How the script works

##### 1. Merges the training and the test sets to create one data set.

**Some Key functions used**

Function Name | What it was used for
------------- | ----------------------
rename | renaming columns
cbind | combine the data together by column for both test and training data. Snippet of code for training data: full_train <- cbind(subject_train,y_train,x_train)
rbind | unioning the training and test data together: fullset <- rbind(full_train, full_test)
grepl | used to extract just the mean and std columns + subject and activity
sub | leveraged to make variable names friendlier.

##### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

**Some Key functions used**

Function Name | What it was used for
------------- | ----------------------
grepl | used to extract just the mean and std columns + subject and activity


##### 3. Uses descriptive activity names to name the activities in the data set

Used a lookup table to replace all V1, V2, V3, ... column names with one provided from features.txt file.

```{r}
# load feature labels into a dataframe
feature_labels_file = "features.txt"
feature_labels <- read.table(feature_labels_file,sep = "",header = FALSE)

# Data frame with column name substitutions
x_test_colnames_lookup = data.frame(old=names(x_test), new=feature_labels["V2"], stringsAsFactors=FALSE)

names(x_test)[match(x_test_colnames_lookup[,"old"], names(x_test))] = x_test_colnames_lookup[,"V2"]
```

##### 4. Appropriately labels the data set with descriptive variable names. 

**Variable names have been renamed to friendlier names as follows:**

* ^f -> frequency
* ^t -> time
* Acc -> Accelerometer
* Gyro -> Gyroscope
* Mag -> Magnitude
* mean() -> Mean
* std() -> StandardDeviation

**Some Key functions used**

Function Name | What it was used for
------------- | ----------------------
sub | leveraged to make variable names friendlier.


##### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

  
