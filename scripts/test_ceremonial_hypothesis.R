#!/usr/bin/env Rscript
# Test Ceremonial Placement Hypothesis vs Transport Failure Model
# This script tests alternative hypotheses for road moai distribution

library(dplyr)
library(ggplot2)

cat("=== TESTING CEREMONIAL PLACEMENT HYPOTHESIS ===\n\n")
cat("This analysis tests whether road moai placement follows ceremonial patterns\n")
cat("rather than transport failure patterns.\n\n")

# Load the road moai data
road_moai <- read.csv("../data/road_moai_distances.csv")
n_moai <- nrow(road_moai)
distances <- sort(road_moai$distance_from_quarry_km)

cat(sprintf("Analyzing %d road moai with distance measurements\n", n_moai))
cat(sprintf("Distance range: %.2f to %.2f km\n\n", min(distances), max(distances)))

# =============================================================================
# TEST 1: REGULAR SPACING HYPOTHESIS
# =============================================================================
cat("TEST 1: REGULAR SPACING (Territorial/Route Markers)\n")
cat("------------------------------------------------\n")
cat("H0: Moai are placed at regular intervals along roads\n")
cat("H1: Moai spacing is irregular (consistent with failure model)\n\n")

# Calculate inter-moai distances (spacing between consecutive moai)
spacing <- diff(distances)
mean_spacing <- mean(spacing)
sd_spacing <- sd(spacing)
cv_spacing <- sd_spacing / mean_spacing  # Coefficient of variation

cat(sprintf("Inter-moai spacing statistics:\n"))
cat(sprintf("  Mean spacing: %.3f km\n", mean_spacing))
cat(sprintf("  SD of spacing: %.3f km\n", sd_spacing))
cat(sprintf("  Coefficient of variation: %.3f\n", cv_spacing))

# Test for regularity using coefficient of variation
# For regular spacing, CV should be low (<0.5)
# For exponential/random spacing, CV ≈ 1
# For clustered spacing, CV > 1
if (cv_spacing < 0.5) {
  spacing_pattern <- "REGULAR (supports ceremonial)"
} else if (cv_spacing > 1.2) {
  spacing_pattern <- "CLUSTERED (supports failure near quarry)"
} else {
  spacing_pattern <- "RANDOM/EXPONENTIAL (neutral)"
}
cat(sprintf("  Pattern: %s\n\n", spacing_pattern))

# Kolmogorov-Smirnov test against uniform distribution
ks_uniform <- ks.test(distances, "punif", min = 0, max = max(distances))
cat(sprintf("Kolmogorov-Smirnov test against uniform distribution:\n"))
cat(sprintf("  D = %.4f, p-value = %.4f\n", ks_uniform$statistic, ks_uniform$p.value))
if (ks_uniform$p.value < 0.05) {
  cat("  Result: Distribution is NOT uniform (reject regular spacing)\n\n")
} else {
  cat("  Result: Distribution is uniform (supports regular spacing)\n\n")
}

# =============================================================================
# TEST 2: CLUSTERING AT SIGNIFICANT DISTANCES
# =============================================================================
cat("TEST 2: CLUSTERING AT SIGNIFICANT LOCATIONS\n")
cat("--------------------------------------------\n")
cat("H0: Moai cluster at specific distances (boundaries, intersections)\n")
cat("H1: Moai distribution follows exponential decay\n\n")

# Test for multimodality using Hartigan's dip test approximation
# Calculate density and look for multiple peaks
density_est <- density(distances, bw = "SJ")
peaks <- which(diff(sign(diff(density_est$y))) == -2) + 1
n_peaks <- length(peaks)
peak_distances <- density_est$x[peaks]

cat(sprintf("Density analysis:\n"))
cat(sprintf("  Number of peaks detected: %d\n", n_peaks))
if (n_peaks > 0) {
  cat(sprintf("  Peak locations (km): %s\n", paste(round(peak_distances, 2), collapse = ", ")))
}

