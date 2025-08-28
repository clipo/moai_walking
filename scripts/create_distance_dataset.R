#!/usr/bin/env Rscript
# Create dataset with Distance from Quarry for moai
# This generates a reusable dataset for Figures 11, 12, and 13

library(dplyr)
library(readxl)
library(tidyr)

cat("=== CREATING MOAI DISTANCE DATASET ===\n\n")

# Rano Raraku quarry coordinates
# Using geocentroid of all bedrock quarry moai (318 moai)
# This represents the actual center of quarrying activity
QUARRY_LAT <- -27.125175  # Geocentroid of QUARRY and QUARRY-BEDROCK moai
QUARRY_LON <- -109.288170  # Calculated from MOAI_DATABASE_PUBLIC.xlsx

cat("Quarry location (Rano Raraku geocentroid):\n")
cat("  Based on 318 bedrock quarry moai\n")
cat(sprintf("  Latitude: %.6f\n", QUARRY_LAT))
cat(sprintf("  Longitude: %.6f\n\n", QUARRY_LON))

# Function to calculate distance from quarry
calculate_distance_from_quarry <- function(lat, lon) {
  if (is.na(lat) || is.na(lon)) {
    return(NA)
  }
  
  # Simple Euclidean approximation for Easter Island's small area
  # At -27° latitude: 1° lat ≈ 111 km, 1° lon ≈ 99 km
  lat_diff <- (lat - QUARRY_LAT) * 111000  # meters
  lon_diff <- (lon - QUARRY_LON) * 99000   # meters
  
  distance <- sqrt(lat_diff^2 + lon_diff^2)
  return(distance)
}

# Load the combined moai dataset
cat("Loading all_moai_combined.csv...\n")
moai_data <- read.csv("../data/all_moai_combined.csv")
cat(sprintf("Loaded %d moai records\n\n", nrow(moai_data)))

# Calculate distance from quarry for each moai
cat("Calculating distances from quarry...\n")
moai_with_distances <- moai_data %>%
  mutate(
    # Calculate distance in meters
    distance_from_quarry_m = mapply(calculate_distance_from_quarry, latitude, longitude),
    # Convert to kilometers
    distance_from_quarry_km = distance_from_quarry_m / 1000,
    # Round for cleaner display
    distance_from_quarry_m = round(distance_from_quarry_m, 1),
    distance_from_quarry_km = round(distance_from_quarry_km, 3)
  )

# Summary statistics by location type
cat("\n=== DISTANCE STATISTICS BY LOCATION TYPE ===\n")
distance_summary <- moai_with_distances %>%
  filter(!is.na(distance_from_quarry_km)) %>%
  group_by(location_type) %>%
  summarise(
    count = n(),
    min_km = min(distance_from_quarry_km, na.rm = TRUE),
    mean_km = mean(distance_from_quarry_km, na.rm = TRUE),
    median_km = median(distance_from_quarry_km, na.rm = TRUE),
    max_km = max(distance_from_quarry_km, na.rm = TRUE),
    within_2km = sum(distance_from_quarry_km <= 2, na.rm = TRUE),
    pct_within_2km = 100 * within_2km / count
  ) %>%
  arrange(median_km)

print(distance_summary)

# First, get road moai from the combined dataset
road_moai_from_combined <- moai_with_distances %>%
  filter(location_type == "ROAD") %>%
  filter(!is.na(distance_from_quarry_km))

# Use ONLY the public database for consistency and completeness
cat("\nLoading moai from MOAI_DATABASE_PUBLIC.xlsx...\n")
public_db <- readxl::read_excel("../data/MOAI_DATABASE_PUBLIC.xlsx")

# Get all ROAD moai from public database
road_moai <- public_db %>%
  filter(LOCATION_TYPE == "ROAD") %>%
  mutate(
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude)
  ) %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  mutate(
    # Calculate distance in meters
    distance_from_quarry_m = mapply(calculate_distance_from_quarry, latitude, longitude),
    # Convert to kilometers
    distance_from_quarry_km = distance_from_quarry_m / 1000,
    # Round for cleaner display
    distance_from_quarry_m = round(distance_from_quarry_m, 1),
    distance_from_quarry_km = round(distance_from_quarry_km, 3),
    location_type = "ROAD"
  )

cat(sprintf("ROAD type moai: %d\n", nrow(road_moai)))

