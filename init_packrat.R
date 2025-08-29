# Initialize packrat for reproducible package management
# Run this script from the project root directory

# Install packrat if not already installed
if (!require("packrat", quietly = TRUE)) {
  install.packages("packrat")
  library(packrat)
}

# Set CRAN repository before initialization
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Initialize packrat with basic settings
cat("Initializing packrat for the moai walking hypothesis project...\n")

# Simple initialization without problematic options
packrat::init()

# Install all required packages
cat("\nInstalling required packages...\n")
required_packages <- c(
  "readxl",     # For reading Excel files
  "ggplot2",    # For creating visualizations
  "dplyr",      # For data manipulation
  "tidyr",      # For data tidying
  "svglite"     # For SVG output
)

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  } else {
    cat(sprintf("%s already installed.\n", pkg))
  }
}

# Take a snapshot of the current package library
cat("\nCreating packrat snapshot...\n")
packrat::snapshot(prompt = FALSE)

cat("\n=== Packrat initialization complete! ===\n")
cat("The project now uses a private package library.\n")
cat("All required packages have been installed.\n\n")
cat("To use this project on another machine:\n")
cat("1. Copy the entire project folder including packrat/\n")
cat("2. Open R in the project directory\n")
cat("3. Run: packrat::restore()\n\n")
cat("You can now run scripts from the scripts/ folder.\n")