# Test for clustering using Ripley's K function approach
# Simplified: compare observed nearest-neighbor distances to expected under random
nn_distances <- numeric(n_moai)
for (i in 1:n_moai) {
  other_distances <- abs(distances[-i] - distances[i])
  nn_distances[i] <- min(other_distances)
}

# Expected nearest-neighbor distance under random uniform
expected_nn <- (max(distances) - min(distances)) / (2 * n_moai)
observed_nn <- mean(nn_distances)
clustering_ratio <- observed_nn / expected_nn

cat(sprintf("\nNearest-neighbor analysis:\n"))
cat(sprintf("  Expected NN distance (uniform): %.3f km\n", expected_nn))
cat(sprintf("  Observed NN distance: %.3f km\n", observed_nn))
cat(sprintf("  Ratio (obs/exp): %.3f\n", clustering_ratio))

if (clustering_ratio < 0.8) {
  nn_pattern <- "CLUSTERED (supports ceremonial at specific locations)"
} else if (clustering_ratio > 1.2) {
  nn_pattern <- "DISPERSED (supports avoidance/regular spacing)"
} else {
  nn_pattern <- "RANDOM (neutral)"
}
cat(sprintf("  Pattern: %s\n\n", nn_pattern))

# =============================================================================
# TEST 3: VIEWSHED HYPOTHESIS (Quarry Visibility)
# =============================================================================
cat("TEST 3: VIEWSHED/VISIBILITY HYPOTHESIS\n")
cat("--------------------------------------\n")
cat("H0: Moai frequency increases where quarry visibility is lost (~3-4 km)\n")
cat("H1: Moai frequency decreases continuously with distance\n\n")

# Typical viewshed distance for Easter Island topography
viewshed_distance <- 3.5  # km (approximate based on island topography)

# Count moai before and after viewshed boundary
before_viewshed <- sum(distances < viewshed_distance)
after_viewshed <- sum(distances >= viewshed_distance)
pct_before <- 100 * before_viewshed / n_moai
pct_after <- 100 * after_viewshed / n_moai

cat(sprintf("Distribution relative to viewshed boundary (%.1f km):\n", viewshed_distance))
cat(sprintf("  Before viewshed boundary: %d moai (%.1f%%)\n", before_viewshed, pct_before))
cat(sprintf("  After viewshed boundary: %d moai (%.1f%%)\n", after_viewshed, pct_after))

# Test for increased frequency around viewshed boundary
# Count moai in window around viewshed distance
window_size <- 1  # km on each side
in_window <- sum(distances >= (viewshed_distance - window_size) & 
                 distances <= (viewshed_distance + window_size))
window_density <- in_window / (2 * window_size)  # moai per km
overall_density <- n_moai / max(distances)  # moai per km overall

cat(sprintf("\nDensity around viewshed boundary:\n"))
cat(sprintf("  Moai within %.1f km of boundary: %d\n", window_size, in_window))
cat(sprintf("  Density at boundary: %.2f moai/km\n", window_density))
cat(sprintf("  Overall density: %.2f moai/km\n", overall_density))
cat(sprintf("  Ratio (boundary/overall): %.2f\n", window_density / overall_density))

if (window_density > 1.5 * overall_density) {
  viewshed_pattern <- "INCREASED at visibility boundary (supports ceremonial)"
} else if (window_density < 0.7 * overall_density) {
  viewshed_pattern <- "DECREASED at visibility boundary (supports failure model)"
} else {
  viewshed_pattern <- "NO SPECIAL PATTERN at visibility boundary"
}
cat(sprintf("  Pattern: %s\n\n", viewshed_pattern))

# =============================================================================
# TEST 4: EXPONENTIAL DECAY (Transport Failure Model)
# =============================================================================
cat("TEST 4: EXPONENTIAL DECAY MODEL FIT\n")
cat("------------------------------------\n")
cat("Testing goodness of fit to exponential decay model\n\n")

# Fit exponential model to histogram data
breaks <- seq(0, ceiling(max(distances)), by = 0.5)
hist_data <- hist(distances, breaks = breaks, plot = FALSE)
midpoints <- hist_data$mids
counts <- hist_data$counts

