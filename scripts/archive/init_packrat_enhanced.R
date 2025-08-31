# Enhanced packrat initialization script for the Moai Walking Hypothesis project
# This ensures reproducible package management
# Run from the project root: Rscript scripts/init_packrat_enhanced.R

# Function to safely install and load packages
safe_install <- function(pkg, repos = "https://cran.rstudio.com/") {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg, repos = repos, quiet = TRUE)
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

# Set working directory to project root
if (basename(getwd()) == "scripts") {
  setwd("..")
}

cat("========================================\n")
cat("Moai Walking Hypothesis Project\n")
cat("Packrat Setup for Reproducibility\n")
cat("========================================\n\n")

# Step 1: Install packrat if needed
cat("Step 1: Checking packrat installation...\n")
if (!requireNamespace("packrat", quietly = TRUE)) {
  cat("Installing packrat...\n")
  install.packages("packrat", repos = "https://cran.rstudio.com/", quiet = TRUE)
} else {
  cat("Packrat is already installed.\n")
}

# Step 2: Check if packrat is already initialized
cat("\nStep 2: Checking packrat status...\n")
if (file.exists("packrat/packrat.lock")) {
  cat("Packrat is already initialized.\n")
  cat("To restore packages, run: packrat::restore()\n")
  cat("To update snapshot, run: packrat::snapshot()\n")
} else {
  cat("Initializing packrat...\n")
  
  # Initialize packrat
  packrat::init(
    options = list(
      use.cache = TRUE,
      print.banner.on.startup = "auto",
      vcs.ignore.lib = TRUE,
      vcs.ignore.src = TRUE
    )
  )
  
  cat("\nPackrat initialized successfully!\n")
}

# Step 3: Install required packages
cat("\nStep 3: Installing required packages...\n")
required_packages <- c(
  "readxl",     # Reading Excel files
  "ggplot2",    # Creating visualizations
  "dplyr",      # Data manipulation
  "tidyr",      # Data tidying
  "svglite",    # SVG output
  "gridExtra"   # Arranging plots (optional but useful)
)

for (pkg in required_packages) {
  safe_install(pkg)
  cat(sprintf("✓ %s installed and loaded\n", pkg))
}

# Step 4: Take a snapshot
cat("\nStep 4: Creating packrat snapshot...\n")
packrat::snapshot(prompt = FALSE)
cat("Snapshot created successfully!\n")

# Step 5: Verify installation
cat("\nStep 5: Verifying installation...\n")
all_installed <- all(sapply(required_packages, requireNamespace, quietly = TRUE))

if (all_installed) {
  cat("\n✓ All packages successfully installed!\n")
  
  # Show package versions
  cat("\nInstalled package versions:\n")
  cat("----------------------------\n")
  for (pkg in required_packages) {
    version <- as.character(packageVersion(pkg))
    cat(sprintf("  %s: %s\n", pkg, version))
  }
  
  cat("\n========================================\n")
  cat("Setup complete! You can now run:\n")
  cat("  cd scripts\n")
  cat("  Rscript create_distance_dataset.R\n")
  cat("  Rscript run_all_figures.R\n")
  cat("========================================\n")
} else {
  cat("\n⚠ Some packages may not have installed correctly.\n")
  cat("Please check the messages above for errors.\n")
}

# Step 6: Create .Rprofile if it doesn't exist
if (!file.exists(".Rprofile")) {
  cat("\nCreating .Rprofile to auto-load packrat...\n")
  writeLines("#### -- Packrat Autoloader (version 0.7.0) -- ####
source(\"packrat/init.R\")
#### -- End Packrat Autoloader -- ####", ".Rprofile")
}

cat("\nPackrat setup is complete!\n")
cat("The project now uses a private package library.\n")
cat("\nFor other users to reproduce this environment:\n")
cat("1. Clone the repository\n")
cat("2. Open R in the project directory\n") 
cat("3. Run: packrat::restore()\n\n")