# Also get "QUARRY NOT BEDROCK" moai - these are fully carved but never transported
quarry_not_bedrock <- public_db %>%
  filter(LOCATION_TYPE == "QUARRY NOT BEDROCK") %>%
  mutate(
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude)
  ) %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  mutate(
    # Calculate distance in meters
    distance_from_quarry_m = mapply(calculate_distance_from_quarry, latitude, longitude),
    # Convert to kilometers
    distance_from_quarry_km = distance_from_quarry_m / 1000,
    # Round for cleaner display
    distance_from_quarry_m = round(distance_from_quarry_m, 1),
    distance_from_quarry_km = round(distance_from_quarry_km, 3),
    location_type = "QUARRY_FAILED"  # Mark as immediate transport failures
  )

cat(sprintf("QUARRY NOT BEDROCK moai (immediate failures): %d\n", nrow(quarry_not_bedrock)))

# Additional road moai identified from map review
additional_road_ids <- c(450, 524, 449, 448, 677, 873, 908, 874, 483, 871, 872, 
                         907, 906, 903, 464, 751, 481, 359, 358, 675, 676, 472, 
                         558, 522, 674, 219, 417, 678, 777, 508, 712, 713, 575)

cat(sprintf("\nAdding %d additional road moai identified from map review\n", 
            length(additional_road_ids)))

# Get these additional moai from the database
additional_road <- public_db %>%
  filter(OBJECTID %in% additional_road_ids) %>%
  mutate(
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude)
  ) %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  mutate(
    # Calculate distance in meters
    distance_from_quarry_m = mapply(calculate_distance_from_quarry, latitude, longitude),
    # Convert to kilometers
    distance_from_quarry_km = distance_from_quarry_m / 1000,
    # Round for cleaner display
    distance_from_quarry_m = round(distance_from_quarry_m, 1),
    distance_from_quarry_km = round(distance_from_quarry_km, 3),
    location_type = "ROAD_ADDITIONAL"  # Mark as additional road moai
  )

cat(sprintf("Found %d of these in database with coordinates\n", nrow(additional_road)))

# Combine all three types - these represent all transport attempts
all_transport_attempts <- bind_rows(road_moai, quarry_not_bedrock, additional_road) %>%
  # Select relevant columns
  select(latitude, longitude, distance_from_quarry_km, distance_from_quarry_m, location_type) %>%
  # Remove any exact duplicates (some IDs might be in multiple categories)
  distinct(latitude, longitude, .keep_all = TRUE) %>%
  # Sort by distance from quarry
  arrange(distance_from_quarry_km)

# Also save just the traditional road moai for backward compatibility
road_moai_original <- all_transport_attempts %>%
  filter(location_type == "ROAD")

# Create expanded road moai dataset (includes additional identified road moai)
road_moai <- all_transport_attempts %>%
  filter(location_type %in% c("ROAD", "ROAD_ADDITIONAL"))

cat(sprintf("\nTotal transport attempts: %d\n", nrow(all_transport_attempts)))
cat(sprintf("  - Original ROAD moai: %d\n", sum(all_transport_attempts$location_type == "ROAD")))
cat(sprintf("  - Additional road moai: %d\n", sum(all_transport_attempts$location_type == "ROAD_ADDITIONAL")))
cat(sprintf("  - Quarry failures: %d\n", sum(all_transport_attempts$location_type == "QUARRY_FAILED")))

cat(sprintf("\n=== ROAD MOAI DISTANCE ANALYSIS ===\n"))
cat(sprintf("Total road moai with distances: %d\n", nrow(road_moai)))

if(nrow(road_moai) > 0) {
  # Calculate quartiles
  quartiles <- quantile(road_moai$distance_from_quarry_km, probs = c(0.25, 0.5, 0.75))
  
  cat(sprintf("\nDistance distribution:\n"))
  cat(sprintf("  Min: %.2f km\n", min(road_moai$distance_from_quarry_km)))
  cat(sprintf("  Q1 (25%%): %.2f km\n", quartiles[1]))
  cat(sprintf("  Median (50%%): %.2f km\n", quartiles[2]))
  cat(sprintf("  Q3 (75%%): %.2f km\n", quartiles[3]))
  cat(sprintf("  Max: %.2f km\n", max(road_moai$distance_from_quarry_km)))
  
  # Calculate percentage within different ranges
  ranges <- c(1, 2, 3, 5, 10)
  cat(sprintf("\nPercentage within distance ranges:\n"))
  for(r in ranges) {
    pct <- 100 * sum(road_moai$distance_from_quarry_km <= r) / nrow(road_moai)
    cat(sprintf("  Within %d km: %.1f%%\n", r, pct))
  }
  
  # Check for transport failure pattern
  within_2km <- sum(road_moai$distance_from_quarry_km <= 2)
  pct_within_2km <- 100 * within_2km / nrow(road_moai)
  
  cat(sprintf("\n=== KEY FINDING ===\n"))
  cat(sprintf("%.1f%% of road moai are within 2 km of the quarry\n", pct_within_2km))
  
  if(pct_within_2km > 40) {
    cat("This concentration near the quarry supports the transport failure hypothesis.\n")
  }
}

