# Initialize renv for reproducible package management (modern replacement for packrat)
# This script sets up renv for the moai walking hypothesis project
# 
# renv is the successor to packrat with better performance and features:
# - Faster package installation and restoration
# - Shared global cache to save disk space
# - Better integration with RStudio
# - Active development and support
# - Can also manage Python dependencies

# Install renv if not already installed
if (!require("renv", quietly = TRUE)) {
  install.packages("renv")
}

# Set CRAN repository
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Initialize renv for this project
cat("Initializing renv for reproducible package management...\n")
renv::init(
  # Use explicit snapshots (more control than automatic)
  settings = list(
    snapshot.type = "explicit",
    use.cache = TRUE,
    vcs.ignore = TRUE  # Add renv files to .gitignore
  )
)

# Install all required packages
required_packages <- c(
  "readxl",     # For reading Excel files
  "ggplot2",    # For creating visualizations
  "dplyr",      # For data manipulation
  "tidyr",      # For data tidying
  "svglite",    # For SVG output
  "cowplot"     # For combining plots (used in Figure 6)
)

cat("\nInstalling required packages...\n")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg)
  }
}

# Create a snapshot of the current package library
cat("\nCreating renv snapshot...\n")
renv::snapshot(prompt = FALSE)

cat("\n================================================================================\n")
cat("renv initialization complete!\n")
cat("================================================================================\n\n")
cat("The project now uses renv for package management.\n\n")
cat("Key renv commands:\n")
cat("  renv::restore()  # Restore packages from renv.lock file\n")
cat("  renv::snapshot() # Save current package state to renv.lock\n")
cat("  renv::status()   # Check synchronization status\n")
cat("  renv::update()   # Update packages to latest versions\n\n")
cat("To reproduce this environment on another machine:\n")
cat("  1. Clone the repository\n")
cat("  2. Open R in the project directory\n")
cat("  3. Run: renv::restore()\n\n")
cat("Note: renv is the modern successor to packrat with better performance.\n")