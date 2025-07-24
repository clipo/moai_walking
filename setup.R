# Setup script for The Walking Moai Hypothesis analysis
# This script checks for packrat and installs all required packages for reproducibility

# Check if we're using packrat
if (file.exists("packrat/init.R")) {
  cat("Packrat detected. Using packrat for package management.\n")
  source("packrat/init.R")
  
  # If packages are missing, restore from packrat
  tryCatch({
    packrat::restore(prompt = FALSE)
    cat("Packrat packages restored successfully.\n")
  }, error = function(e) {
    cat("Note: Could not restore from packrat snapshot. Installing packages...\n")
  })
} else {
  cat("Packrat not initialized. Run 'source(\"init_packrat.R\")' for enhanced reproducibility.\n")
  cat("Proceeding with standard package installation...\n\n")
}

# Function to check and install packages
install_if_missing <- function(packages) {
  # Get list of installed packages
  installed_packages <- installed.packages()[, "Package"]
  
  # Find packages that need to be installed
  packages_to_install <- packages[!packages %in% installed_packages]
  
  if (length(packages_to_install) > 0) {
    cat("Installing missing packages:", paste(packages_to_install, collapse = ", "), "\n")
    install.packages(packages_to_install, dependencies = TRUE)
  } else {
    cat("All required packages are already installed.\n")
  }
  
  # Verify all packages can be loaded
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      stop(paste("Failed to load package:", pkg))
    }
  }
  
  cat("All packages successfully installed and loaded!\n")
}

# List of required packages
required_packages <- c(
  "readxl",     # For reading Excel files
  "ggplot2",    # For creating visualizations
  "dplyr",      # For data manipulation
  "tidyr",      # For data tidying
  "svglite",    # For SVG output
  "geosphere",  # For geographic calculations (Figure 3)
  "purrr",      # For functional programming (Figure 3)
  "scales",     # For scale transformations (Figure 5)
  "ragg"        # For high-quality graphics (Figures 11-13)
)

# Install missing packages
install_if_missing(required_packages)

# If using packrat, take a snapshot
if (file.exists("packrat/init.R")) {
  cat("\nUpdating packrat snapshot...\n")
  packrat::snapshot(prompt = FALSE)
}

# Print R version for reproducibility
cat("\nR version information:\n")
print(R.version.string)

# Print package versions
cat("\nInstalled package versions:\n")
for (pkg in required_packages) {
  cat(sprintf("%s: %s\n", pkg, packageVersion(pkg)))
}

cat("\nSetup complete! You can now run the figure scripts.\n")