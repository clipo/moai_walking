# Simple renv setup script for the moai walking hypothesis project

# Install renv if needed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cran.rstudio.com/")
}

# Load renv
library(renv)

# Initialize renv with default settings
cat("Initializing renv for package management...\n\n")
renv::init(bare = TRUE, restart = FALSE)

# Required packages for the project
packages <- c(
  "readxl",     # For reading Excel files
  "ggplot2",    # For creating visualizations
  "dplyr",      # For data manipulation
  "tidyr",      # For data tidying
  "svglite",    # For SVG output
  "cowplot"     # For combining plots
)

# Install packages
cat("Installing required packages...\n")
for (pkg in packages) {
  cat(sprintf("  - Installing %s...\n", pkg))
  install.packages(pkg, repos = "https://cran.rstudio.com/")
}

# Create snapshot
cat("\nCreating renv.lock file...\n")
renv::snapshot(prompt = FALSE)

cat("\n✓ renv setup complete!\n")
cat("\nTo restore this environment on another machine:\n")
cat("  1. Clone the repository\n")
cat("  2. Open R in the project directory\n")
cat("  3. Run: renv::restore()\n")