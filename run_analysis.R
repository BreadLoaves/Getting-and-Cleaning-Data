library(data.table)

#Data Download and unzip

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "something.zip", mode = "wb")

unzip("something.zip", exdir = getwd())

#Reading and converting data

features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
head(features)

data.train.x <- read.table('./UCI HAR Dataset/train/X_train.txt')
data.train.activity <- read.table('./UCI HAR Dataset/train/Y_train.txt', header = FALSE, sep = ' ')
data.train.subject <- read.table('./UCI HAR Dataset/train/subject_train.txt', header = FALSE, sep = ' ')

data.train <- data.frame(data.train.subject, data.train.activity, data.train.x)
names(data.train) <- c(c('Subject', 'Activity'), 'Features')

data.test.x <- read.table('./UCI HAR Dataset/test/X_test.txt')
data.test.activity <- read.table('./UCI HAR Dataset/test/Y_test.txt', header = FALSE, sep = ' ')
data.test.subject <- read.table('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

data.test <- data.frame(data.test.subject, data.test.activity, data.test.x)
names(data.test) <- c(c('Subject', 'Activity'), 'Features')

#Merging testing and training sets into one

data.all <- rbind(data.train, data.test)

#Extracting the measurements on the mean and SD of each measurement

mean.SD.select <- grep('mean|std', features)
data.sub <- data.all[, c(1, 2, mean.SD.select + 2)]

#Descriptive activity names to name the activities

labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
labels <- as.character(labels[,2])

data.sub$Activity <- labels[data.sub$Activity]

#Labelling the dataset

name.new <- names(data.sub)
name.new <- gsub("[(][)]", "", name.new)
name.new <- gsub("^t", "TimeDomain_", name.new)
name.new <- gsub("^f", "FrequencyDomain_", name.new)
name.new <- gsub("Acc", "Accelerometer", name.new)
name.new <- gsub("Gyro", "Gyroscope", name.new)
name.new <- gsub("Mag", "Magnitude", name.new)
name.new <- gsub("-mean-", "_Mean_", name.new)
name.new <- gsub("-std-", "_StandardDeviation_", name.new)
name.new <- gsub("-", "_", name.new)
names(data.sub) <- name.new

#Independent, secondary clean data set

data.tidy <- aggregate(data.sub [, 3] , by = list(Activity = data.sub$Activity, Subject = data.sub$Subject),FUN = mean)
write.table(x = data.tidy, file = "data_tidy.txt", row.names = FALSE)
