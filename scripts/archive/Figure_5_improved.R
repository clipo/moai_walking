#!/usr/bin/env Rscript
# Figure 5: Relationship between moai base angle and size metric
# IMPROVED VERSION - Uses actual data and provides clear documentation

# Load required packages
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(svglite)

cat("=== FIGURE 5: BASE ANGLE VS SIZE ANALYSIS ===\n\n")

# Function to create the base angle vs size figure with proper documentation
create_base_angle_size_figure <- function(data_file = NULL, use_road_moai_only = TRUE) {
  
  cat("EXPECTED DATA FORMAT:\n")
  cat("Required columns:\n")
  cat("  - mean_base_angle: Average of base angle measurements (degrees)\n")
  cat("  - total_length_cm: Total moai height in centimeters\n")
  cat("  - base_width_cm: Base width in centimeters\n")
  cat("  - Position (optional): 'prone', 'supine', or NA\n")
  cat("  - location_type (optional): 'ROAD', 'ISOLATED', 'AHU', etc.\n\n")
  
  # Load data based on input
  if (!is.null(data_file)) {
    # Use provided data file
    cat(sprintf("Loading data from: %s\n", data_file))
    
    if(grepl("\\.csv$", data_file)) {
      complete_data <- read.csv(data_file)
    } else if(grepl("\\.xlsx$", data_file)) {
      complete_data <- read_excel(data_file)
    } else {
      stop("Unsupported file format. Use CSV or XLSX.")
    }
    
  } else {
    # Try to use the actual combined data
    cat("No data file specified. Attempting to use all_moai_combined.csv\n")
    
    if(file.exists("../data/all_moai_combined.csv")) {
      complete_data <- read.csv("../data/all_moai_combined.csv")
      cat("Loaded all_moai_combined.csv\n")
    } else if(file.exists("data/all_moai_combined.csv")) {
      complete_data <- read.csv("data/all_moai_combined.csv")
      cat("Loaded all_moai_combined.csv\n")
    } else {
      cat("\n=== ERROR: NO DATA FILE FOUND ===\n")
      cat("\nThis analysis requires real moai measurement data.\n")
      cat("\nData file not found. Please ensure one of the following:\n")
      cat("1. Place 'all_moai_combined.csv' in the data/ directory\n")
      cat("2. Provide a data file path as argument\n")
      cat("\nExample usage:\n")
      cat("  result <- create_base_angle_size_figure('path/to/data.csv')\n")
      cat("  result <- create_base_angle_size_figure('../data/all_moai_combined.csv')\n")
      stop("Cannot proceed without real data. Demo data generation has been disabled for scientific integrity.")
    }
  }
  
  # Check required columns
  required_cols <- c("mean_base_angle", "total_length_cm", "base_width_cm")
  missing_cols <- required_cols[!required_cols %in% names(complete_data)]
  
  if(length(missing_cols) > 0) {
    stop(sprintf("Missing required columns: %s", paste(missing_cols, collapse = ", ")))
  }
  
  # Data processing
  cat("\nProcessing data...\n")
  
  # Filter for road moai if specified and column exists
  if(use_road_moai_only && "location_type" %in% names(complete_data)) {
    complete_data <- complete_data %>%
      filter(location_type %in% c("ROAD", "ISOLATED"))
    cat(sprintf("Filtered to ROAD/ISOLATED moai: %d records\n", nrow(complete_data)))
  }
  
  # Calculate size metric and filter
  complete_data <- complete_data %>%
    filter(!is.na(mean_base_angle) & !is.na(total_length_cm) & !is.na(base_width_cm)) %>%
    filter(mean_base_angle > 0 & mean_base_angle < 90) %>%  # Reasonable angle range
    filter(total_length_cm > 0 & base_width_cm > 0) %>%
    mutate(size_metric = total_length_cm * base_width_cm) %>%
    filter(size_metric > 100)  # Remove unreasonably small values
  
  cat(sprintf("Valid records for analysis: %d\n", nrow(complete_data)))
  
  if(nrow(complete_data) < 3) {
    stop("Insufficient data for analysis. Need at least 3 valid records.")
  }
  
  # Calculate statistics
  angle_range <- range(complete_data$mean_base_angle)
  size_range <- range(complete_data$size_metric)
  size_fold <- max(complete_data$size_metric) / min(complete_data$size_metric)
  
  # Calculate correlation
  correlation <- cor(complete_data$mean_base_angle, complete_data$size_metric, use = "complete.obs")
  
  # Perform linear regression for additional statistics
  lm_model <- lm(mean_base_angle ~ size_metric, data = complete_data)
  r_squared <- summary(lm_model)$r.squared
  p_value <- summary(lm_model)$coefficients[2, 4]
  
  # Print summary statistics
  cat("\n=== SUMMARY STATISTICS ===\n")
  cat(sprintf("Sample size: %d moai\n", nrow(complete_data)))
  cat(sprintf("Base angle range: %.1f° to %.1f° (range: %.1f°)\n", 
              angle_range[1], angle_range[2], diff(angle_range)))
  cat(sprintf("Size metric range: %s to %s cm² (%.1f-fold variation)\n", 
              format(round(size_range[1]), big.mark = ","),
              format(round(size_range[2]), big.mark = ","),
              size_fold))
  cat(sprintf("Pearson correlation: r = %.4f\n", correlation))
  cat(sprintf("R-squared: %.4f\n", r_squared))
  cat(sprintf("P-value: %.4f\n", p_value))
  
  # Interpretation
  cat("\n=== INTERPRETATION ===\n")
  if(abs(correlation) < 0.1) {
    cat("NEGLIGIBLE correlation between base angle and size.\n")
    cat("This supports standardized construction regardless of moai size.\n")
  } else if(abs(correlation) < 0.3) {
    cat("WEAK correlation between base angle and size.\n")
    cat("Base angles remain relatively consistent across different sizes.\n")
  } else {
    cat("MODERATE TO STRONG correlation detected.\n")
    cat("This may indicate size-dependent construction techniques.\n")
  }
  
  # Create the plot
  p <- ggplot(complete_data, aes(x = mean_base_angle, y = size_metric)) +
    # Add points with conditional color
    {if("Position" %in% names(complete_data)) {
      geom_point(aes(color = Position, size = total_length_cm), alpha = 0.7)
    } else {
      geom_point(aes(size = total_length_cm), alpha = 0.7, color = "#3498db")
    }} +
    
    # Add regression line with confidence interval
    geom_smooth(method = "lm", se = TRUE, color = "darkgray", 
                linetype = "dashed", alpha = 0.3) +
    
    # Add horizontal line at mean angle to show consistency
    geom_hline(yintercept = mean(complete_data$mean_base_angle), 
               linetype = "dotted", color = "red", alpha = 0.5) +
    
    # Conditional color scale
    {if("Position" %in% names(complete_data)) {
      scale_color_manual(values = c("prone" = "#e74c3c", "supine" = "#3498db"),
                        labels = c("Prone", "Supine"),
                        na.value = "#95a5a6")
    }} +
    
    # Size scale
    scale_size_continuous(name = "Height (cm)", range = c(2, 8)) +
    
    # Format y-axis
    scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
    
    # Labels
    labs(
      title = "Base Angle vs Size Metric: Testing Construction Standardization",
      subtitle = sprintf("n = %d moai | r = %.3f (p = %.3f) | %.1f-fold size variation", 
                        nrow(complete_data), correlation, p_value, size_fold),
      x = "Mean Base Angle (degrees)",
      y = expression(paste("Size Metric (Length × Width, cm"^"2", ")"))
    ) +
    
    # Theme
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11, color = "gray50"),
      axis.title = element_text(size = 11),
      axis.text = element_text(size = 10),
      legend.position = "right",
      legend.title = element_text(size = 10),
      legend.text = element_text(size = 9),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(color = "gray80", fill = NA)
    ) +
    
    # Add annotation about the narrow angle range
    annotate("text", x = mean(angle_range), y = min(complete_data$size_metric),
             label = sprintf("Angle range:\n%.1f°", diff(angle_range)),
             size = 3, color = "red", fontface = "italic")
  
  return(list(
    plot = p,
    data = complete_data,
    stats = list(
      n = nrow(complete_data),
      correlation = correlation,
      r_squared = r_squared,
      p_value = p_value,
      angle_range = angle_range,
      size_fold = size_fold
    )
  ))
}

