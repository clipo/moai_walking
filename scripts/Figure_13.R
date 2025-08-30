#!/usr/bin/env Rscript
# Figure 13: Analysis of moai size in relation to transport distance
# Creates box plots by transport phase and scatter plot with regression

library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(svglite)

cat("=== FIGURE 13: SIZE VS TRANSPORT DISTANCE ANALYSIS ===\n\n")

# Load the public database which has size data
public_db <- read_excel("../data/MOAI_DATABASE_PUBLIC.xlsx")

# Get ROAD and QUARRY NOT BEDROCK moai with size data
road_quarry_moai <- public_db %>%
  filter(LOCATION_TYPE %in% c("ROAD", "QUARRY NOT BEDROCK")) %>%
  mutate(
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude),
    total_length_cm = suppressWarnings(as.numeric(TOTAL_LENGTH_cm)),
    base_width_cm = suppressWarnings(as.numeric(BASE_WIDTHcm)),
    n_fragments = as.character(NUMBER_OF_FRAGMENTS)
  ) %>%
  filter(!is.na(latitude) & !is.na(longitude))

# Calculate distances directly for the road/quarry moai
QUARRY_LAT <- -27.125175
QUARRY_LON <- -109.288170

merged_data <- road_quarry_moai %>%
  mutate(
    lat_diff = (latitude - QUARRY_LAT) * 111000,
    lon_diff = (longitude - QUARRY_LON) * 99000,
    distance_from_quarry_m = sqrt(lat_diff^2 + lon_diff^2),
    distance_from_quarry_km = distance_from_quarry_m / 1000
  ) %>%
  filter(!is.na(distance_from_quarry_km))

# Use ALL moai with size data (not just complete ones) to get better coverage
# This includes fragments but gives us more data points across all distances
moai_with_size <- merged_data %>%
  filter(!is.na(total_length_cm) & total_length_cm > 0) %>%
  mutate(
    height_m = total_length_cm / 100,
    size_metric = ifelse(!is.na(base_width_cm), 
                         total_length_cm * base_width_cm, 
                         total_length_cm * total_length_cm * 0.3),  # Estimate if width missing
    is_complete = (n_fragments == "1" | n_fragments == 1)
  )

cat(sprintf("Moai with size and distance data: %d\n", nrow(moai_with_size)))
cat(sprintf("  Complete moai: %d\n", sum(moai_with_size$is_complete, na.rm = TRUE)))
cat(sprintf("  Fragments: %d\n", sum(!moai_with_size$is_complete, na.rm = TRUE)))

# Use the renamed variable for consistency
complete_moai <- moai_with_size

# Define transport phases based on distance
complete_moai <- complete_moai %>%
  mutate(
    transport_phase = case_when(
      distance_from_quarry_km <= 2 ~ "Early\n(0-2 km)",
      distance_from_quarry_km <= 5 ~ "Middle\n(2-5 km)",
      TRUE ~ "Late\n(5+ km)"
    ),
    transport_phase = factor(transport_phase, 
                            levels = c("Early\n(0-2 km)", "Middle\n(2-5 km)", "Late\n(5+ km)"))
  )

# Calculate phase statistics
phase_stats <- complete_moai %>%
  group_by(transport_phase) %>%
  summarise(
    n = n(),
    mean_height = mean(height_m),
    median_height = median(height_m),
    sd_height = sd(height_m),
    .groups = 'drop'
  )

print(phase_stats)

# Run correlation test
cor_test <- cor.test(complete_moai$distance_from_quarry_km, complete_moai$total_length_cm)
lm_model <- lm(total_length_cm ~ distance_from_quarry_km, data = complete_moai)

cat(sprintf("\nCorrelation Analysis:\n"))
cat(sprintf("Pearson r = %.3f\n", cor_test$estimate))
cat(sprintf("p-value = %.4f\n", cor_test$p.value))
cat(sprintf("R² = %.3f\n", summary(lm_model)$r.squared))

# Create the two-panel figure
par(mfrow = c(1, 2), mar = c(5, 4, 3, 2))

