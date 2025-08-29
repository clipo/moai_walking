#!/usr/bin/env Rscript
# Figure 6: Elevation and slope profiles for moai transport roads
# Creates a two-panel figure showing elevation profiles and terrain slopes
# Data from GPS surveys of moai transport roads on Easter Island

library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(cowplot)

cat("=== CREATING FIGURE 6: SLOPE PROFILES ===\n\n")

# Read the slope data files
cat("Reading slope data files...\n")
raraku_road <- read_excel("../data/moai_road_slope_from_raraku.xlsx")
south_coast <- read_excel("../data/southcoast_road_only_slope.xlsx")

# Clean column names for raraku road (handling duplicates)
names(raraku_road)[names(raraku_road) == "Max_Slope...13"] <- "Max_Slope"
names(raraku_road)[names(raraku_road) == "Max_Slope...6"] <- "Max_Slope_old"

# Clean column names for south coast (handling duplicates)
names(south_coast)[names(south_coast) == "Max_Slope...12"] <- "Max_Slope"
names(south_coast)[names(south_coast) == "Max_Slope...6"] <- "Max_Slope_old"

# Remove NA rows from both datasets
raraku_road <- raraku_road %>% 
  filter(!is.na(Distance) & !is.na(Elevation) & !is.na(Max_Slope))

south_coast <- south_coast %>% 
  filter(!is.na(Distance) & !is.na(Elevation) & !is.na(Max_Slope))

