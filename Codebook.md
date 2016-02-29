---
title: "Getting and Cleaning Data Course Project"
output: html_document
---


# Introduction

There original data comes from the smartphone accelerometer and gyroscope 3-axial raw signals, 
which have been processed using various signal processing techniques to measurement vector consisting
of 561 features. For detailed description of the original dataset, please see `features_info.txt` in
the zipped dataset file.

Description of abbreviations of measurements

leading time or freq is based on time or frequency measurements.
Body = related to body movement.
Gravity = acceleration of gravity
Acc = accelerometer measurement
Gyro = gyroscopic measurements
Jerk = sudden movement acceleration
Mag = magnitude of movement
mean and SD are calculated for each subject for each activity for each mean and SD measurements.
The units given are g’s for the accelerometer and rad/sec for the gyro and g/sec and rad/sec/sec for the corresponding jerks.

These signals were used to estimate variables of the feature vector for each pattern:
‘-XYZ’ is used to denote 3-axial signals in the X, Y and Z directions. They total 33 measurements including the 3 dimensions - the X,Y, and Z axes.

time_BodyAcc_XYZ
time_GravityAcc_XYZ
time_BodyAccJerk_XYZ
time_BodyGyro_XYZ
time_BodyGyroJerk_XYZ
time_BodyAccMag
time_GravityAccMag
time_BodyAccJerkMag
time_BodyGyroMag
time_BodyGyroJerkMag
freq_BodyAcc_XYZ
freq_BodyAccJerk_XYZ
freq_BodyGyro_XYZ
freq_BodyAccMag
freq_BodyAccJerkMag
freq_BodyGyroMag
freq_BodyGyroJerkMag

## Set the working directory

We assume the data is already downloaded into the working directory.
     
```
working_dir <- getwd()
```

## Load the descriptions of the Variables and Clean them

I changed the steps of the project a little because I wanted to make sure I understand the lables of the data I was working with before I loaded the data it was describing. My view is that this makes the data easier to work with because you then know what is being described in the data.
     
### Load the Activity descriptions
     
We can find the activity lables in the 'activity_labels.txt' file. We have two columns in the activity descriptions an ID that links to a description. So I give these tidy names of activity_id and activity_name

```
activity_col_names <- c("activity_id", "activity_name")
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt",
                              col.names = activity_col_names)
```

### Load the Vaiable descriptions

The variable lables can be found in the 'features.txt'. The variable names are simply a list of 561 names that will be linked to training and test data.

```
variable_names_col_names <- c("variable_id", "variable_name")
variable_names <- read.table("./data/UCI HAR Dataset/features.txt"
                             , col.names = variable_names_col_names)
```

#### Clean the Variable Lables

The variables themselves are best described in the 'features_info.txt'. However, the names that are in 'features.txt' file (now in the 'variable_names' data.frame) are not easy to read or type in R. So I have made a few modfications to the names.

All of the variable names will take the form of timeorfreq_variableName_aggregateMeasure. I picked this particular strucutre of mixing capitals and underscores because I thought it made the name easily readable and understandable.

First we have to add underscores where there are '-', or ',' or ')_', or '),'.
```
variable_names$variable_name_tidy <- gsub("-|,|)_|),", "_", as.character(variable_names$variable_name)) 
```

Then remove any unnecessary characters.
```
variable_names$variable_name_tidy <- gsub("\\()|)$", "", variable_names$variable_name_tidy)
```

There is one spot where I felt like there needed to be a little extra description about the variable name in that the brackets were representing the 'action_of' so I have added an '_of_' to the names that needed it.
```
variable_names$variable_name_tidy <- gsub("\\(", "_of_", variable_names$variable_name_tidy)     
```

We then add the 'time' and 'freq' (representing frequency).
```
variable_names$variable_name_tidy <- gsub("^t", "time_", variable_names$variable_name_tidy)     
variable_names$variable_name_tidy <- gsub("_t", "_time_", variable_names$variable_name_tidy) 
variable_names$variable_name_tidy <- gsub("^f", "freq_", variable_names$variable_name_tidy) 
```

There are a set of instances where the word 'Body' is duplicated for seemingly no reason.
```
variable_names$variable_name_tidy <- gsub("BodyBody", "Body", variable_names$variable_name_tidy) 
```

## Load the Test Data

