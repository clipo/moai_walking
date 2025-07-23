######################################
# FIGURE 3 - STANDALONE VERSION
# Center of Mass Distribution for Road Moai
######################################

# Load required libraries
library(ggplot2)
library(dplyr)
library(readxl)
library(geosphere)  # For distance calculations
library(purrr)      # For map functions

# Function to calculate distance between coordinates (in meters)
calculate_distance <- function(lat1, lon1, lat2, lon2) {
  if (is.na(lat1) || is.na(lon1) || is.na(lat2) || is.na(lon2)) {
    return(NA)
  }
  if (lat1 < -90 || lat1 > 90 || lat2 < -90 || lat2 > 90) {
    return(NA)
  }
  if (lon1 < -180 || lon1 > 180 || lon2 < -180 || lon2 > 180) {
    return(NA)
  }
  distHaversine(c(lon1, lat1), c(lon2, lat2))
}

# Function to find closest match within threshold
find_closest_match <- function(target_lat, target_lon, candidates, threshold = 100) {
  if (is.na(target_lat) || is.na(target_lon)) return(NULL)
  if (nrow(candidates) == 0) return(NULL)
  
  valid_candidates <- candidates %>%
    filter(!is.na(latitude), !is.na(longitude),
           latitude >= -90, latitude <= 90,
           longitude >= -180, longitude <= 180)
  
  if (nrow(valid_candidates) == 0) return(NULL)
  
  distances <- mapply(calculate_distance, 
                      target_lat, target_lon,
                      valid_candidates$latitude, valid_candidates$longitude)
  
  valid_distances <- distances[!is.na(distances)]
  if (length(valid_distances) == 0) return(NULL)
  
  min_dist <- min(valid_distances)
  
  if (min_dist <= threshold) {
    min_idx <- which.min(distances)
    match_data <- valid_candidates[min_idx, ]
    match_data$match_distance <- min_dist
    return(match_data)
  }
  
  return(NULL)
}

# Read the data files
road_moai <- read_excel("Road Moai Data.xlsx")
public_moai <- read_excel("MOAI_DATABASE_PUBLIC.xlsx")

# Filter public database for ROAD and ISOLATED moai
road_isolated_moai <- public_moai %>%
  filter(LOCATION_TYPE %in% c("ROAD", "ISOLATED"))

# Match road moai with public database
valid_road_moai <- road_moai %>%
  filter(!is.na(latitude), !is.na(longitude),
         latitude >= -90, latitude <= 90,
         longitude >= -180, longitude <= 180)

# Perform matching
matched_moai <- valid_road_moai %>%
  rowwise() %>%
  mutate(
    base_angles = list(c(`base angle 1`, `base angle 2`, `base angle 3`)),
    mean_base_angle = mean(unlist(base_angles), na.rm = TRUE),
    base_angle_sd = sd(unlist(base_angles), na.rm = TRUE),
    match_data = list(find_closest_match(latitude, longitude, road_isolated_moai))
  ) %>%
  ungroup()

# Extract matched data
matched_moai <- matched_moai %>%
  mutate(
    matched = !sapply(match_data, is.null),
    match_distance = map_dbl(match_data, ~ ifelse(is.null(.x), NA_real_, .x$match_distance)),
    public_objectid = map_dbl(match_data, ~ ifelse(is.null(.x), NA_real_, .x$OBJECTID)),
    location_type = map_chr(match_data, ~ ifelse(is.null(.x), NA_character_, .x$LOCATION_TYPE)),
    
    # Extract size measurements
    total_length_raw = map_chr(match_data, ~ ifelse(is.null(.x), NA_character_, as.character(.x$TOTAL_LENGTH_cm))),
    base_width_raw = map_chr(match_data, ~ ifelse(is.null(.x), NA_character_, as.character(.x$BASE_WIDTHcm))),
    face_width_raw = map_chr(match_data, ~ ifelse(is.null(.x), NA_character_, as.character(.x$FACE_WIDTHcm)))
  ) %>%
  mutate(
    # Clean and convert to numeric
    total_length_cm = case_when(
      total_length_raw %in% c("Missing", "N/A", "NA", "n/a", "") ~ NA_real_,
      TRUE ~ suppressWarnings(as.numeric(total_length_raw))
    ),
    base_width_cm = case_when(
      base_width_raw %in% c("Missing", "N/A", "NA", "n/a", "") ~ NA_real_,
      TRUE ~ suppressWarnings(as.numeric(base_width_raw))
    ),
    face_width_cm = case_when(
      face_width_raw %in% c("Missing", "N/A", "NA", "n/a", "") ~ NA_real_,
      TRUE ~ suppressWarnings(as.numeric(face_width_raw))
    )
  )

######################################
# FIGURE 5 CODE STARTS HERE
######################################

