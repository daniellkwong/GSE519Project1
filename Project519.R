options(scipen=999)
library(readxl)
setwd("/Users/danielkwong/Documents/GSE519")

#Import data
myData <- read.csv("train.csv")


# Rename columns that start with numbers
names(train)[names(train) == "1stFlrSF"] <- "X1stFlrSF"
names(train)[names(train) == "2ndFlrSF"] <- "X2ndFlrSF"
names(train)[names(train) == "3SsnPorch"] <- "X3SsnPorch"

names(test)[names(test) == "1stFlrSF"] <- "X1stFlrSF"
names(test)[names(test) == "2ndFlrSF"] <- "X2ndFlrSF"
names(test)[names(test) == "3SsnPorch"] <- "X3SsnPorch"

#Convert categorical variables into dummy variables
install.packages("fastDummies")
library(fastDummies)

cat_vars <- c("MSZoning", "LotShape", "LandContour", "LotConfig", "LandSlope", "Neighborhood",
              "Condition1", "BldgType", "HouseStyle", "RoofStyle", "Exterior1st", "Exterior2nd",
              "MasVnrType", "ExterQual", "ExterCond", "Foundation", "BsmtQual", "BsmtCond",
              "BsmtExposure", "BsmtFinType1", "BsmtFinType2", "HeatingQC", "CentralAir",
              "Electrical", "KitchenQual", "Functional", "FireplaceQu", "GarageType", 
              "GarageFinish", "GarageQual", "GarageCond", "PavedDrive")

train[cat_vars] <- lapply(train[cat_vars], as.factor)
test[cat_vars]  <- lapply(test[cat_vars],  as.factor)

train_with_dummies <- dummy_cols(train, select_columns = cat_vars, remove_selected_columns = TRUE)
test_with_dummies  <- dummy_cols(test,  select_columns = cat_vars, remove_selected_columns = TRUE)