# Main execution
cat("\n=== GENERATING FIGURE 5 ===\n")

# Use actual data (required)
result <- create_base_angle_size_figure(use_road_moai_only = TRUE)

# Display plot
print(result$plot)

# Save outputs
if (!dir.exists("../figures")) {
  dir.create("../figures")
}

# Save figure in multiple formats
ggsave("../figures/Figure_5_base_angle_vs_size.svg", result$plot, 
       width = 10, height = 7)
ggsave("../figures/Figure_5_base_angle_vs_size.png", result$plot, 
       width = 10, height = 7, dpi = 600)
ggsave("../figures/Figure_5_base_angle_vs_size_preview.png", result$plot, 
       width = 10, height = 7, dpi = 150)
ggsave("../figures/Figure_5_base_angle_vs_size.pdf", result$plot, 
       width = 10, height = 7)

# Save data
write.csv(result$data, "../figures/Figure_5_analysis_data.csv", row.names = FALSE)

# Save statistics summary
stats_df <- data.frame(
  metric = c("sample_size", "correlation", "r_squared", "p_value", 
             "min_angle", "max_angle", "angle_range", "size_fold_variation"),
  value = c(result$stats$n, result$stats$correlation, result$stats$r_squared, 
            result$stats$p_value, result$stats$angle_range[1], 
            result$stats$angle_range[2], diff(result$stats$angle_range), 
            result$stats$size_fold)
)
write.csv(stats_df, "../figures/Figure_5_statistics.csv", row.names = FALSE)

cat("\n=== FILES SAVED ===\n")
cat("- Figure_5_base_angle_vs_size.svg (vector format)\n")
cat("- Figure_5_base_angle_vs_size.png (600 dpi)\n")
cat("- Figure_5_base_angle_vs_size_preview.png (150 dpi)\n")
cat("- Figure_5_base_angle_vs_size.pdf\n")
cat("- Figure_5_analysis_data.csv (processed data)\n")
cat("- Figure_5_statistics.csv (summary statistics)\n")

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("\nKEY FINDING: ")
if(abs(result$stats$correlation) < 0.1) {
  cat("The negligible correlation supports the Walking Moai Hypothesis.\n")
  cat("Base angles remain remarkably consistent (narrow range) despite huge size variation.\n")
  cat("This suggests sophisticated, standardized engineering for 'walking' transport.\n")
} else {
  cat(sprintf("Correlation of %.3f detected. Further investigation may be needed.\n", 
              result$stats$correlation))
}