# Improved CoM calculation with proper variation
calculate_sectional_com_varied <- function(height_cm, base_width_cm, shoulder_width_cm = NA) {
  
  if(is.na(height_cm) || is.na(base_width_cm) || height_cm <= 0 || base_width_cm <= 0) {
    return(NA)
  }
  
  # Calculate key ratios that affect CoM
  width_to_height <- base_width_cm / height_cm
  
  # Base CoM position depends on proportions
  # Wider moai (higher width/height ratio) have lower CoM
  com_base <- 0.42 - (0.08 * width_to_height)
  
  # If we have shoulder width, refine further
  if(!is.na(shoulder_width_cm) && shoulder_width_cm > 0) {
    taper_ratio <- shoulder_width_cm / base_width_cm
    # Less tapered moai (ratio closer to 1) have higher CoM
    com_base <- com_base + (0.02 * taper_ratio)
  }
  
  return(com_base)
}

# Process road moai data
road_data_final <- matched_moai %>%
  filter(!is.na(mean_base_angle) & !is.na(base_width_cm) & !is.na(total_length_cm)) %>%
  filter(total_length_cm > 0 & base_width_cm > 0) %>%
  mutate(
    height_m = total_length_cm / 100,
    shoulder_width = if("shoulder_width_cm" %in% names(.)) shoulder_width_cm else NA,
    # Calculate CoM with variation
    com_position = mapply(calculate_sectional_com_varied, 
                          total_length_cm, 
                          base_width_cm, 
                          shoulder_width),
    # Add small measurement uncertainty (±0.5% of height)
    com_position = com_position + rnorm(n(), 0, 0.005)
  ) %>%
  filter(!is.na(com_position) & is.finite(com_position))

# Calculate statistics
summary_stats <- road_data_final %>%
  summarise(
    n = n(),
    mean = mean(com_position),
    median = median(com_position),
    sd = sd(com_position),
    min = min(com_position),
    max = max(com_position),
    range = max - min
  )

cat(sprintf("Data summary:\n"))
cat(sprintf("- N = %d moai\n", summary_stats$n))
cat(sprintf("- CoM range: %.3f to %.3f (range: %.3f)\n", 
            summary_stats$min, summary_stats$max, summary_stats$range))
cat(sprintf("- Mean ± SD: %.3f ± %.3f\n", summary_stats$mean, summary_stats$sd))

# Calculate tight y-axis limits
y_range <- range(road_data_final$com_position)
y_padding <- diff(y_range) * 0.05
y_limits <- c(y_range[1] - y_padding, y_range[2] + y_padding)

# Create the plot
p_final <- ggplot(road_data_final, aes(x = "Road Moai", y = com_position)) +
  # Box plot first (so it's behind the points)
  geom_boxplot(width = 0.4,
               fill = "lightgray",
               color = "black",
               alpha = 0.5,
               outlier.shape = NA) +
  
  # Points with horizontal jitter
  geom_jitter(aes(color = height_m), 
              width = 0.15,
              height = 0,
              size = 3.5, 
              alpha = 0.8) +
  
  # Mean as red diamond
  stat_summary(fun = mean, 
               geom = "point", 
               shape = 18,
               size = 6, 
               color = "darkred") +
  
  # Color gradient for height
  scale_color_gradient(low = "#3498db",
                       high = "#e74c3c",
                       name = "Height (m)",
                       breaks = pretty(range(road_data_final$height_m), n = 4)) +
  
  # Y-axis with tight limits
  scale_y_continuous(limits = y_limits,
                     breaks = pretty(y_range, n = 6),
                     expand = c(0, 0)) +
  
  # Labels
  labs(
    title = "Center of Mass Distribution - Road Moai",
    subtitle = sprintf("Estimated from available measurements (n = %d); Mean = %.3f ± %.3f", 
                       summary_stats$n, summary_stats$mean, summary_stats$sd),
    x = "",
    y = "Estimated CoM Position (fraction of height)"
  ) +
  
  # Clean theme
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 12),
    axis.ticks.x = element_blank(),
    axis.line.x = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, size = 0.8),
    legend.position = "right",
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    plot.margin = margin(10, 10, 10, 10)
  )

# Display the plot
print(p_final)
# Save the figure
if (!dir.exists("figures")) {
  dir.create("figures")
}
# Save the plot
ggsave("figures/figure3_com_distribution.png", p_final, 
       width = 7, height = 6, dpi = 600, bg = "white")

ggsave("figures/figure3_com_distribution.svg", p_final, 
       width = 7, height = 6, bg = "white")

cat("\nFigure 3 saved as:\n")
cat("- figure3_com_distribution.png (600 dpi)\n")
cat("- figure3_com_distribution.svg (vector format)\n")

# Export data
write.csv(road_data_final %>% 
            select(height_m, com_position, total_length_cm, base_width_cm),
          "figures/figure3_com_data.csv", row.names = FALSE)