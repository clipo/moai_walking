# Package loader helper function
# This file provides a function to ensure all required packages are loaded

load_required_packages <- function() {
  # List of required packages
  required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "svglite")
  
  # Function to check and install a package
  check_and_load <- function(pkg) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(paste("Package", pkg, "not found. Installing...\n"))
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
  
  # Check and load each package
  invisible(sapply(required_packages, check_and_load))
  
  # Suppress startup messages
  suppressPackageStartupMessages({
    library(readxl)
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(svglite)
  })
}