#!/usr/bin/env Rscript
# Figure 5: Base angle vs size for intact road moai
# Using explicit package::function notation

# Check for required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "svglite")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

cat("=== FIGURE 5: INTACT ROAD MOAI - BASE ANGLE VS SIZE ===\n\n")

# Load the combined dataset
cat("Loading moai dataset...\n")
data <- utils::read.csv("../data/all_moai_combined.csv")
cat(sprintf("Total records: %d\n\n", nrow(data)))

# Filter for INTACT ROAD MOAI
cat("Filtering for intact road moai:\n")
cat("- location_type = 'ROAD'\n")
cat("- n.of.pieces = 1 (intact)\n")
cat("- valid measurements\n\n")

# Apply filters using dplyr
intact_road_moai <- data %>%
  dplyr::filter(location_type == "ROAD") %>%
  dplyr::filter(n.of.pieces == "1" | n.of.pieces == 1) %>%
  dplyr::filter(!is.na(mean_base_angle) & 
                !is.na(total_length_cm) & 
                !is.na(base_width_cm)) %>%
  dplyr::filter(mean_base_angle > 0 & mean_base_angle < 90) %>%
  dplyr::filter(total_length_cm > 0 & base_width_cm > 0) %>%
  dplyr::mutate(size_metric = total_length_cm * base_width_cm) %>%
  dplyr::filter(size_metric > 100)

cat(sprintf("Intact road moai with complete data: %d\n\n", nrow(intact_road_moai)))

# Check if we have enough data
if(nrow(intact_road_moai) < 3) {
  stop("Insufficient intact road moai for analysis. Check data filters.")
}

# Calculate statistics
angle_range <- range(intact_road_moai$mean_base_angle)
size_range <- range(intact_road_moai$size_metric)
size_fold <- max(intact_road_moai$size_metric) / min(intact_road_moai$size_metric)

# Calculate correlation
correlation <- stats::cor(intact_road_moai$mean_base_angle, 
                          intact_road_moai$size_metric)

# Linear regression
lm_model <- stats::lm(mean_base_angle ~ size_metric, data = intact_road_moai)
r_squared <- summary(lm_model)$r.squared
p_value <- summary(lm_model)$coefficients[2, 4]

# Print statistics
cat("=== STATISTICS ===\n")
cat(sprintf("Sample size: n = %d\n", nrow(intact_road_moai)))
cat(sprintf("Base angle range: %.1f° - %.1f° (%.1f° total)\n", 
            angle_range[1], angle_range[2], diff(angle_range)))
cat(sprintf("Size variation: %.1f-fold\n", size_fold))
cat(sprintf("Correlation: r = %.4f (p = %.4f)\n\n", correlation, p_value))

# Interpretation
if(abs(correlation) < 0.1) {
  cat("INTERPRETATION: Negligible correlation - standardized construction\n")
} else if(abs(correlation) < 0.3) {
  cat("INTERPRETATION: Weak correlation - relatively consistent angles\n")
} else {
  cat("INTERPRETATION: Moderate/strong correlation detected\n")
}