The test data is in the 'X_test.txt' file. Since we already created the list of variable names we can load the data with the columns attached.
```
test_data_no_ids <- read.table("./data/UCI HAR Dataset/test/X_test.txt"
                        , col.names = variable_names$variable_name_tidy)
```

There are some duplicate column names that need to be handeled. The duplicate names were given .# at the end of the columns where # represents an incremental number we are just going to replace the . with an underscore and keep the number.
```
colnames(test_data_no_ids) <- gsub("\\.", "_", colnames(test_data_no_ids))
```

### Load the subjects associated to the test data

The test subjects are in the 'subjects_test.txt' file. There is one colunm that we give the name of 'subject_id'.
```
test_subjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt",
                            col.names = "subject_id")
```

### Load the test activities that relate to the test data

The test activities are in the 'y_test.txt' file. There is one columne that we give the name of 'activity_id'. We give it this name since it represents the same data as the what we loaded in the in 'activity_labels.txt' file.
```
test_activities <- read.table("./data/UCI HAR Dataset/test/y_test.txt",
                              col.names = "activity_id")
```

We then add descriptors to the test_activities
```
test_activities <- 
     test_activities %>% 
     left_join(activity_labels,
               by = "activity_id")
```               
### Bring all of the testing data together

Add the descriptors of subject and activity to the data variables we want the subjects at the front of the data set to make them easy to see and match to our training data.
```
test_data <- cbind(data_type = rep("test", length(test_data$subject_id)),
                   test_subjects, 
                   activity_name = test_activities$activity_name, 
                   test_data_no_ids)
```
## Load the Training data

The test data is in the 'X_train.txt' file. Since we already created the list of variable names we can load the data with the columns attached.
```
train_data_no_ids <- read.table("./data/UCI HAR Dataset/train/X_train.txt"
                               , col.names = variable_names$variable_name_tidy)
```

There are some duplicate column names that need to be handeled. The duplicate names were given .# at the end of the columns where # represents an incremental number we are just going to replace the . with an underscore and keep the number.
```
colnames(train_data_no_ids) <- gsub("\\.", "_", colnames(train_data_no_ids))
```

### Load the train subjects

The test subjects are in the 'subjects_train.txt' file. There is one colunm that we give the name of 
'subject_id'.
```
train_subjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt",
                            col.names = "subject_id")
```

### Load the train activities that relate to the train data

The test activities are in the 'y_train.txt' file. There is one columne that we give the name of 'activity_id'. We give it this name since it represents the same data as the what we loaded in the in 'activity_labels.txt' file.
```
train_activities <- read.table("./data/UCI HAR Dataset/train/y_train.txt",
                              col.names = "activity_id")
```

Add descriptors to the train_activities
```
train_activities <- 
     train_activities %>% 
     left_join(activity_labels,
               by = "activity_id")
```               

### Bring all of the training data together

Add the descriptors of subject and activity to the data variables. We want the subjects at the front of the data set to make them easy to see.
```
train_data <- cbind(data_type = rep("train", length(train_data$subject_id)),
                    train_subjects, 
                    activity_name = train_activities$activity_name, 
                    train_data_no_ids)
```

## Test and Training Data Together

Now that we have the training and test datasets loaded with identical data structures we can combine them together and start our data manipulation.
```
samsung_data <- rbind(test_data, train_data)
```

'samsung_data' is a tidy data set because we have 1 observation of a subject in a particular environment (test or training) doing a particular acticity in a particular instance of time. All of our columns represent variables that can change with each observation.

We can use dplyr to get only the columns we want. Ones which contain mean or std.
```
samsung_data_means_and_stds <-
     agg_samsung_data %>% 
          select(data_type,
                 subject_id,
                 activity_name,
                 contains("mean"),
                 contains("std"))
```
'samsung_data_means_and_stds' is a tidy data set because it is simply a representation of 'samsung_data' with fewer variables and already know 'samsung_data' is a tidy data set.

For step # 5 we get the average of all of the variables and group by the subject(subject_id) and activity(activity_name)
```
agg_samsung_data_means_and_stds <-
     samsung_data_means_and_stds %>% 
     group_by(subject_id,
              activity_name) %>% 
     summarise_each(funs(mean))
```
'agg_samsung_data_means_and_stds' is a tidy data set because we have 1 observation of a suject doing an activity. The variables then represent aggregrates of those observations.
