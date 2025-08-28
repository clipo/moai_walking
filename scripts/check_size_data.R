#!/usr/bin/env Rscript
library(readxl)
library(dplyr)

# Load public database
db <- read_excel("../data/MOAI_DATABASE_PUBLIC.xlsx")

# Filter for ROAD and QUARRY NOT BEDROCK moai
road_moai <- db %>% 
  filter(LOCATION_TYPE %in% c("ROAD", "QUARRY NOT BEDROCK"))

cat("Total ROAD/QUARRY NOT BEDROCK moai:", nrow(road_moai), "\n")

# Check size data availability
with_size <- road_moai %>% 
  mutate(total_length_cm = suppressWarnings(as.numeric(TOTAL_LENGTH_cm))) %>%
  filter(!is.na(total_length_cm))

cat("With size data:", nrow(with_size), "\n")

# Check complete moai
complete <- road_moai %>% 
  filter(NUMBER_OF_FRAGMENTS == 1 | NUMBER_OF_FRAGMENTS == "1")

cat("Complete moai (n_fragments=1):", nrow(complete), "\n")

# Complete with size
complete_with_size <- complete %>% 
  mutate(total_length_cm = suppressWarnings(as.numeric(TOTAL_LENGTH_cm))) %>%
  filter(!is.na(total_length_cm))

cat("Complete moai with size:", nrow(complete_with_size), "\n")

# Check distance distribution for complete moai with size
# Calculate distances
QUARRY_LAT <- -27.125175
QUARRY_LON <- -109.288170

complete_with_dist <- complete_with_size %>%
  mutate(
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude),
    lat_diff = (latitude - QUARRY_LAT) * 111000,
    lon_diff = (longitude - QUARRY_LON) * 99000,
    distance_from_quarry_m = sqrt(lat_diff^2 + lon_diff^2),
    distance_from_quarry_km = distance_from_quarry_m / 1000
  ) %>%
  filter(!is.na(distance_from_quarry_km))

# Show distance distribution
cat("\nDistance distribution for complete moai with size:\n")
cat("0-2 km:", sum(complete_with_dist$distance_from_quarry_km <= 2), "\n")
cat("2-5 km:", sum(complete_with_dist$distance_from_quarry_km > 2 & complete_with_dist$distance_from_quarry_km <= 5), "\n")
cat("5+ km:", sum(complete_with_dist$distance_from_quarry_km > 5), "\n")

# Show max distance
cat("\nMax distance with size data:", max(complete_with_dist$distance_from_quarry_km), "km\n")

# List the distant moai
distant <- complete_with_dist %>% 
  filter(distance_from_quarry_km > 5) %>%
  select(OBJECTID, distance_from_quarry_km, total_length_cm)

if(nrow(distant) > 0) {
  cat("\nDistant complete moai (>5 km) with size:\n")
  print(distant)
}