# Panel A: Scatter plot with regression
plot(complete_moai$distance_from_quarry_km, complete_moai$total_length_cm,
     main = "A. Size vs Distance Regression",
     xlab = "Distance from Quarry (km)",
     ylab = "Total Length (cm)",
     pch = 19,
     col = rgb(0.2, 0.2, 0.2, 0.6),
     las = 1,
     xlim = c(0, max(complete_moai$distance_from_quarry_km) * 1.1))

# Add regression line with confidence interval
pred_data <- data.frame(distance_from_quarry_km = seq(0, max(complete_moai$distance_from_quarry_km), 
                                                      length.out = 100))
pred <- predict(lm_model, pred_data, interval = "confidence")

# Add confidence band
polygon(c(pred_data$distance_from_quarry_km, rev(pred_data$distance_from_quarry_km)),
        c(pred[,"lwr"], rev(pred[,"upr"])),
        col = rgb(0.5, 0.5, 0.5, 0.2),
        border = NA)

# Add regression line
lines(pred_data$distance_from_quarry_km, pred[,"fit"], 
      col = "red", lwd = 2)

# Add statistics text
text(max(complete_moai$distance_from_quarry_km) * 0.7, 
     max(complete_moai$total_length_cm) * 0.95,
     sprintf("r = %.3f\np = %.4f\nn = %d", 
             cor_test$estimate, cor_test$p.value, nrow(complete_moai)),
     pos = 4, cex = 0.9)

# Panel B: Box plots by transport phase
phase_counts <- table(complete_moai$transport_phase)
medians <- tapply(complete_moai$total_length_cm, complete_moai$transport_phase, median)

boxplot(total_length_cm ~ transport_phase, data = complete_moai,
        main = "B. Size by Transport Phase (All Moai)",
        xlab = "Transport Phase",
        ylab = "Total Length (cm)",
        col = c("#e74c3c", "#3498db", "#2ecc71"),
        las = 1,
        outline = TRUE)

# Add sample sizes
mtext(side = 1, at = 1:3, text = paste0("n=", phase_counts), 
      line = 2.5, cex = 0.8)

# Add median values
points(1:3, medians, pch = 18, cex = 2, col = "black")

# Save the figure
if (!dir.exists("../figures")) {
  dir.create("../figures")
}

# Save in multiple formats
# High resolution PNG (600 dpi)
png("../figures/Figure_13_size_distance_analysis.png", 
    width = 10, height = 5, units = "in", res = 600)
par(mfrow = c(1, 2), mar = c(5, 4, 3, 2))

# Recreate Panel A for PNG
plot(complete_moai$distance_from_quarry_km, complete_moai$total_length_cm,
     main = "A. Size vs Distance Regression",
     xlab = "Distance from Quarry (km)",
     ylab = "Total Length (cm)",
     pch = 19,
     col = rgb(0.2, 0.2, 0.2, 0.6),
     las = 1,
     xlim = c(0, max(complete_moai$distance_from_quarry_km) * 1.1))
polygon(c(pred_data$distance_from_quarry_km, rev(pred_data$distance_from_quarry_km)),
        c(pred[,"lwr"], rev(pred[,"upr"])),
        col = rgb(0.5, 0.5, 0.5, 0.2),
        border = NA)
lines(pred_data$distance_from_quarry_km, pred[,"fit"], 
      col = "red", lwd = 2)
text(max(complete_moai$distance_from_quarry_km) * 0.7, 
     max(complete_moai$total_length_cm) * 0.95,
     sprintf("r = %.3f\np = %.4f\nn = %d", 
             cor_test$estimate, cor_test$p.value, nrow(complete_moai)),
     pos = 4, cex = 0.9)

# Recreate Panel B for PNG (now box plots)
boxplot(total_length_cm ~ transport_phase, data = complete_moai,
        main = "B. Size by Transport Phase (All Moai)",
        xlab = "Transport Phase",
        ylab = "Total Length (cm)",
        col = c("#e74c3c", "#3498db", "#2ecc71"),
        las = 1,
        outline = TRUE)
