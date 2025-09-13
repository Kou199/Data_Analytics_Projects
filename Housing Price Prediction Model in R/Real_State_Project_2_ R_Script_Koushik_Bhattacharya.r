# Load required libraries
library(tidyverse)
library(caret)
library(data.table)

# Helper function to compute mode
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# Set file paths
train_filepath <- "E:/R Projects/Dataset/housing_train.csv"
test_filepath  <- "E:/R Projects/Dataset/housing_test.csv"

# Load data
train_data <- fread(train_filepath)
test_data  <- fread(test_filepath)

# Convert to data.frame
train_data <- as.data.frame(train_data)
test_data  <- as.data.frame(test_data)

# Drop non-generalizable column
train_data <- train_data %>% select(-Address)
test_data  <- test_data %>% select(-Address)

# Specify categorical variables
cat_vars <- c("Suburb", "Type", "Method", "SellerG", "Postcode", "CouncilArea")

# Convert to factors
train_data[cat_vars] <- lapply(train_data[cat_vars], as.factor)
test_data[cat_vars]  <- lapply(test_data[cat_vars], as.factor)

# Match factor levels
for (var in cat_vars) {
  test_data[[var]] <- factor(test_data[[var]], levels = levels(train_data[[var]]))
}

# Impute missing values in training data
for (col in names(train_data)) {
  if (any(is.na(train_data[[col]]))) {
    if (is.numeric(train_data[[col]])) {
      train_data[[col]][is.na(train_data[[col]])] <- median(train_data[[col]], na.rm = TRUE)
    } else {
      train_data[[col]][is.na(train_data[[col]])] <- Mode(train_data[[col]])
    }
  }
}

# Impute missing values in test data
for (col in names(test_data)) {
  if (any(is.na(test_data[[col]]))) {
    if (is.numeric(test_data[[col]])) {
      test_data[[col]][is.na(test_data[[col]])] <- median(test_data[[col]], na.rm = TRUE)
    } else {
      test_data[[col]][is.na(test_data[[col]])] <- Mode(test_data[[col]])
    }
  }
}

# Build linear regression model
set.seed(123)
model <- train(Price ~ ., data = train_data, method = "lm")

# Predict prices
predicted_prices <- predict(model, newdata = test_data)

# Create output with predictions
submission <- test_data %>% 
  mutate(PredictedPrice = predicted_prices)

# Export results
write.csv(submission, "E:/R Projects/Dataset/predicted_prices.csv", row.names = FALSE)

cat("\n✅ Prediction file saved to: E:/R Projects/Dataset/predicted_prices.csv\n")
