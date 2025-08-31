#!/usr/bin/env Rscript
# Figure 2: Base-to-shoulder width ratio comparison
# Using explicit package::function notation for clarity

# Load required packages (without attaching to namespace)
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "svglite")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

cat("=== FIGURE 2: BASE-TO-SHOULDER WIDTH RATIO ANALYSIS ===\n\n")

# Read the Van Tilburg data
cat("Loading Van Tilburg dataset...\n")
data <- readxl::read_excel("../data/VanTilburgData.xlsx")
cat(sprintf("Loaded %d records\n\n", nrow(data)))

# Calculate base-to-shoulder width ratio
# The Van Tilburg database uses "Width:Base" and "Width:Shoulders" columns
cat("Processing data...\n")
data <- data %>%
  dplyr::rename(
    BaseWidth = `Width:Base`,
    ShoulderWidth = `Width:Shoulders`,
    Location = Location
  ) %>%
  dplyr::mutate(ratio = BaseWidth / ShoulderWidth) %>%
  dplyr::filter(!is.na(ratio) & !is.na(Location))

# Categorize moai based on Location
# In Van Tilburg's coding system:
# Locations 1-6 = ahu sites (completed moai on platforms)
# Location 8 = roads/transport routes (moai in transport)
data <- data %>%
  dplyr::mutate(MoaiType = dplyr::case_when(
    Location >= 1 & Location <= 6 ~ "Ahu",
    Location == 8 ~ "Road",
    TRUE ~ "Other"
  )) %>%
  dplyr::filter(MoaiType %in% c("Ahu", "Road"))

# Prepare data for plotting
plot_data <- data %>%
  dplyr::mutate(MoaiType = factor(MoaiType, levels = c("Ahu", "Road")))

# Calculate statistics for each group
ahu_data <- plot_data %>% dplyr::filter(MoaiType == "Ahu")
road_data <- plot_data %>% dplyr::filter(MoaiType == "Road")

# Perform Welch's t-test
t_result <- stats::t.test(ratio ~ MoaiType, data = plot_data, var.equal = FALSE)

cat("\n=== STATISTICAL RESULTS ===\n")
cat(sprintf("Ahu Moai: n = %d, mean = %.3f ± %.3f\n", 
            nrow(ahu_data), mean(ahu_data$ratio), stats::sd(ahu_data$ratio)))
cat(sprintf("Road Moai: n = %d, mean = %.3f ± %.3f\n", 
            nrow(road_data), mean(road_data$ratio), stats::sd(road_data$ratio)))
cat(sprintf("Welch's t-test: t = %.3f, df = %.1f, p = %.3e\n\n", 
            t_result$statistic, t_result$parameter, t_result$p.value))

# Create the violin plot using ggplot2
cat("Creating figure...\n")
p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = MoaiType, y = ratio, fill = MoaiType)) +
  # Add violin plots
  ggplot2::geom_violin(alpha = 0.5, color = "black", linewidth = 0.7, 
                       scale = "width", trim = FALSE, adjust = 1.2) +
  
  # Add box plots inside violins
  ggplot2::geom_boxplot(width = 0.25, alpha = 0.8, outlier.shape = NA, 
                        fill = c("#9ECAE1", "#FC9272"), 
                        color = "black", linewidth = 0.5) +
  
  # Add individual points with jitter
  ggplot2::geom_jitter(width = 0.12, size = 1.2, alpha = 0.7, color = "black") +
  
  # Add horizontal line at y = 1
  ggplot2::geom_hline(yintercept = 1, linetype = "dashed", 
                      color = "black", linewidth = 0.7) +
  
  # Customize colors
  ggplot2::scale_fill_manual(values = c("Ahu" = "#9ECAE1", "Road" = "#FC9272")) +
  
  # Add sample sizes
  ggplot2::annotate("text", x = 1, y = 0.42, 
                   label = paste("n =", nrow(ahu_data)), size = 3.5) +
  ggplot2::annotate("text", x = 2, y = 0.42, 
                   label = paste("n =", nrow(road_data)), size = 3.5) +
  
  # Add significance bracket if significant
  {if(t_result$p.value < 0.05) {
    list(
      ggplot2::annotate("segment", x = 1.05, xend = 1.95, 
                       y = 1.48, yend = 1.48, linewidth = 0.5),
      ggplot2::annotate("segment", x = 1.05, xend = 1.05, 
                       y = 1.46, yend = 1.48, linewidth = 0.5),
      ggplot2::annotate("segment", x = 1.95, xend = 1.95, 
                       y = 1.46, yend = 1.48, linewidth = 0.5),
      ggplot2::annotate("text", x = 1.5, y = 1.5, label = "*", size = 6)
    )
  }} +
  
  # Customize axes and labels
  ggplot2::labs(
    x = "",
    y = "Base Width / Shoulder Width Ratio"
  ) +
  
  # Customize theme
  ggplot2::theme_minimal() +
  ggplot2::theme(
    legend.position = "none",
    plot.title = ggplot2::element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = ggplot2::element_text(size = 10, hjust = 0.5, face = "italic"),
    axis.title.y = ggplot2::element_text(size = 11),
    axis.text = ggplot2::element_text(size = 10),
    axis.text.x = ggplot2::element_text(size = 11),
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    panel.border = ggplot2::element_rect(color = "black", fill = NA, linewidth = 0.8),
    plot.margin = ggplot2::margin(t = 10, r = 10, b = 10, l = 10, unit = "pt")
  ) +
  
  # Set y-axis limits
  ggplot2::coord_cartesian(ylim = c(0.35, 1.65)) +
  ggplot2::scale_y_continuous(breaks = seq(0.4, 2.2, by = 0.2)) +
  
  # Customize x-axis labels
  ggplot2::scale_x_discrete(labels = c("Ahu Moai", "Road Moai"))

# Display the plot
print(p)

# Save the figure
if (!dir.exists("../figures")) {
  dir.create("../figures")
}

cat("\nSaving figure...\n")

# Save in multiple formats
# SVG format
ggplot2::ggsave("../figures/Figure_2_moai_ratio_comparison.svg", 
                plot = p, width = 8, height = 6, device = "svg")

# PNG format at 600 dpi
ggplot2::ggsave("../figures/Figure_2_moai_ratio_comparison.png", 
                plot = p, width = 8, height = 6, dpi = 600)

# Preview PNG at 150 dpi
ggplot2::ggsave("../figures/Figure_2_moai_ratio_comparison_preview.png", 
                plot = p, width = 8, height = 6, dpi = 150)

# Generate figure caption
caption_text <- paste(
  "Figure 2. Comparison of the ratio of base width to shoulder width for ahu moai (left) and road moai (right).",
  sprintf("Using measurement data of moai from Van Tilburg (1986), the figures show that the two types of moai have statistically distinctive ratios (Welch's t-test: t = %.3f, df = %.1f, p = %.3e).",
          t_result$statistic, t_result$parameter, t_result$p.value)
)

cat("\n", caption_text, "\n")

cat("\n=== FIGURE 2 COMPLETED ===\n")
cat("Files saved:\n")
cat("- Figure_2_moai_ratio_comparison.svg (vector format)\n")
cat("- Figure_2_moai_ratio_comparison.png (600 dpi)\n")
cat("- Figure_2_moai_ratio_comparison_preview.png (150 dpi)\n")