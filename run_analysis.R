library(dplyr)

# We assume the data is already downloaded into the working directory.
working_dir <- getwd()

## Tidy the data ----

# give activity_labels easy to read and understand names
activity_col_names <- c("activity_id", "activity_name")
# load activity lables
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt",
                              col.names = activity_col_names)
# give the variable name table column names
variable_names_col_names <- c("variable_id", "variable_name")
# load variable labels
variable_names <- read.table("./data/UCI HAR Dataset/features.txt"
                             , col.names = variable_names_col_names)
# clean the variable lables
variable_names$variable_name_tidy <- 
     # replace dashes with underscores
     gsub("-|,|)_|),", "_", as.character(variable_names$variable_name)) 
variable_names$variable_name_tidy <- 
     # we don't need the brackets that don't contain anything, so we remove those.
     gsub("\\()|)$", "", variable_names$variable_name_tidy)
variable_names$variable_name_tidy <- 
     # replace opening brackets with 'of'
     gsub("\\(", "_of_", variable_names$variable_name_tidy)     
variable_names$variable_name_tidy <- 
     # whenever a variable name starts with t we want to indicate it's a time variable
     gsub("^t", "time_", variable_names$variable_name_tidy)     
variable_names$variable_name_tidy <- 
     # whenever a variable name starts with t we want to indicate it's a time variable
     gsub("_t", "_time_", variable_names$variable_name_tidy) 
variable_names$variable_name_tidy <- 
     # whenever a variable name starts with f we want to indicate it's a frequency variable
     gsub("^f", "freq_", variable_names$variable_name_tidy) 
variable_names$variable_name_tidy <- 
     # bodybody is repetative and can be replaced by just body
     gsub("BodyBody", "Body", variable_names$variable_name_tidy) 


# load the test data
test_data_no_ids <- read.table("./data/UCI HAR Dataset/test/X_test.txt"
                        , col.names = variable_names$variable_name_tidy)
# there are some duplicate column names that need to be handeled
# the duplicate names were given .# at the end of the columns
# where # represents an incremental number
# we are just going to replace the . with an underscore and keep the number
colnames(test_data_no_ids) <- gsub("\\.", "_", colnames(test_data_no_ids))
# load the test subjects
test_subjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt",
                            col.names = "subject_id")
# load the test activities that relate to the test data
test_activities <- read.table("./data/UCI HAR Dataset/test/y_test.txt",
                              col.names = "activity_id")
# add descriptors to the test_activities
test_activities <- 
     test_activities %>% 
     left_join(activity_labels,
               by = "activity_id")
# add the descriptors of subject and activity to the data variables
# we want the subjects at the front of the data set to make them easy to see
test_data <- cbind(data_type = rep("test", length(test_data$subject_id)),
                   test_subjects, 
                   activity_name = test_activities$activity_name, 
                   test_data_no_ids)

# load the training data
train_data_no_ids <- read.table("./data/UCI HAR Dataset/train/X_train.txt"
                               , col.names = variable_names$variable_name_tidy)
# there are some duplicate column names that need to be handeled
# the duplicate names were given .# at the end of the columns
# where # represents an incremental number
# we are just going to replace the . with an underscore and keep the number
colnames(train_data_no_ids) <- gsub("\\.", "_", colnames(train_data_no_ids))
# load the train subjects
train_subjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt",
                            col.names = "subject_id")
# load the train activities that relate to the train data
train_activities <- read.table("./data/UCI HAR Dataset/train/y_train.txt",
                              col.names = "activity_id")
# add descriptors to the train_activities
train_activities <- 
     train_activities %>% 
     left_join(activity_labels,
               by = "activity_id")
# add the descriptors of subject and activity to the data variables
# we want the subjects at the front of the data set to make them easy to see
train_data <- cbind(data_type = rep("train", length(train_data$subject_id)),
                    train_subjects, 
                    activity_name = train_activities$activity_name, 
                    train_data_no_ids)

# Now that we have the training and test datasets loaded with identical data 
# structures we can combine them together and start our data manipulation.
samsung_data <- rbind(test_data, train_data)
# we can use dplyr to get only the columns we want. Ones which contain mean or std
samsung_data_means_and_stds <-
     agg_samsung_data %>% 
          select(data_type,
                 subject_id,
                 activity_name,
                 contains("mean"),
                 contains("std"))

# For step # 5 we get the average of all of the variables and group by
# the subject(subject_id) and activity(activity_name)
agg_samsung_data_means_and_stds <-
     samsung_data_means_and_stds %>% 
     group_by(subject_id,
              activity_name) %>% 
     summarise_each(funs(mean))

write.table(agg_samsung_data_means_and_stds, file = "agg_samsung_data_means_and_stds.txt", row.names = FALSE)