# Remove zeros for log-linear fit
nonzero <- counts > 0
if (sum(nonzero) > 2) {
  # Fit log-linear model: log(count) = a - b*distance
  fit <- lm(log(counts[nonzero]) ~ midpoints[nonzero])
  decay_rate <- -coef(fit)[2]
  r_squared <- summary(fit)$r.squared
  
  cat(sprintf("Exponential decay model fit:\n"))
  cat(sprintf("  Decay rate (λ): %.3f per km\n", decay_rate))
  cat(sprintf("  R-squared: %.3f\n", r_squared))
  cat(sprintf("  Half-distance: %.2f km\n", log(2) / decay_rate))
  
  if (r_squared > 0.6) {
    exponential_fit <- "GOOD FIT (supports transport failure)"
  } else if (r_squared > 0.3) {
    exponential_fit <- "MODERATE FIT (weak support for failure model)"
  } else {
    exponential_fit <- "POOR FIT (does not support failure model)"
  }
  cat(sprintf("  Assessment: %s\n\n", exponential_fit))
} else {
  cat("  Insufficient data for exponential fit\n\n")
  exponential_fit <- "INSUFFICIENT DATA"
  r_squared <- NA
}

# =============================================================================
# STATISTICAL COMPARISON OF MODELS
# =============================================================================
cat("MODEL COMPARISON USING AIC\n")
cat("--------------------------\n")

# Prepare data for model comparison
dist_data <- data.frame(
  distance = distances,
  rank = 1:n_moai
)

# Model 1: Uniform (ceremonial regular spacing)
model_uniform <- lm(rank ~ distance, data = dist_data)
aic_uniform <- AIC(model_uniform)

# Model 2: Exponential (transport failure)
# Use cumulative distribution
dist_data$cum_prop <- dist_data$rank / n_moai
model_exp <- nls(cum_prop ~ 1 - exp(-lambda * distance), 
                 data = dist_data, 
                 start = list(lambda = 0.5),
                 control = nls.control(warnOnly = TRUE))
aic_exp <- AIC(model_exp)

# Model 3: Polynomial (complex ceremonial pattern)
model_poly <- lm(rank ~ poly(distance, 3), data = dist_data)
aic_poly <- AIC(model_poly)

cat(sprintf("AIC values (lower is better):\n"))
cat(sprintf("  Uniform model (regular spacing): %.1f\n", aic_uniform))
cat(sprintf("  Exponential model (transport failure): %.1f\n", aic_exp))
cat(sprintf("  Polynomial model (complex ceremonial): %.1f\n", aic_poly))

# Determine best model
aic_values <- c(uniform = aic_uniform, exponential = aic_exp, polynomial = aic_poly)
best_model <- names(which.min(aic_values))
cat(sprintf("\nBest model: %s\n", best_model))

# Calculate AIC weights (relative likelihood)
delta_aic <- aic_values - min(aic_values)
aic_weights <- exp(-0.5 * delta_aic) / sum(exp(-0.5 * delta_aic))

cat(sprintf("\nModel weights (relative likelihood):\n"))
cat(sprintf("  Uniform: %.1f%%\n", 100 * aic_weights["uniform"]))
cat(sprintf("  Exponential: %.1f%%\n", 100 * aic_weights["exponential"]))
cat(sprintf("  Polynomial: %.1f%%\n", 100 * aic_weights["polynomial"]))

# =============================================================================
# SUMMARY AND INTERPRETATION
# =============================================================================
cat("\n=== SUMMARY OF HYPOTHESIS TESTS ===\n\n")

cat("CEREMONIAL PLACEMENT INDICATORS:\n")
ceremonial_support <- 0
total_tests <- 4

# Evaluate regular spacing
if (cv_spacing < 0.5 || ks_uniform$p.value > 0.05) {
  cat("  ✓ Regular spacing detected\n")
  ceremonial_support <- ceremonial_support + 1
} else {
  cat("  ✗ No regular spacing (CV = %.2f)\n", cv_spacing)
}

