# Load required libraries
library(tidyverse)
library(data.table)
library(caret)
library(randomForest)
library(forcats)

# Set file paths
train_path <- "E:/R Projects/Dataset/store_train.csv"
test_path  <- "E:/R Projects/Dataset/store_test.csv"

# Read data
train_data <- fread(train_path) %>% as.data.frame()
test_data  <- fread(test_path) %>% as.data.frame()

# Drop ID column
train_data <- train_data %>% select(-Id)
test_data  <- test_data %>% select(-Id)

# Convert target to factor
train_data$store <- as.factor(train_data$store)

# Identify categorical columns
cat_vars <- names(train_data)[sapply(train_data, is.character)]

# Drop high-cardinality categorical variables (> 50 levels)
high_card <- cat_vars[sapply(train_data[cat_vars], function(x) length(unique(x)) > 50)]
train_data <- train_data %>% select(-all_of(high_card))
test_data  <- test_data %>% select(-all_of(high_card))

# Update cat_vars after dropping
cat_vars <- setdiff(cat_vars, high_card)

# Convert to factors
train_data[cat_vars] <- lapply(train_data[cat_vars], as.factor)
test_data[cat_vars]  <- lapply(test_data[cat_vars], as.factor)

# Align test factor levels with training levels
for (var in cat_vars) {
  test_data[[var]] <- factor(test_data[[var]], levels = levels(train_data[[var]]))
}

# Mode function
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# Impute missing values
for (col in names(train_data)) {
  if (any(is.na(train_data[[col]]))) {
    if (is.numeric(train_data[[col]])) {
      train_data[[col]][is.na(train_data[[col]])] <- median(train_data[[col]], na.rm = TRUE)
    } else {
      train_data[[col]][is.na(train_data[[col]])] <- Mode(train_data[[col]])
    }
  }
}
for (col in names(test_data)) {
  if (any(is.na(test_data[[col]]))) {
    if (is.numeric(test_data[[col]])) {
      test_data[[col]][is.na(test_data[[col]])] <- median(test_data[[col]], na.rm = TRUE)
    } else {
      test_data[[col]][is.na(test_data[[col]])] <- Mode(test_data[[col]])
    }
  }
}

# Train Random Forest model
set.seed(42)
rf_model <- randomForest(store ~ ., data = train_data, ntree = 100, importance = TRUE)

# Predict probabilities for class 1
score <- predict(rf_model, newdata = test_data, type = "prob")[, 2]

# Prepare submission
submission <- test_data %>%
  mutate(PredictedProbability = score)

# Export results
write.csv(submission, "E:/R Projects/Dataset/predicted_store_scores.csv", row.names = FALSE)
cat("✅ Predictions saved at: E:/R Projects/Dataset/predicted_store_scores.csv\n")
