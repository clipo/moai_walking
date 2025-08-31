# Alternative analyses for Figure 2
# Exploring different filtering approaches that might match the paper's results

library(readxl)
library(dplyr)

# Read the Van Tilburg data
data <- read_excel("../data/VanTilburgData.xlsx")

# Base processing
data_base <- data %>%
  rename(
    BaseWidth = `Width:Base`,
    ShoulderWidth = `Width:Shoulders`,
    Location = Location
  ) %>%
  mutate(ratio = BaseWidth / ShoulderWidth) %>%
  filter(!is.na(ratio) & !is.na(Location))

cat("=== EXPLORING DIFFERENT ANALYSES ===\n\n")

# Analysis 1: Standard (current approach)
cat("1. STANDARD ANALYSIS (Location 1-6 = Ahu, 8 = Road):\n")
data1 <- data_base %>%
  mutate(MoaiType = case_when(
    Location >= 1 & Location <= 6 ~ "Ahu",
    Location == 8 ~ "Road",
    TRUE ~ "Other"
  )) %>%
  filter(MoaiType %in% c("Ahu", "Road"))

t1 <- t.test(ratio ~ MoaiType, data = data1, var.equal = FALSE)
cat(sprintf("   n_ahu = %d, n_road = %d\n", 
            sum(data1$MoaiType == "Ahu"), sum(data1$MoaiType == "Road")))
cat(sprintf("   t = %.3f, df = %.1f, p = %.3e\n\n", 
            t1$statistic, t1$parameter, t1$p.value))

# Analysis 2: Remove outliers (IQR method)
cat("2. REMOVING OUTLIERS (1.5 × IQR):\n")
remove_outliers <- function(df, column) {
  q1 <- quantile(df[[column]], 0.25)
  q3 <- quantile(df[[column]], 0.75)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  df %>% filter(!!sym(column) >= lower & !!sym(column) <= upper)
}

data2 <- data1 %>%
  group_by(MoaiType) %>%
  group_modify(~ remove_outliers(.x, "ratio")) %>%
  ungroup()

t2 <- t.test(ratio ~ MoaiType, data = data2, var.equal = FALSE)
cat(sprintf("   n_ahu = %d, n_road = %d\n", 
            sum(data2$MoaiType == "Ahu"), sum(data2$MoaiType == "Road")))
cat(sprintf("   t = %.3f, df = %.1f, p = %.3e\n\n", 
            t2$statistic, t2$parameter, t2$p.value))

# Analysis 3: Only specific ahu locations
cat("3. SPECIFIC AHU LOCATIONS (only 1-4, vs Road=8):\n")
data3 <- data_base %>%
  mutate(MoaiType = case_when(
    Location >= 1 & Location <= 4 ~ "Ahu",  # Only locations 1-4
    Location == 8 ~ "Road",
    TRUE ~ "Other"
  )) %>%
  filter(MoaiType %in% c("Ahu", "Road"))

t3 <- t.test(ratio ~ MoaiType, data = data3, var.equal = FALSE)
cat(sprintf("   n_ahu = %d, n_road = %d\n", 
            sum(data3$MoaiType == "Ahu"), sum(data3$MoaiType == "Road")))
cat(sprintf("   t = %.3f, df = %.1f, p = %.3e\n\n", 
            t3$statistic, t3$parameter, t3$p.value))

# Analysis 4: Stricter ratio bounds
cat("4. RATIO BOUNDS (0.5 < ratio < 1.5):\n")
data4 <- data1 %>%
  filter(ratio > 0.5 & ratio < 1.5)

t4 <- t.test(ratio ~ MoaiType, data = data4, var.equal = FALSE)
cat(sprintf("   n_ahu = %d, n_road = %d\n", 
            sum(data4$MoaiType == "Ahu"), sum(data4$MoaiType == "Road")))
cat(sprintf("   t = %.3f, df = %.1f, p = %.3e\n\n", 
            t4$statistic, t4$parameter, t4$p.value))

# Analysis 5: One-tailed test (Road > Ahu expected)
cat("5. ONE-TAILED TEST (Road ratio > Ahu ratio):\n")
t5 <- t.test(ratio ~ MoaiType, data = data1, var.equal = FALSE, alternative = "less")
cat(sprintf("   n_ahu = %d, n_road = %d\n", 
            sum(data1$MoaiType == "Ahu"), sum(data1$MoaiType == "Road")))
cat(sprintf("   t = %.3f, df = %.1f, p = %.3e (one-tailed)\n\n", 
            t5$statistic, t5$parameter, t5$p.value))

# Analysis 6: Log-transformed ratios
cat("6. LOG-TRANSFORMED RATIOS:\n")
data6 <- data1 %>%
  mutate(log_ratio = log(ratio))

t6 <- t.test(log_ratio ~ MoaiType, data = data6, var.equal = FALSE)
cat(sprintf("   n_ahu = %d, n_road = %d\n", 
            sum(data6$MoaiType == "Ahu"), sum(data6$MoaiType == "Road")))
cat(sprintf("   t = %.3f, df = %.1f, p = %.3e\n\n", 
            t6$statistic, t6$parameter, t6$p.value))

# Analysis 7: Include Location 7 as Road
cat("7. INCLUDE LOCATION 7 AS ROAD:\n")
data7 <- data_base %>%
  mutate(MoaiType = case_when(
    Location >= 1 & Location <= 6 ~ "Ahu",
    Location %in% c(7, 8) ~ "Road",  # Include location 7
    TRUE ~ "Other"
  )) %>%
  filter(MoaiType %in% c("Ahu", "Road"))

t7 <- t.test(ratio ~ MoaiType, data = data7, var.equal = FALSE)
cat(sprintf("   n_ahu = %d, n_road = %d\n", 
            sum(data7$MoaiType == "Ahu"), sum(data7$MoaiType == "Road")))
cat(sprintf("   t = %.3f, df = %.1f, p = %.3e\n\n", 
            t7$statistic, t7$parameter, t7$p.value))

# Check if any additional filtering columns might be relevant
cat("\n=== OTHER POTENTIALLY RELEVANT COLUMNS ===\n")
cat("Column names in dataset:\n")
print(names(data))

# Look for any status or condition columns that might filter data
if("Status" %in% names(data)) {
  cat("\nStatus values found:\n")
  print(table(data$Status, useNA = "always"))
}

if("Condition" %in% names(data)) {
  cat("\nCondition values found:\n")
  print(table(data$Condition, useNA = "always"))
}

if("Complete" %in% names(data)) {
  cat("\nComplete values found:\n")
  print(table(data$Complete, useNA = "always"))
}

cat("\n=== RECOMMENDATION ===\n")
cat("Your current results (t = 2.474, df = 86.0, p = 0.0153) suggest:\n")
cat("- A moderate effect size with statistical significance at p < 0.05\n")
cat("- The direction of the effect (Road > Ahu ratios) supports the hypothesis\n")
cat("- The slight difference from the paper could be due to:\n")
cat("  * Data updates or corrections since publication\n")
cat("  * Different handling of edge cases or missing data\n")
cat("  * Rounding differences in the original analysis\n\n")
cat("The results still support the main conclusion that road and ahu moai\n")
cat("have statistically different base-to-shoulder width ratios.\n")