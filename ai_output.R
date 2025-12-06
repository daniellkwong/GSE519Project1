# =============================================================================
# Ames Housing Price Prediction Analysis
# Part 2: AI-Generated Exploratory & Predictive Analysis
# =============================================================================

setwd("/Users/danielkwong/Documents/GitHub/GSE519Project")
set.seed(42)

# Load required libraries
install.packages(c(
  "tidyverse",
  "janitor",
  "skimr",
  "broom",
  "ggplot2",
  "dplyr",
  "readr",
  "tibble",
  "purrr",
  "stringr",
  "forcats"
))


library(tidyverse)
library(janitor)
library(skimr)
library(broom)

# Create output directory
if (!dir.exists("outputs")) dir.create("outputs")

# -----------------------------------------------------------------------------
# 1. Data Loading
# -----------------------------------------------------------------------------
raw_data <- read_csv("train.csv", show_col_types = FALSE) %>%
  clean_names()

cat("Dataset:", nrow(raw_data), "rows x", ncol(raw_data), "columns\n")

# EDA summary
skim_output <- skim(raw_data)
print(skim_output)

# -----------------------------------------------------------------------------
# 2. Target Distribution & Log Transform
# -----------------------------------------------------------------------------
p_target <- ggplot(raw_data, aes(x = sale_price)) +
  geom_histogram(bins = 40, fill = "steelblue", color = "white") +
  geom_vline(aes(xintercept = median(sale_price)), color = "red", linetype = "dashed") +
  scale_x_continuous(labels = scales::comma) +
  labs(title = "Distribution of Sale Price", x = "Sale Price ($)", y = "Count") +
  theme_minimal()
ggsave("outputs/fig1_target_distribution.png", p_target, width = 8, height = 5)

# -----------------------------------------------------------------------------
# 3. Correlation Analysis
# -----------------------------------------------------------------------------
numeric_data <- raw_data %>% select(where(is.numeric)) %>% drop_na()
cor_matrix <- cor(numeric_data)
target_cors <- cor_matrix[, "sale_price"] %>% sort(decreasing = TRUE)
print(head(target_cors, 15))

# -----------------------------------------------------------------------------
# 4. Train-Test Split (75/25)
# -----------------------------------------------------------------------------
model_data <- raw_data %>%
  select(sale_price, overall_qual, gr_liv_area, garage_cars, garage_area,
         total_bsmt_sf, x1st_flr_sf, full_bath, year_built, year_remod_add,
         fireplaces, bsmt_fin_sf1, lot_area, neighborhood) %>%
  mutate(log_sale_price = log(sale_price),
         across(where(is.numeric), ~if_else(is.na(.), median(., na.rm = TRUE), .)),
         neighborhood = factor(neighborhood))

train_idx <- sample(1:nrow(model_data), size = floor(0.75 * nrow(model_data)))
train_data <- model_data[train_idx, ]
test_data <- model_data[-train_idx, ]

# -----------------------------------------------------------------------------
# 5. Linear Regression Model
# -----------------------------------------------------------------------------
lm_model <- lm(log_sale_price ~ overall_qual + gr_liv_area + garage_cars +
                 total_bsmt_sf + year_built + full_bath + fireplaces +
                 lot_area + neighborhood, data = train_data)

summary(lm_model)
coef_table <- tidy(lm_model, conf.int = TRUE)
write_csv(coef_table, "outputs/model_coefficients.csv")

# -----------------------------------------------------------------------------
# 6. 5-Fold Cross-Validation
# -----------------------------------------------------------------------------
n_folds <- 5
fold_ids <- sample(rep(1:n_folds, length.out = nrow(train_data)))
cv_rmse <- numeric(n_folds)

for (k in 1:n_folds) {
  cv_train <- train_data[fold_ids != k, ]
  cv_val <- train_data[fold_ids == k, ]
  cv_model <- lm(log_sale_price ~ overall_qual + gr_liv_area + garage_cars +
                   total_bsmt_sf + year_built + full_bath + fireplaces +
                   lot_area + neighborhood, data = cv_train)
  cv_preds <- predict(cv_model, newdata = cv_val)
  cv_rmse[k] <- sqrt(mean((cv_val$log_sale_price - cv_preds)^2))
}
cat("Mean CV RMSE:", mean(cv_rmse), "\n")

# Ensure factor levels match
test_data$neighborhood <- factor(
  test_data$neighborhood,
  levels = levels(train_data$neighborhood)
)

# Test Set Evaluation
test_preds <- exp(predict(lm_model, newdata = test_data))
test_actual <- test_data$sale_price


# -----------------------------------------------------------------------------
# 7. Test Set Evaluation
# -----------------------------------------------------------------------------
test_preds <- exp(predict(lm_model, newdata = test_data))
test_actual <- test_data$sale_price
test_rmse <- sqrt(mean((test_actual - test_preds)^2))
test_mae <- mean(abs(test_actual - test_preds))
test_r2 <- cor(test_actual, test_preds)^2

cat("Test RMSE: $", round(test_rmse), "\n")
cat("Test MAE: $", round(test_mae), "\n")
cat("Test R-squared:", round(test_r2, 4), "\n")

# -----------------------------------------------------------------------------
# 8. Diagnostic Plots
# -----------------------------------------------------------------------------
diag_data <- augment(lm_model)

# Residuals vs Fitted
p_resid <- ggplot(diag_data, aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residuals vs Fitted", x = "Fitted Values", y = "Residuals") +
  theme_minimal()
ggsave("outputs/fig6_residuals.png", p_resid, width = 8, height = 5)

# Q-Q Plot
p_qq <- ggplot(diag_data, aes(sample = .resid)) +
  stat_qq(color = "steelblue") + stat_qq_line(color = "red") +
  labs(title = "Normal Q-Q Plot") + theme_minimal()
ggsave("outputs/fig7_qqplot.png", p_qq, width = 6, height = 6)

# Predicted vs Actual
p_pred <- ggplot(tibble(actual = test_actual, predicted = test_preds),
                 aes(x = actual, y = predicted)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Predicted vs Actual", x = "Actual ($)", y = "Predicted ($)") +
  theme_minimal()
ggsave("outputs/fig8_pred_vs_actual.png", p_pred, width = 7, height = 6)

cat("\n=== Analysis Complete ===")
cat("\nOutputs saved to outputs/ directory\n")