# Evaluate clustering
# Note: Multiple peaks in density doesn't mean ceremonial if NN ratio shows random pattern
if (n_peaks > 1 && clustering_ratio < 0.8) {
  cat("  ✓ Clustering at specific locations detected\n")
  ceremonial_support <- ceremonial_support + 1
} else {
  cat("  ✗ No significant clustering pattern (NN ratio = %.2f)\n", clustering_ratio)
}

# Evaluate viewshed
if (window_density > 1.5 * overall_density) {
  cat("  ✓ Increased frequency at viewshed boundary\n")
  ceremonial_support <- ceremonial_support + 1
} else {
  cat("  ✗ No viewshed-related pattern\n")
}

# Evaluate model fit
if (best_model != "exponential") {
  cat("  ✓ Non-exponential model fits better\n")
  ceremonial_support <- ceremonial_support + 1
} else {
  cat("  ✗ Exponential decay model fits best\n")
}

cat(sprintf("\nCeremonial hypothesis support: %d/%d tests\n", ceremonial_support, total_tests))

cat("\nTRANSPORT FAILURE INDICATORS:\n")
failure_support <- 0

# Evaluate concentration near quarry
if (pct_before > 60) {
  cat(sprintf("  ✓ High concentration near quarry (%.1f%% within %.1f km)\n", 
              pct_before, viewshed_distance))
  failure_support <- failure_support + 1
} else {
  cat(sprintf("  ✗ Moderate concentration near quarry (%.1f%%)\n", pct_before))
}

# Evaluate exponential fit
if (!is.na(r_squared) && r_squared > 0.6) {
  cat(sprintf("  ✓ Good exponential decay fit (R² = %.3f)\n", r_squared))
  failure_support <- failure_support + 1
} else if (!is.na(r_squared)) {
  cat(sprintf("  ✗ Poor exponential fit (R² = %.3f)\n", r_squared))
} else {
  cat("  ? Cannot evaluate exponential fit\n")
}

# Evaluate clustering pattern
if (cv_spacing > 1.0) {
  cat("  ✓ Clustering near quarry (CV = %.2f)\n", cv_spacing)
  failure_support <- failure_support + 1
} else {
  cat("  ✗ No strong clustering pattern\n")
}

# Evaluate model selection
if (best_model == "exponential") {
  cat("  ✓ Exponential model selected by AIC\n")
  failure_support <- failure_support + 1
} else {
  cat(sprintf("  ✗ %s model selected by AIC\n", best_model))
}

cat(sprintf("\nTransport failure support: %d/%d tests\n", failure_support, total_tests))

# Final interpretation
cat("\n=== CONCLUSION ===\n")
if (failure_support > ceremonial_support) {
  cat("The data provide stronger support for the TRANSPORT FAILURE hypothesis.\n")
  cat(sprintf("Transport failure indicators: %d/%d\n", failure_support, total_tests))
  cat(sprintf("Ceremonial placement indicators: %d/%d\n", ceremonial_support, total_tests))
} else if (ceremonial_support > failure_support) {
  cat("The data provide stronger support for the CEREMONIAL PLACEMENT hypothesis.\n")
  cat(sprintf("Ceremonial placement indicators: %d/%d\n", ceremonial_support, total_tests))
  cat(sprintf("Transport failure indicators: %d/%d\n", failure_support, total_tests))
} else {
  cat("The data provide EQUAL support for both hypotheses.\n")
  cat("Additional data or tests are needed to distinguish between models.\n")
}

cat(sprintf("\nModel preference by AIC weight: %s (%.1f%% support)\n", 
            best_model, 100 * max(aic_weights)))

# =============================================================================
# VISUALIZATION
# =============================================================================
cat("\n=== GENERATING VISUALIZATION ===\n")

# Create a 4-panel figure showing the different tests
png("../figures/ceremonial_hypothesis_tests.png", 
    width = 12, height = 10, units = "in", res = 300)

par(mfrow = c(2, 2), mar = c(5, 4, 4, 2))