# Create the figure
cat("\nCreating figure...\n")
p <- ggplot2::ggplot(intact_road_moai, 
                     ggplot2::aes(x = mean_base_angle, y = size_metric)) +
  
  # Points colored by position if available
  {if("Position" %in% names(intact_road_moai) && 
      any(!is.na(intact_road_moai$Position))) {
    ggplot2::geom_point(ggplot2::aes(color = Position, size = total_length_cm), 
                       alpha = 0.7)
  } else {
    ggplot2::geom_point(ggplot2::aes(size = total_length_cm), 
                       alpha = 0.7, color = "#2c3e50")
  }} +
  
  # Regression line
  ggplot2::geom_smooth(method = "lm", se = TRUE, color = "darkred", 
                       linetype = "dashed", alpha = 0.2, size = 0.8) +
  
  # Color scale for position
  {if("Position" %in% names(intact_road_moai) && 
      any(!is.na(intact_road_moai$Position))) {
    ggplot2::scale_color_manual(
      values = c("prone" = "#e74c3c", "supine" = "#3498db"),
      labels = c("Prone (face down)", "Supine (face up)"),
      na.value = "#95a5a6",
      name = "Final Position"
    )
  }} +
  
  # Size scale
  ggplot2::scale_size_continuous(
    name = "Height (cm)",
    range = c(3, 10),
    breaks = pretty(range(intact_road_moai$total_length_cm), n = 4)
  ) +
  
  # Format axes
  ggplot2::scale_x_continuous(
    limits = c(floor(angle_range[1]) - 0.5, ceiling(angle_range[2]) + 0.5),
    breaks = seq(floor(angle_range[1]), ceiling(angle_range[2]), by = 2)
  ) +
  ggplot2::scale_y_continuous(
    labels = function(x) format(x, big.mark = ",", scientific = FALSE),
    limits = c(0, max(intact_road_moai$size_metric) * 1.1)
  ) +
  
  # Labels
  ggplot2::labs(
    title = "Base Angle vs Size: Intact Road Moai",
    subtitle = sprintf("n = %d | r = %.3f (p = %.3f) | %.0f-fold size variation | Angle range: %.1f°", 
                      nrow(intact_road_moai), correlation, p_value, 
                      size_fold, diff(angle_range)),
    x = "Mean Base Angle (degrees)",
    y = expression(paste("Size Metric (Length × Width, cm"^"2", ")"))
  ) +
  
  # Theme
  ggplot2::theme_bw() +
  ggplot2::theme(
    plot.title = ggplot2::element_text(size = 16, face = "bold"),
    plot.subtitle = ggplot2::element_text(size = 11, color = "gray40"),
    axis.title = ggplot2::element_text(size = 12),
    axis.text = ggplot2::element_text(size = 10),
    legend.position = c(0.85, 0.25),
    legend.background = ggplot2::element_rect(fill = "white", color = "gray80"),
    legend.title = ggplot2::element_text(size = 10, face = "bold"),
    legend.text = ggplot2::element_text(size = 9),
    panel.grid.minor = ggplot2::element_blank()
  ) +
  
  # Highlight angle range
  ggplot2::annotate("rect", 
                   xmin = angle_range[1], xmax = angle_range[2],
                   ymin = -Inf, ymax = Inf,
                   alpha = 0.05, fill = "blue") +
  ggplot2::annotate("text", 
                   x = mean(angle_range), 
                   y = max(intact_road_moai$size_metric) * 0.95,
                   label = sprintf("Narrow range:\n%.1f° - %.1f°", 
                                  angle_range[1], angle_range[2]),
                   size = 3.5, fontface = "italic", color = "darkblue")

# Display plot
print(p)

# Save outputs
if (!dir.exists("../figures")) {
  dir.create("../figures")
}

cat("\nSaving figure...\n")

# Save in multiple formats
svglite::svglite("../figures/Figure_5_intact_road_moai.svg", width = 10, height = 8)
print(p)
grDevices::dev.off()

ggplot2::ggsave("../figures/Figure_5_intact_road_moai.png", p, 
                width = 10, height = 8, dpi = 600)
ggplot2::ggsave("../figures/Figure_5_intact_road_moai_preview.png", p, 
                width = 10, height = 8, dpi = 150)

grDevices::pdf("../figures/Figure_5_intact_road_moai.pdf", width = 10, height = 8)
print(p)
grDevices::dev.off()

# Save analysis data
output_data <- intact_road_moai %>%
  dplyr::select(mean_base_angle, total_length_cm, base_width_cm, 
                size_metric, Position)
utils::write.csv(output_data, "../figures/Figure_5_intact_road_moai_data.csv", 
                 row.names = FALSE)

# Save statistics summary
stats_summary <- data.frame(
  Statistic = c("Sample Size", "Correlation", "P-value",
                "Min Angle", "Max Angle", "Angle Range",
                "Size Fold Variation"),
  Value = c(nrow(intact_road_moai), correlation, p_value,
            angle_range[1], angle_range[2], diff(angle_range),
            size_fold)
)
utils::write.csv(stats_summary, "../figures/Figure_5_statistics.csv", 
                 row.names = FALSE)

cat("\n=== FIGURE 5 COMPLETED ===\n")
cat("Files saved:\n")
cat("- Figure_5_intact_road_moai.svg (vector)\n")
cat("- Figure_5_intact_road_moai.png (600 dpi)\n")
cat("- Figure_5_intact_road_moai_preview.png (150 dpi)\n")
cat("- Figure_5_intact_road_moai.pdf\n")
cat("- Figure_5_intact_road_moai_data.csv\n")
cat("- Figure_5_statistics.csv\n")

# Display individual moai if small sample
if(nrow(intact_road_moai) <= 20) {
  cat("\n=== INDIVIDUAL INTACT ROAD MOAI ===\n")
  display_data <- intact_road_moai %>%
    dplyr::select(mean_base_angle, total_length_cm, base_width_cm, Position) %>%
    dplyr::mutate(size_cm2 = total_length_cm * base_width_cm) %>%
    dplyr::arrange(mean_base_angle)
  
  print(display_data, n = 20)
}