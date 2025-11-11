options(scipen=999)
library(readxl)
setwd("/Users/danielkwong/Documents/GitHub/GSE519Project")

#Import data
myData <- read.csv("train.csv")

desired <- c(
  "MSSubClass","MSZoning","LotFrontage","LotArea","LotShape","LandContour","LotConfig",
  "LandSlope","Neighborhood","Condition1","BldgType","HouseStyle","OverallQual",
  "OverallCond","YearBuilt","YearRemodAdd","RoofStyle","Exterior1st","Exterior2nd",
  "MasVnrType","MasVnrArea","ExterQual","ExterCond","Foundation","BsmtQual","BsmtCond",
  "BsmtExposure","BsmtFinType1","BsmtFinSF1","BsmtFinType2","BsmtFinSF2","BsmtUnfSF",
  "TotalBsmtSF","HeatingQC","CentralAir","Electrical","X1stFlrSF","X2ndFlrSF",
  "LowQualFinSF","GrLivArea","BsmtFullBath","BsmtHalfBath","FullBath","HalfBath",
  "BedroomAbvGr","KitchenQual","TotRmsAbvGrd","Functional","Fireplaces","FireplaceQu",
  "GarageType","GarageYrBlt","GarageFinish","GarageCars","GarageArea","GarageQual",
  "GarageCond","PavedDrive","WoodDeckSF","OpenPorchSF","EnclosedPorch","X3SsnPorch",
  "ScreenPorch","PoolArea","MoSold","YrSold"
)

# 3) Keep only the ones that exist; list any that don't
keep <- intersect(desired, names(myData))
missing <- setdiff(desired, names(myData))


new_data <- myData[, keep, drop = FALSE]

write.csv(new_data, "selected_columns.csv", row.names = FALSE)


# Rename columns that start with numbers
names(new_data)[names(new_data) == "1stFlrSF"] <- "X1stFlrSF"
names(new_data)[names(new_data) == "2ndFlrSF"] <- "X2ndFlrSF"
names(new_data)[names(new_data) == "3SsnPorch"] <- "X3SsnPorch"

#Check which variables are categorical
str(new_data)

#Convert categorical variables into dummy variables
install.packages("fastDummies")
library(fastDummies)

cat_vars <- c("MSZoning", "LotShape", "LandContour", "LotConfig", "LandSlope", "Neighborhood",
              "Condition1", "BldgType", "HouseStyle", "RoofStyle", "Exterior1st", "Exterior2nd",
              "MasVnrType", "ExterQual", "ExterCond", "Foundation", "BsmtQual", "BsmtCond",
              "BsmtExposure", "BsmtFinType1", "BsmtFinType2", "HeatingQC", "CentralAir",
              "Electrical", "KitchenQual", "Functional", "FireplaceQu", "GarageType", 
              "GarageFinish", "GarageQual", "GarageCond", "PavedDrive")

new_data[cat_vars] <- lapply(new_data[cat_vars], as.factor)

myData_with_dummies <- dummy_cols(new_data, select_columns = cat_vars, remove_selected_columns = TRUE)

#Drop ID column
myData_with_dummies <- myData_with_dummies[ , !(names(myData_with_dummies) == "Id")]


#Split data set into test and training sets
set.seed(42)
split <- sample(1:nrow(myData_with_dummies), 0.8*nrow(myData_with_dummies))

train <- myData_with_dummies[split, ]
test  <- myData_with_dummies[-split, ]

