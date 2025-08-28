#!/usr/bin/env Rscript
# Run all figure generation scripts
# This script tests that all figures can be produced successfully

cat("=====================================\n")
cat("RUNNING ALL FIGURE GENERATION SCRIPTS\n")
cat("=====================================\n\n")

# Track success/failure
results <- list()
start_time <- Sys.time()

# Function to safely run a script
run_script <- function(script_name, description) {
  cat(sprintf("\n--- %s ---\n", description))
  cat(sprintf("Running %s...\n", script_name))
  
  tryCatch({
    source(script_name, local = TRUE, echo = FALSE)
    cat(sprintf("✓ %s completed successfully\n", script_name))
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ ERROR in %s: %s\n", script_name, e$message))
    return(FALSE)
  })
}

# Set working directory to scripts folder
if (!grepl("/scripts$", getwd())) {
  if (file.exists("scripts")) {
    setwd("scripts")
  }
}

# Ensure data exists
if (!file.exists("../data/moai_with_distances.csv")) {
  cat("\nGenerating distance datasets first...\n")
  results[["data"]] <- run_script("create_distance_dataset.R", 
                                  "Creating Distance Datasets")
}

# Run all figure scripts
figures <- list(
  Figure_2 = "Figure_2.R",
  Figure_3 = "Figure_3.R", 
  Figure_5 = "Figure_5.R",
  Figure_11 = "Figure_11.R",
  Figure_12 = "Figure_12.R",
  Figure_13 = "Figure_13.R"
)

for (fig_name in names(figures)) {
  results[[fig_name]] <- run_script(figures[[fig_name]], 
                                    sprintf("Generating %s", fig_name))
}

# Summary
cat("\n\n=====================================\n")
cat("SUMMARY OF RESULTS\n")
cat("=====================================\n")

success_count <- sum(unlist(results))
total_count <- length(results)

for (name in names(results)) {
  status <- ifelse(results[[name]], "✓ Success", "✗ Failed")
  cat(sprintf("%-15s: %s\n", name, status))
}

cat(sprintf("\nTotal: %d/%d successful\n", success_count, total_count))

# Time taken
end_time <- Sys.time()
time_taken <- difftime(end_time, start_time, units = "secs")
cat(sprintf("Time taken: %.1f seconds\n", time_taken))

# Check output files
cat("\n=====================================\n")
cat("CHECKING OUTPUT FILES\n")
cat("=====================================\n")

expected_outputs <- c(
  "Figure_2_moai_ratio_comparison.png",
  "Figure_3_com_distribution.png",
  "Figure_5_intact_road_moai.png",
  "Figure_11_transport_failure_expectation.png",
  "Figure_12_distribution_analysis.png",
  "Figure_13_size_analysis.png"
)

cat("\nChecking for expected output files in ../figures/:\n")
for (file in expected_outputs) {
  path <- file.path("../figures", file)
  exists <- file.exists(path)
  status <- ifelse(exists, "✓", "✗")
  cat(sprintf("%s %s\n", status, file))
}

# Final status
if (success_count == total_count) {
  cat("\n✓ ALL FIGURES GENERATED SUCCESSFULLY!\n")
  quit(status = 0)
} else {
  cat(sprintf("\n✗ %d FIGURES FAILED TO GENERATE\n", total_count - success_count))
  cat("Please check the error messages above.\n")
  quit(status = 1)
}