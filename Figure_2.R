# Load required libraries
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(svglite)  # For SVG output

# Read the Van Tilburg data
data <- read_excel("VanTilburgData.xlsx")

# Calculate base-to-shoulder width ratio
# The Van Tilburg database uses "Width:Base" and "Width:Shoulders" columns
data <- data %>%
  rename(
    BaseWidth = `Width:Base`,
    ShoulderWidth = `Width:Shoulders`,
    Location = Location
  ) %>%
  mutate(ratio = BaseWidth / ShoulderWidth) %>%
  filter(!is.na(ratio) & !is.na(Location))

# Categorize moai based on Location
# In Van Tilburg's coding system:
# Locations 1-6 = ahu sites (completed moai on platforms)
# Location 8 = roads/transport routes (moai in transport)
data <- data %>%
  mutate(MoaiType = case_when(
    Location >= 1 & Location <= 6 ~ "Ahu",
    Location == 8 ~ "Road",
    TRUE ~ "Other"
  )) %>%
  filter(MoaiType %in% c("Ahu", "Road"))

# Prepare data for plotting
plot_data <- data %>%
  mutate(MoaiType = factor(MoaiType, levels = c("Ahu", "Road")))

# Calculate statistics for each group
ahu_data <- plot_data %>% filter(MoaiType == "Ahu")
road_data <- plot_data %>% filter(MoaiType == "Road")

# Perform Welch's t-test
t_result <- t.test(ratio ~ MoaiType, data = plot_data, var.equal = FALSE)

# Create the violin plot
p <- ggplot(plot_data, aes(x = MoaiType, y = ratio, fill = MoaiType)) +
  # Add violin plots (trim=FALSE ensures full violin shape, adjust bandwidth for smoother curves)
  geom_violin(alpha = 0.5, color = "black", linewidth = 0.7, scale = "width", 
              trim = FALSE, adjust = 1.2) +
  
  # Add box plots inside violins
  geom_boxplot(width = 0.25, alpha = 0.8, outlier.shape = NA, 
               fill = c("#9ECAE1", "#FC9272"), color = "black", linewidth = 0.5) +
  
  # Add individual points with jitter
  geom_jitter(width = 0.12, size = 1.2, alpha = 0.7, color = "black") +
  
  # Add horizontal line at y = 1
  geom_hline(yintercept = 1, linetype = "dashed", color = "black", linewidth = 0.7) +
  
  # Add design labels
  #annotate("text", x = 0.55, y = 1.015, label = "Transport Design", 
  #         color = "#E41A1C", size = 3.2, hjust = 0, fontface = "bold") +
  #annotate("text", x = 1.0, y = 0.985, label = "Display Design", 
  #         color = "#377EB8", size = 3.2, hjust = 0, fontface = "bold") +
  
  # Customize colors
  scale_fill_manual(values = c("Ahu" = "#9ECAE1", "Road" = "#FC9272")) +
  
  # Add sample sizes
  annotate("text", x = 1, y = 0.42, 
           label = paste("n =", nrow(ahu_data)), size = 3.5) +
  annotate("text", x = 2, y = 0.42, 
           label = paste("n =", nrow(road_data)), size = 3.5) +
  
  # Add significance bracket if significant
  {if(t_result$p.value < 0.05) {
    list(
      annotate("segment", x = 1.05, xend = 1.95, y = 1.48, yend = 1.48, linewidth = 0.5),
      annotate("segment", x = 1.05, xend = 1.05, y = 1.46, yend = 1.48, linewidth = 0.5),
      annotate("segment", x = 1.95, xend = 1.95, y = 1.46, yend = 1.48, linewidth = 0.5),
      annotate("text", x = 1.5, y = 1.5, label = "*", size = 6)
    )
  }} +
  
  # Customize axes and labels
  labs(
    x = "",
    y = "Base Width / Shoulder Width Ratio"
    #title = "Direct Measurements: Base-to-Shoulder Width Ratios"
  ) +
  
  # Customize theme
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, face = "italic"),
    axis.title.y = element_text(size = 11),
    axis.text = element_text(size = 10),
    axis.text.x = element_text(size = 11),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10, unit = "pt")
  ) +
  
  # Set y-axis limits using coord_cartesian to avoid clipping violins
  # Extend slightly beyond visible range to accommodate full violin shapes
  coord_cartesian(ylim = c(0.35, 1.65)) +
  scale_y_continuous(breaks = seq(0.4, 2.2, by = 0.2)) +
  
  # Customize x-axis labels
  scale_x_discrete(labels = c("Ahu Moai", "Road Moai"))

# Display the plot
print(p)

# Print statistical results
cat("\nStatistical Results:\n")
cat(sprintf("Welch's t-test: t = %.3f, df = %.1f, p = %.3e\n", 
            t_result$statistic, t_result$parameter, t_result$p.value))
cat(sprintf("Ahu Moai: mean ratio = %.3f ± %.3f (n = %d)\n", 
            mean(ahu_data$ratio), sd(ahu_data$ratio), nrow(ahu_data)))
cat(sprintf("Road Moai: mean ratio = %.3f ± %.3f (n = %d)\n", 
            mean(road_data$ratio), sd(road_data$ratio), nrow(road_data)))

# Add figure caption information
caption_text <- paste(
  "Figure 2. Comparison of the ratio of base width to shoulder width for ahu moai (left) and road moai (right).",
  sprintf("Using measurement data of moai from Van Tilburg (1986), the figures show that the two types of moai have statistically distinctive ratios (Welch's t-test: t = %.3f, df = %.1f, p = %.3e).",
          t_result$statistic, t_result$parameter, t_result$p.value)
)

cat("\n\n", caption_text, "\n")

# Save the figure
if (!dir.exists("figures")) {
  dir.create("figures")
}

# Save the plot in multiple formats
# SVG format
ggsave("figures/Figure_2_moai_ratio_comparison.svg", 
       plot = p, 
       width = 8, 
       height = 6, 
       device = "svg")

# PNG format at 600 dpi
ggsave("figures/Figure_2_moai_ratio_comparison.png", 
       plot = p, 
       width = 8, 
       height = 6, 
       dpi = 600)

# Also save a standard resolution PNG for quick viewing
ggsave("figures/Figure_2_moai_ratio_comparison_preview.png", 
       plot = p, 
       width = 8, 
       height = 6, 
       dpi = 150)

cat("\nFigure saved as:\n")
cat("- Figure_2_moai_ratio_comparison.svg (vector format)\n")
cat("- Figure_2_moai_ratio_comparison.png (600 dpi)\n")
cat("- Figure_2_moai_ratio_comparison_preview.png (150 dpi for preview)\n")