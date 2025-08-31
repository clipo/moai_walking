# Diagnostic script for Figure 2 analysis
# This helps understand why the t-test results might differ from the paper

# Load required packages
library(readxl)
library(dplyr)

# Read the Van Tilburg data
cat("Loading data...\n")
data <- read_excel("../data/VanTilburgData.xlsx")

# Show initial data dimensions
cat(sprintf("\nInitial dataset: %d rows, %d columns\n", nrow(data), ncol(data)))

# Check for the required columns
cat("\nChecking required columns:\n")
if("Width:Base" %in% names(data)) cat("✓ Width:Base found\n") else cat("✗ Width:Base NOT found\n")
if("Width:Shoulders" %in% names(data)) cat("✓ Width:Shoulders found\n") else cat("✗ Width:Shoulders NOT found\n")
if("Location" %in% names(data)) cat("✓ Location found\n") else cat("✗ Location NOT found\n")

# Calculate ratios and filter
data_processed <- data %>%
  rename(
    BaseWidth = `Width:Base`,
    ShoulderWidth = `Width:Shoulders`,
    Location = Location
  ) %>%
  mutate(ratio = BaseWidth / ShoulderWidth)

# Check for missing values
cat(sprintf("\nMissing values before filtering:\n"))
cat(sprintf("  Base Width: %d missing\n", sum(is.na(data_processed$BaseWidth))))
cat(sprintf("  Shoulder Width: %d missing\n", sum(is.na(data_processed$ShoulderWidth))))
cat(sprintf("  Ratio: %d missing\n", sum(is.na(data_processed$ratio))))
cat(sprintf("  Location: %d missing\n", sum(is.na(data_processed$Location))))

# Filter out missing values
data_filtered <- data_processed %>%
  filter(!is.na(ratio) & !is.na(Location))

cat(sprintf("\nAfter removing missing values: %d rows\n", nrow(data_filtered)))

# Check Location distribution
cat("\nLocation distribution:\n")
location_counts <- table(data_filtered$Location)
print(location_counts)

# Categorize by location
data_categorized <- data_filtered %>%
  mutate(MoaiType = case_when(
    Location >= 1 & Location <= 6 ~ "Ahu",
    Location == 8 ~ "Road",
    TRUE ~ "Other"
  ))

cat("\nMoai type distribution:\n")
type_counts <- table(data_categorized$MoaiType)
print(type_counts)

# Filter to only Ahu and Road
final_data <- data_categorized %>%
  filter(MoaiType %in% c("Ahu", "Road"))

cat(sprintf("\nFinal dataset: %d rows\n", nrow(final_data)))

# Split by type
ahu_data <- final_data %>% filter(MoaiType == "Ahu")
road_data <- final_data %>% filter(MoaiType == "Road")

# Detailed statistics
cat("\n=== DETAILED STATISTICS ===\n")
cat(sprintf("\nAhu Moai (n = %d):\n", nrow(ahu_data)))
cat(sprintf("  Mean ratio: %.4f\n", mean(ahu_data$ratio)))
cat(sprintf("  SD ratio: %.4f\n", sd(ahu_data$ratio)))
cat(sprintf("  Min ratio: %.4f\n", min(ahu_data$ratio)))
cat(sprintf("  Max ratio: %.4f\n", max(ahu_data$ratio)))
cat(sprintf("  Median ratio: %.4f\n", median(ahu_data$ratio)))

cat(sprintf("\nRoad Moai (n = %d):\n", nrow(road_data)))
cat(sprintf("  Mean ratio: %.4f\n", mean(road_data$ratio)))
cat(sprintf("  SD ratio: %.4f\n", sd(road_data$ratio)))
cat(sprintf("  Min ratio: %.4f\n", min(road_data$ratio)))
cat(sprintf("  Max ratio: %.4f\n", max(road_data$ratio)))
cat(sprintf("  Median ratio: %.4f\n", median(road_data$ratio)))

# Perform t-test
cat("\n=== WELCH'S T-TEST ===\n")
t_result <- t.test(ratio ~ MoaiType, data = final_data, var.equal = FALSE)
print(t_result)

cat(sprintf("\nFormatted result: t = %.3f, df = %.1f, p = %.3e\n", 
            t_result$statistic, t_result$parameter, t_result$p.value))

# Alternative t-test formulation (to check consistency)
cat("\n=== ALTERNATIVE T-TEST (direct comparison) ===\n")
t_alt <- t.test(ahu_data$ratio, road_data$ratio, var.equal = FALSE)
print(t_alt)

# Check for outliers
cat("\n=== OUTLIER CHECK ===\n")
find_outliers <- function(x, name) {
  q1 <- quantile(x, 0.25)
  q3 <- quantile(x, 0.75)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  outliers <- x[x < lower | x > upper]
  cat(sprintf("%s: %d outliers (%.1f%%)\n", name, length(outliers), 100*length(outliers)/length(x)))
  if(length(outliers) > 0 & length(outliers) <= 10) {
    cat(sprintf("  Outlier values: %s\n", paste(round(outliers, 3), collapse=", ")))
  }
}

find_outliers(ahu_data$ratio, "Ahu Moai")
find_outliers(road_data$ratio, "Road Moai")

# Check assumptions
cat("\n=== ASSUMPTION CHECKS ===\n")

# Normality test
cat("\nShapiro-Wilk normality test:\n")
if(nrow(ahu_data) <= 5000) {
  shapiro_ahu <- shapiro.test(ahu_data$ratio)
  cat(sprintf("  Ahu: W = %.4f, p = %.4f %s\n", 
              shapiro_ahu$statistic, shapiro_ahu$p.value,
              ifelse(shapiro_ahu$p.value < 0.05, "(not normal)", "(normal)")))
}

if(nrow(road_data) <= 5000) {
  shapiro_road <- shapiro.test(road_data$ratio)
  cat(sprintf("  Road: W = %.4f, p = %.4f %s\n", 
              shapiro_road$statistic, shapiro_road$p.value,
              ifelse(shapiro_road$p.value < 0.05, "(not normal)", "(normal)")))
}

# Variance test
cat("\nF-test for equality of variances:\n")
var_test <- var.test(ratio ~ MoaiType, data = final_data)
cat(sprintf("  F = %.4f, p = %.4f %s\n", 
            var_test$statistic, var_test$p.value,
            ifelse(var_test$p.value < 0.05, "(unequal variances - Welch's t-test appropriate)", 
                   "(equal variances)")))

# Save diagnostic data for inspection
cat("\n=== SAVING DIAGNOSTIC DATA ===\n")
write.csv(final_data, "../figures/Figure_2_diagnostic_data.csv", row.names = FALSE)
cat("Diagnostic data saved to: ../figures/Figure_2_diagnostic_data.csv\n")

# Summary
cat("\n=== SUMMARY ===\n")
cat("The t-test results from this analysis are:\n")
cat(sprintf("t = %.3f, df = %.1f, p = %.3e (%.4f)\n", 
            t_result$statistic, t_result$parameter, t_result$p.value, t_result$p.value))
cat("\nIf these differ from the paper, possible reasons include:\n")
cat("1. Different data filtering criteria\n")
cat("2. Different handling of outliers\n")
cat("3. Different Location coding or categorization\n")
cat("4. Updates to the original dataset\n")
cat("5. Different statistical software or methods\n")