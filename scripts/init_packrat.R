# Initialize packrat for reproducible package management
# This script sets up packrat for the moai walking hypothesis project

# Install packrat if not already installed
if (!require("packrat", quietly = TRUE)) {
  install.packages("packrat")
}

# Set CRAN repository
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Initialize packrat for this project
packrat::init(options = list(
  # Don't use packrat for base R packages
  external.packages = c(),
  
  # Automatically snapshot after installing packages
  auto.snapshot = TRUE,
  
  # Use cache for faster installs
  use.cache = TRUE
))

# Install all required packages
required_packages <- c(
  "readxl",     # For reading Excel files
  "ggplot2",    # For creating visualizations
  "dplyr",      # For data manipulation
  "tidyr",      # For data tidying
  "svglite"     # For SVG output
)

cat("Installing required packages into packrat library...\n")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg)
  }
}

# Take a snapshot of the current package library
cat("\nCreating packrat snapshot...\n")
packrat::snapshot()

cat("\nPackrat initialization complete!\n")
cat("The project now uses a private package library.\n")
cat("To restore this environment on another machine, run:\n")
cat("  packrat::restore()\n")