# Create dataset specifically for intact road moai
intact_road_moai <- moai_with_distances %>%
  filter(location_type == "ROAD") %>%
  filter(`n.of.pieces` == "1" | `n.of.pieces` == 1) %>%
  filter(!is.na(distance_from_quarry_km))

cat(sprintf("\nIntact road moai (1 piece): %d\n", nrow(intact_road_moai)))

# Save the complete dataset with distances
output_file <- "../data/moai_with_distances.csv"
write.csv(moai_with_distances, output_file, row.names = FALSE)
cat(sprintf("\n=== DATASET SAVED ===\n"))
cat(sprintf("Saved to: %s\n", output_file))
cat(sprintf("Total records: %d\n", nrow(moai_with_distances)))
cat(sprintf("Records with valid distances: %d\n", sum(!is.na(moai_with_distances$distance_from_quarry_km))))

# Save the traditional road moai dataset
road_output <- "../data/road_moai_distances.csv"
write.csv(road_moai, road_output, row.names = FALSE)
cat(sprintf("\nRoad moai dataset saved to: %s\n", road_output))
cat(sprintf("Road moai records: %d\n", nrow(road_moai)))

# Display summary of all transport attempts (not saved to file)
cat(sprintf("\nTotal transport attempts analyzed: %d\n", nrow(all_transport_attempts)))
cat("(Includes ROAD moai + QUARRY NOT BEDROCK immediate failures)\n")

# Summary for transport failure model (Figure 11)
cat("\n=== TRANSPORT FAILURE MODEL DATA ===\n")
cat("Analysis with ALL transport attempts (including quarry failures):\n")

# Calculate observed counts by distance zones for ALL transport attempts
zones_all <- data.frame(
  zone = c("0-1km", "1-2km", "2-3km", "3-4km", "4-5km", "5-6km", "6-8km", "8-10km", "10+km"),
  min_km = c(0, 1, 2, 3, 4, 5, 6, 8, 10),
  max_km = c(1, 2, 3, 4, 5, 6, 8, 10, Inf)
)

for(i in 1:nrow(zones_all)) {
  count <- sum(all_transport_attempts$distance_from_quarry_km >= zones_all$min_km[i] & 
               all_transport_attempts$distance_from_quarry_km < zones_all$max_km[i])
  zones_all$observed_count[i] <- count
  zones_all$observed_pct[i] <- 100 * count / nrow(all_transport_attempts)
}

print(zones_all)

# Calculate key statistics
within_1km <- sum(all_transport_attempts$distance_from_quarry_km < 1)
within_2km <- sum(all_transport_attempts$distance_from_quarry_km < 2)
cat(sprintf("\nKEY STATISTICS (all transport attempts):\n"))
cat(sprintf("  Within 1 km: %d moai (%.1f%%)\n", within_1km, 100*within_1km/nrow(all_transport_attempts)))
cat(sprintf("  Within 2 km: %d moai (%.1f%%)\n", within_2km, 100*within_2km/nrow(all_transport_attempts)))
cat(sprintf("  1-1.5 km range: %d moai\n", 
    sum(all_transport_attempts$distance_from_quarry_km >= 1 & 
        all_transport_attempts$distance_from_quarry_km < 1.5)))

# Save traditional road-only zones for Figure 12
zones <- data.frame(
  zone = c("0-2km", "2-4km", "4-6km", "6-8km", "8-10km", "10+km"),
  min_km = c(0, 2, 4, 6, 8, 10),
  max_km = c(2, 4, 6, 8, 10, Inf)
)

for(i in 1:nrow(zones)) {
  count <- sum(road_moai$distance_from_quarry_km >= zones$min_km[i] & 
               road_moai$distance_from_quarry_km < zones$max_km[i])
  zones$observed_count[i] <- count
  zones$observed_pct[i] <- 100 * count / nrow(road_moai)
}

zone_output <- "../data/road_moai_zones.csv"
write.csv(zones, zone_output, row.names = FALSE)
cat(sprintf("Traditional road zones saved to: %s\n", zone_output))

cat("\n=== DATASETS CREATED SUCCESSFULLY ===\n")
cat("\nFiles created in data/ directory:\n")
cat("1. moai_with_distances.csv - Complete dataset with distance calculations\n")
cat("2. road_moai_distances.csv - Road moai subset for analysis\n")
cat("3. road_moai_histogram.csv - Pre-computed histogram data\n")
cat("4. road_moai_zones.csv - Distance zone analysis\n")
cat("\nThese datasets can now be used by Figures 11, 12, and 13\n")
cat("eliminating the need for random data generation.\n")