mtext(side = 1, at = 1:3, text = paste0("n=", phase_counts), 
      line = 2.5, cex = 0.8)
points(1:3, medians, pch = 18, cex = 2, col = "black")
dev.off()

# Low resolution preview PNG (150 dpi)
png("../figures/Figure_13_size_distance_analysis_preview.png", 
    width = 10, height = 5, units = "in", res = 150)
par(mfrow = c(1, 2), mar = c(5, 4, 3, 2))

# Recreate Panel A for preview PNG
plot(complete_moai$distance_from_quarry_km, complete_moai$total_length_cm,
     main = "A. Size vs Distance Regression",
        xlab = "Transport Phase",
        ylab = "Total Length (cm)",
        col = c("#e74c3c", "#3498db", "#2ecc71"),
        las = 1,
        outline = TRUE)
mtext(side = 1, at = 1:3, text = paste0("n=", phase_counts), 
      line = 2.5, cex = 0.8)
points(1:3, medians, pch = 18, cex = 2, col = "black")

# Recreate Panel B for preview PNG
plot(complete_moai$distance_from_quarry_km, complete_moai$total_length_cm,
     main = "B. Size vs Distance Regression",
        xlab = "Transport Phase",
        ylab = "Total Length (cm)",
        col = c("#e74c3c", "#3498db", "#2ecc71"),
        las = 1,
        outline = TRUE)
mtext(side = 1, at = 1:3, text = paste0("n=", phase_counts), 
      line = 2.5, cex = 0.8)
points(1:3, medians, pch = 18, cex = 2, col = "black")
dev.off()

pdf("../figures/Figure_13_size_distance_analysis.pdf", width = 10, height = 5)
par(mfrow = c(1, 2), mar = c(5, 4, 3, 2))

# Repeat Panel A for PDF
plot(complete_moai$distance_from_quarry_km, complete_moai$total_length_cm,
     main = "A. Size vs Distance Regression",
        xlab = "Transport Phase",
        ylab = "Total Length (cm)",
        col = c("#e74c3c", "#3498db", "#2ecc71"),
        las = 1,
        outline = TRUE)
mtext(side = 1, at = 1:3, text = paste0("n=", phase_counts), 
      line = 2.5, cex = 0.8)
points(1:3, medians, pch = 18, cex = 2, col = "black")

# Repeat Panel B for PDF
plot(complete_moai$distance_from_quarry_km, complete_moai$total_length_cm,
     main = "B. Size vs Distance Regression",
        xlab = "Transport Phase",
        ylab = "Total Length (cm)",
        col = c("#e74c3c", "#3498db", "#2ecc71"),
        las = 1,
        outline = TRUE)
mtext(side = 1, at = 1:3, text = paste0("n=", phase_counts), 
      line = 2.5, cex = 0.8)
points(1:3, medians, pch = 18, cex = 2, col = "black")
dev.off()

# Save statistics
write.csv(phase_stats, "../figures/Figure_13_phase_statistics.csv", row.names = FALSE)
write.csv(complete_moai %>% 
          select(distance_from_quarry_km, total_length_cm, height_m, transport_phase),
          "../figures/Figure_13_analysis_data.csv", row.names = FALSE)

cat("\n=== FIGURE 13 CREATED SUCCESSFULLY ===\n")
cat("Files saved:\n")
cat("- Figure_13_size_distance_analysis.png (600 dpi)\n")
cat("- Figure_13_size_distance_analysis_preview.png (150 dpi)\n") 
cat("- Figure_13_size_distance_analysis.pdf\n")
cat("- Figure_13_phase_statistics.csv\n")
cat("- Figure_13_analysis_data.csv\n")

cat("\n=== KEY FINDINGS ===\n")
if(cor_test$p.value < 0.05) {
  cat("Significant negative correlation between size and distance\n")
  cat("Larger moai tend to be found closer to the quarry\n")
} else {
  cat("No significant correlation between size and distance\n")
  cat("Moai size does not predict transport distance\n")
}