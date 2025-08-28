#!/usr/bin/env Rscript
# Test environment and package availability
# Verifies that all required packages are installed and can be loaded

cat("=====================================\n")
cat("TESTING R ENVIRONMENT\n")
cat("=====================================\n\n")

# R version
cat("R VERSION:\n")
print(R.version.string)
cat("\n")

# Required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "svglite")

cat("CHECKING REQUIRED PACKAGES:\n")
cat("----------------------------\n")

all_available <- TRUE

for (pkg in required_packages) {
  # Check if package is installed
  installed <- requireNamespace(pkg, quietly = TRUE)
  
  if (installed) {
    # Get version
    version <- packageVersion(pkg)
    cat(sprintf("✓ %-12s: %s\n", pkg, version))
  } else {
    cat(sprintf("✗ %-12s: NOT INSTALLED\n", pkg))
    all_available <- FALSE
  }
}

# Check for optional packages used in some scripts
cat("\nOPTIONAL PACKAGES:\n")
cat("------------------\n")
optional_packages <- c("gridExtra")

for (pkg in optional_packages) {
  installed <- requireNamespace(pkg, quietly = TRUE)
  if (installed) {
    version <- packageVersion(pkg)
    cat(sprintf("✓ %-12s: %s\n", pkg, version))
  } else {
    cat(sprintf("✗ %-12s: NOT INSTALLED (optional)\n", pkg))
  }
}

# Check packrat status
cat("\nPACKRAT STATUS:\n")
cat("---------------\n")
if (file.exists("../packrat/init.R")) {
  cat("✓ Packrat initialized\n")
  if (requireNamespace("packrat", quietly = TRUE)) {
    cat(sprintf("  Packrat version: %s\n", packageVersion("packrat")))
    # Check if we're using packrat libs
    lib_paths <- .libPaths()
    if (any(grepl("packrat", lib_paths))) {
      cat("  ✓ Using packrat library\n")
    } else {
      cat("  ✗ Not using packrat library\n")
    }
  }
} else {
  cat("✗ Packrat not initialized\n")
  cat("  Run: source('init_packrat.R') to initialize\n")
}

# Check data files
cat("\nDATA FILES:\n")
cat("-----------\n")
data_files <- c(
  "VanTilburgData.xlsx",
  "Road Moai Data.xlsx",
  "MOAI_DATABASE_PUBLIC.xlsx",
  "all_moai_combined.csv",
  "moai_with_distances.csv",
  "road_moai_distances.csv"
)

data_dir <- "../data"
for (file in data_files) {
  path <- file.path(data_dir, file)
  exists <- file.exists(path)
  status <- ifelse(exists, "✓", "✗")
  
  if (exists) {
    size <- file.info(path)$size / 1024  # KB
    cat(sprintf("%s %-30s (%.1f KB)\n", status, file, size))
  } else {
    cat(sprintf("%s %-30s\n", status, file))
  }
}

# Check if distance datasets need to be created
if (!file.exists(file.path(data_dir, "moai_with_distances.csv"))) {
  cat("\n⚠ Distance datasets not found.\n")
  cat("  Run: Rscript create_distance_dataset.R\n")
}

# Check output directory
cat("\nOUTPUT DIRECTORY:\n")
cat("-----------------\n")
if (dir.exists("../figures")) {
  n_files <- length(list.files("../figures"))
  cat(sprintf("✓ figures/ directory exists (%d files)\n", n_files))
} else {
  cat("✗ figures/ directory does not exist\n")
}

# Summary
cat("\n=====================================\n")
cat("SUMMARY\n")
cat("=====================================\n")

if (all_available) {
  cat("✓ All required packages are available\n")
} else {
  cat("✗ Some required packages are missing\n")
  cat("\nTo install missing packages, run:\n")
  cat("  source('setup.R')\n")
  cat("\nOr install individually:\n")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cat(sprintf("  install.packages('%s')\n", pkg))
    }
  }
}

# Test that we can load packages
cat("\nTESTING PACKAGE LOADING:\n")
cat("------------------------\n")
can_load_all <- TRUE

for (pkg in required_packages) {
  tryCatch({
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    cat(sprintf("✓ %s loads successfully\n", pkg))
  }, error = function(e) {
    cat(sprintf("✗ Error loading %s: %s\n", pkg, e$message))
    can_load_all <- FALSE
  })
}

if (can_load_all && all_available) {
  cat("\n✓ ENVIRONMENT IS READY FOR ANALYSIS\n")
} else {
  cat("\n✗ ENVIRONMENT NEEDS SETUP\n")
}