# Function to create dual-axis slope profile plot
create_slope_profile <- function(data, title) {
  # Ensure data is sorted by distance
  data <- data %>% arrange(Distance)
  
  # Calculate scaling factor for secondary axis
  max_elev <- max(data$Elevation, na.rm = TRUE)
  min_elev <- min(data$Elevation, na.rm = TRUE)
  max_slope <- max(data$Max_Slope, na.rm = TRUE)
  
  # Scale factor to fit slope data on same plot
  slope_scale <- (max_elev - min_elev) / 50
  
  # Create base plot with elevation
  p <- ggplot(data) +
    # Elevation profile (primary y-axis)
    geom_line(aes(x = Distance, y = Elevation), 
              color = "#4169E1", linewidth = 1.2) +
    
    # Max slope profile (secondary y-axis) - scaled to fit
    geom_line(aes(x = Distance, y = Max_Slope * slope_scale + min_elev), 
              color = "#FF8C00", linewidth = 0.7, alpha = 0.9) +
    
    # Primary y-axis (Elevation)
    scale_y_continuous(
      name = "Elevation (MSL)",
      limits = c(min_elev * 0.9, max_elev * 1.1),
      expand = c(0, 0)
    ) +
    
    # X-axis
    scale_x_continuous(
      name = "Distance from Rano Raraku (m)",
      expand = c(0.01, 0)
    ) +
    
    # Title and theme
    ggtitle(title) +
    theme_classic() +
    theme(
      plot.title = element_text(size = 12, face = "bold", hjust = 0.5),
      axis.title.x = element_text(size = 10),
      axis.title.y = element_text(size = 10, color = "blue"),
      axis.text.y = element_text(color = "blue"),
      axis.ticks.y = element_line(color = "blue"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
  
  # Add secondary y-axis for slope
  p <- p + 
    scale_y_continuous(
      name = "Elevation (MSL)",
      limits = c(min_elev * 0.9, max_elev * 1.1),
      expand = c(0, 0),
      sec.axis = sec_axis(
        trans = ~ (. - min_elev) / slope_scale,
        name = "Slope Percent (%)",
        breaks = seq(0, 50, 10)
      )
    ) +
    theme(
      axis.title.y.right = element_text(size = 10, color = "darkorange"),
      axis.text.y.right = element_text(color = "darkorange"),
      axis.ticks.y.right = element_line(color = "darkorange")
    )
  
  # Add legend without box
  legend_x <- max(data$Distance) * 0.85
  legend_y_top <- max_elev * 0.95
  legend_y_bottom <- max_elev * 0.88
  
  p <- p +
    # Legend lines
    annotate("segment", 
             x = legend_x - max(data$Distance) * 0.04, 
             xend = legend_x - max(data$Distance) * 0.01,
             y = legend_y_top, yend = legend_y_top,
             color = "#4169E1", linewidth = 1) +
    annotate("segment", 
             x = legend_x - max(data$Distance) * 0.04, 
             xend = legend_x - max(data$Distance) * 0.01,
             y = legend_y_bottom, yend = legend_y_bottom,
             color = "#FF8C00", linewidth = 0.7) +
    # Legend text
    annotate("text", x = legend_x, y = legend_y_top,
             label = "Elevation", color = "black", size = 3.5, hjust = 0) +
    annotate("text", x = legend_x, y = legend_y_bottom,
             label = "Max. Slope", color = "black", size = 3.5, hjust = 0)
  
  return(p)
}

# Create plots for both roads
cat("Creating slope profile plots...\n")

# Plot 1: Moai Road from Rano Raraku
p1 <- create_slope_profile(raraku_road, 
                           "Moai Road from Rano Raraku to South Coast")

# Plot 2: South Coast Road Only
p2 <- create_slope_profile(south_coast, 
                           "South Coast Road Segment")

# Combine plots into a two-panel figure
combined_plot <- plot_grid(p1, p2, 
                          ncol = 1, 
                          nrow = 2,
                          align = "v",
                          rel_heights = c(1, 1))

# Save the figure in multiple formats
cat("Saving Figure 6...\n")

# High-resolution PNG for publication
png("../figures/Figure_6_slope_profiles.png", 
    width = 12, height = 8, units = "in", res = 600)
print(combined_plot)
dev.off()

# Preview PNG
png("../figures/Figure_6_slope_profiles_preview.png", 
    width = 12, height = 8, units = "in", res = 150)
print(combined_plot)
dev.off()

# SVG for editing
svglite::svglite("../figures/Figure_6_slope_profiles.svg", 
                 width = 12, height = 8)
print(combined_plot)
dev.off()

# PDF for manuscripts
pdf("../figures/Figure_6_slope_profiles.pdf", 
    width = 12, height = 8)
print(combined_plot)
dev.off()

# Print summary statistics
cat("\n=== SUMMARY STATISTICS ===\n")
cat("\nRano Raraku to South Coast Road:\n")
cat(sprintf("  Total distance: %.1f m\n", max(raraku_road$Distance)))
cat(sprintf("  Elevation range: %.1f - %.1f m\n", 
            min(raraku_road$Elevation), max(raraku_road$Elevation)))
cat(sprintf("  Maximum slope: %.1f%%\n", max(raraku_road$Max_Slope)))
cat(sprintf("  Mean slope: %.1f%%\n", mean(raraku_road$Max_Slope)))
cat(sprintf("  Slopes > 10%%: %d segments (%.1f%%)\n", 
            sum(raraku_road$Max_Slope > 10),
            100 * sum(raraku_road$Max_Slope > 10) / nrow(raraku_road)))

cat("\nSouth Coast Road Segment:\n")
cat(sprintf("  Total distance: %.1f m\n", max(south_coast$Distance)))
cat(sprintf("  Elevation range: %.1f - %.1f m\n", 
            min(south_coast$Elevation), max(south_coast$Elevation)))
cat(sprintf("  Maximum slope: %.1f%%\n", max(south_coast$Max_Slope)))
cat(sprintf("  Mean slope: %.1f%%\n", mean(south_coast$Max_Slope)))
cat(sprintf("  Slopes > 10%%: %d segments (%.1f%%)\n", 
            sum(south_coast$Max_Slope > 10),
            100 * sum(south_coast$Max_Slope > 10) / nrow(south_coast)))

cat("\nFigure 6 saved as:\n")
cat("  ../figures/Figure_6_slope_profiles.png (600 dpi)\n")
cat("  ../figures/Figure_6_slope_profiles_preview.png (150 dpi)\n")
cat("  ../figures/Figure_6_slope_profiles.svg\n")
cat("  ../figures/Figure_6_slope_profiles.pdf\n")