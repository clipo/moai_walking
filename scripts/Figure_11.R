#!/usr/bin/env Rscript
# Standalone R code for Figure 11: Expected distribution of road moai under transport failure hypothesis
# From: "Transport Failure Analysis of Easter Island Road Moai"

# Ensure reproducibility by loading required packages
# Source the package loader or install packages if needed
if (file.exists("package_loader.R")) {
  source("package_loader.R")
  load_required_packages()
} else {
  # Fallback: install and load packages directly
  required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "svglite")
  
  for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
}

# Define color palette
moai_colors <- c(
  early = "#e74c3c",
  middle = "#3498db", 
  late = "#2ecc71",
  highlight = "#e74c3c",
  secondary = "#34495e"
)

# Create the observed percentage value
# (In the original, this was calculated from actual data)
# Here we use the reported value of 51.6% within 2 km
observed_percent_within_2km <- 51.6

# Function to create transport failure expectation figure
create_transport_failure_figure <- function(observed_pct = 51.6) {
  # Set up single panel figure
  par(mar = c(5, 4, 4, 2))
  
  # Define distance range
  max_dist <- 12
  
  # Create plot with extra space at top for zone labels
  plot(0, 0, type = "n", xlim = c(0, max_dist), ylim = c(0, 16.5),
       xlab = "Distance from Quarry (km)", 
       ylab = "Expected Number of Moai",
       main = "")
  
  # Add zone backgrounds
  rect(0, 0, 2, 16.5, col = rgb(1, 0.8, 0.8, 0.3), border = NA)
  rect(2, 0, 4, 16.5, col = rgb(0.8, 0.8, 1, 0.3), border = NA)
  rect(4, 0, max_dist, 16.5, col = rgb(0.8, 1, 0.8, 0.3), border = NA)
  
  # Add transport failure pattern bars
  # High concentration in first 2 km, then rapid decrease
  bar_width <- 0.8
  failure_heights <- c(14, 12, 5, 3, 2, 2, 1, 1, 0.5, 0.5, 0.5, 0.5)
  
  for (i in 1:length(failure_heights)) {
    rect(i - 0.5 - bar_width/2, 0, 
         i - 0.5 + bar_width/2, failure_heights[i], 
         col = moai_colors["highlight"], 
         border = "darkred", 
         lwd = 2)
  }
  
  # Add zone labels at the very top, well above the bars
  text(1, 16, "Near Zone", cex = 1.0, font = 2, xpd = TRUE)
  text(3, 16, "Middle Zone", cex = 1.0, font = 2, xpd = TRUE)
  text(8, 16, "Far Zone", cex = 1.0, font = 2, xpd = TRUE)
  
  # Add percentage annotations
  text(1, failure_heights[1] + 0.5, "~60%", cex = 1.2, font = 2)
  text(3, failure_heights[3] + 0.5, "~24%", cex = 1.2, font = 2)
  text(6, failure_heights[6] + 0.5, "~16%", cex = 1.2, font = 2)
  
  # Add grid for easier reading
  grid(nx = NA, ny = NULL, col = "gray80", lty = 2)
  
  # Add prediction text box
  text(8.5, 10, 
       "Prediction:\nMost failures occur near\nthe quarry due to:\n• Structural flaws\n• Learning curve\n• Initiation challenges", 
       cex = 1, font = 3, adj = 0.5,
       bg = "white", box = TRUE)
  
  # Add observed value annotation
  text(1, 8, 
       sprintf("Observed:\n%.1f%% within 2 km", observed_pct), 
       cex = 1, font = 2, col = "darkred")
}

# Display the figure in current graphics device
create_transport_failure_figure(observed_percent_within_2km)

# Save figures (optional - uncomment to save)
# Create figures directory if it doesn't exist
if (!dir.exists("../figures")) {
  dir.create("../figures")
}

# Save as high-resolution PNG (600 dpi)
png("../figures/Figure_11_transport_failure_expectation.png", 
    width = 8, height = 5, units = "in", res = 600)
create_transport_failure_figure(observed_percent_within_2km)
dev.off()

# Also save a standard resolution PNG for quick viewing (150 dpi)
png("../figures/Figure_11_transport_failure_expectation_preview.png", 
    width = 8, height = 5, units = "in", res = 150)
create_transport_failure_figure(observed_percent_within_2km)
dev.off()

# Save as SVG
svglite("../figures/Figure_11_transport_failure_expectation.svg", 
        width = 8, height = 5)
create_transport_failure_figure(observed_percent_within_2km)
dev.off()

# Save as PDF
pdf("../figures/Figure_11_transport_failure_expectation.pdf", 
    width = 8, height = 5)
create_transport_failure_figure(observed_percent_within_2km)
dev.off()

cat("Figure 11 created successfully!\n")
cat("Files saved in 'figures' directory:\n")
cat("- Figure_11_transport_failure_expectation.svg (vector format)\n")
cat("- Figure_11_transport_failure_expectation.png (600 dpi)\n")
cat("- Figure_11_transport_failure_expectation_preview.png (150 dpi for preview)\n")
cat("- Figure_11_transport_failure_expectation.pdf\n")