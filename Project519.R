options(scipen=999)
library(readxl)
setwd("/Users/danielkwong/Documents/GitHub/GSE519Project")

#Import data
myData <- read.csv("train.csv")


# Rename columns that start with numbers
names(myData)[names(myData) == "1stFlrSF"] <- "X1stFlrSF"
names(myData)[names(myData) == "2ndFlrSF"] <- "X2ndFlrSF"
names(myData)[names(myData) == "3SsnPorch"] <- "X3SsnPorch"

#Convert categorical variables into dummy variables
install.packages("fastDummies")
library(fastDummies)

cat_vars <- c("MSZoning", "LotShape", "LandContour", "LotConfig", "LandSlope", "Neighborhood",
              "Condition1", "BldgType", "HouseStyle", "RoofStyle", "Exterior1st", "Exterior2nd",
              "MasVnrType", "ExterQual", "ExterCond", "Foundation", "BsmtQual", "BsmtCond",
              "BsmtExposure", "BsmtFinType1", "BsmtFinType2", "HeatingQC", "CentralAir",
              "Electrical", "KitchenQual", "Functional", "FireplaceQu", "GarageType", 
              "GarageFinish", "GarageQual", "GarageCond", "PavedDrive")

myData[cat_vars] <- lapply(myData[cat_vars], as.factor)

myData_with_dummies <- dummy_cols(myData, select_columns = cat_vars, remove_selected_columns = TRUE)
