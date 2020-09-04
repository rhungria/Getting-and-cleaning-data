# Preparatoty work - loading commandos:
library(reshape2)

# Getting data from the internet and saving it locally on different folders:
data_folder <- "./rawData"
data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
raw_data_path <- paste(data_folder, "/", "rawData.zip", sep = "")
cooked_data_folder <- "./data"

if (!file.exists(data_folder)) {
    dir.create(data_folder)
    download.file(url = data_url, destfile = raw_data_path)
}
if (!file.exists(cooked_data_folder)) {
    dir.create(cooked_data_folder)
    unzip(zipfile = raw_data_path, exdir = cooked_data_folder)
}


#1. Merging train & test datasets to create one dataset:
# Full description here: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# train data
x_train <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/train/x_train.txt"))
y_train <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/train/y_train.txt"))
s_train <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/train/subject_train.txt"))

# test data
x_test <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/test/x_test.txt"))
y_test <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/test/y_test.txt"))
s_test <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/test/subject_test.txt"))

# merging {train, test} data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)


#3. Loading feature & activity information:
# feature info
feature <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/features.txt"))

# activity labels
a_label <- read.table(paste(sep = "", cooked_data_folder, "/UCI HAR Dataset/activity_labels.txt"))
a_label[,2] <- as.character(a_label[,2])

# extracting feature columns & replacing all matches of 'mean, std' respectively:
cols <- grep("-(mean|std).*", as.character(feature[,2]))
cols_names <- feature[cols, 2]
cols_names <- gsub("-mean", "Mean", cols_names)
cols_names <- gsub("-std", "Std", cols_names)
cols_names <- gsub("[-()]", "", cols_names)


#4. Extracting data by columns & giving variable names:
x_data <- x_data[cols]
all_data <- cbind(s_data, y_data, x_data)
colnames(all_data) <- c("Subject", "Activity", cols_names)

all_data$Activity <- factor(all_data$Activity, levels = a_label[,1], labels = a_label[,2])
all_data$Subject <- as.factor(all_data$Subject)


#5. Generating tidy dataset
merged_data <- melt(all_data, id = c("Subject", "Activity"))
tidy_data <- dcast(merged_data, Subject + Activity ~ variable, mean)

write.table(tidy_data, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)
