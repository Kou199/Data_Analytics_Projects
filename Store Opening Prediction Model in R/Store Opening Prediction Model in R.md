Store Opening Prediction Model in R
Project Overview
This project tackles a classic business problem in the retail domain: predicting the success of a new store location. The goal was to build a machine learning model to determine whether a potential new store should be opened based on key factors such as sales data, population density, and area demographics. The model was developed using R programming.

Problem Statement
A major challenge for retail companies is deciding where to open new stores. This project aims to create a predictive model to forecast the viability of a store location. The model uses historical data to predict the binary outcome of whether a store should be opened (1) or not (0). This provides a data-driven tool for strategic decision-making in retail expansion.

Datasets
The analysis was performed using two datasets:

store_train.csv: This dataset contains historical data, including the target variable store (a binary outcome). It was used to train the predictive model.

store_test.csv: This dataset contains the same features as the training data but is missing the store variable. My model was used to predict the probability of a store opening for each entry in this dataset.

Evaluation Criterion
The performance of the model was evaluated using the AUC (Area Under the Curve) score, a standard metric for binary classification models.

Passing Criterion: An AUC score greater than 0.81.

Submission Format: Predictions were submitted as probability scores (the probability of the outcome being 1), not as hard classes.