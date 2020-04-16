packages<- c("data.table", "reshape")

#Download and Load the dataset.
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip("/home/kartikeya/datavalidationgetdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")

#Load all the label/feature files
label<- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
              , col.names = c("classLabels", "activityName"))
features<- fread(file.path(path, "UCI HAR Dataset/features.txt")
              , col.names = c("index", "featureNames"))

#Extracting only mean and standard devation
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

#Loading train data
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainAct <- fread(file.path(path, "UCI HAR Dataset/train/y_train.txt")
                         , col.names = c("Activity"))
trainSub <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSub, trainAct, train)

#Loading test data
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testAct <- fread(file.path(path, "UCI HAR Dataset/test/y_test.txt")
                         , col.names = c("Activity"))
testSub <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                  , col.names = c("SubjectNum"))
test <- cbind(testSub, testAct, test)

#Combined dataset
final<- rbind(test, train)

#Giving Descriptive column name
final[["Activity"]] <- factor(final[, Activity]
                                 , levels = label[["classLabels"]]
                                 , labels = label[["activityName"]])

final[["SubjectNum"]] <- as.factor(final[, SubjectNum])
final <- reshape2::melt(data = final, id = c("SubjectNum", "Activity"))
final <- reshape2::dcast(data = final, SubjectNum + Activity ~ variable, fun.aggregate = mean)


#Creating the final tidy dataset
data.table::fwrite(x = final, file = "tidyData.txt", quote = FALSE)
write.csv(x = final, file = "tidyData.csv", quote = FALSE)