# Panel 1: Spacing distribution
hist(spacing, breaks = 20, main = "A. Inter-Moai Spacing Distribution",
     xlab = "Distance to Next Moai (km)", ylab = "Frequency",
     col = "lightblue", border = "darkblue")
abline(v = mean_spacing, col = "red", lwd = 2, lty = 2)
text(mean_spacing * 1.5, par("usr")[4] * 0.9, 
     sprintf("CV = %.2f\n%s", cv_spacing, spacing_pattern), 
     adj = 0, cex = 0.9)

# Panel 2: Cumulative distribution
plot(ecdf(distances), main = "B. Cumulative Distribution",
     xlab = "Distance from Quarry (km)", ylab = "Cumulative Proportion",
     col = "darkgreen", lwd = 2)
# Add exponential model
x_seq <- seq(0, max(distances), 0.1)
if (exists("model_exp")) {
  exp_pred <- predict(model_exp, newdata = data.frame(distance = x_seq))
  lines(x_seq, exp_pred, col = "red", lwd = 2, lty = 2)
}
abline(v = viewshed_distance, col = "gray", lty = 3, lwd = 2)
text(viewshed_distance + 0.5, 0.2, "Viewshed\nboundary", cex = 0.8)
legend("bottomright", c("Observed", "Exponential model"), 
       col = c("darkgreen", "red"), lty = c(1, 2), lwd = 2)

# Panel 3: Density plot
plot(density_est, main = "C. Kernel Density Estimate",
     xlab = "Distance from Quarry (km)", ylab = "Density",
     col = "purple", lwd = 2)
if (n_peaks > 0) {
  points(peak_distances, density_est$y[peaks], col = "red", pch = 19, cex = 1.5)
  text(peak_distances, density_est$y[peaks], "Peak", pos = 3, cex = 0.8)
}
polygon(density_est$x, density_est$y, col = rgb(0.5, 0, 0.5, 0.3), border = NA)

# Panel 4: Model comparison
barplot(aic_weights * 100, 
        names.arg = c("Uniform", "Exponential", "Polynomial"),
        main = "D. Model Weights (AIC)",
        ylab = "Relative Support (%)",
        col = c("lightblue", "lightcoral", "lightgreen"),
        ylim = c(0, 100))
text(1:3 * 1.2 - 0.5, aic_weights * 100 + 5, 
     sprintf("%.1f%%", aic_weights * 100), cex = 0.9)

dev.off()

cat("Visualization saved as: ../figures/ceremonial_hypothesis_tests.png\n")

# Save results to CSV for reference
results_summary <- data.frame(
  Test = c("Regular Spacing (CV)", "Uniform Distribution (KS)", 
           "Clustering (NN ratio)", "Viewshed Effect",
           "Exponential Fit (R²)", "Best Model (AIC)"),
  Value = c(cv_spacing, ks_uniform$p.value, 
            clustering_ratio, window_density / overall_density,
            ifelse(is.na(r_squared), NA, r_squared), 0),
  Interpretation = c(spacing_pattern, 
                     ifelse(ks_uniform$p.value < 0.05, "Not uniform", "Uniform"),
                     nn_pattern, viewshed_pattern,
                     ifelse(is.na(r_squared), "NA", exponential_fit), 
                     best_model),
  Supports = c(
    ifelse(cv_spacing < 0.5, "Ceremonial", "Failure"),
    ifelse(ks_uniform$p.value > 0.05, "Ceremonial", "Failure"),
    ifelse(clustering_ratio < 0.8, "Ceremonial", "Failure"),
    ifelse(window_density > 1.5 * overall_density, "Ceremonial", "Neither"),
    ifelse(!is.na(r_squared) && r_squared > 0.6, "Failure", "Neither"),
    ifelse(best_model == "exponential", "Failure", "Ceremonial")
  )
)

write.csv(results_summary, "../figures/ceremonial_hypothesis_results.csv", row.names = FALSE)
cat("\nResults summary saved as: ../figures/ceremonial_hypothesis_results.csv\n")

cat("\n=== ANALYSIS COMPLETE ===\n")