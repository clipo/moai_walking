#!/usr/bin/env Rscript
# Template R Script - Demonstrating Clean Code Style
# This template shows the recommended coding style for the project

# =============================================================================
# SETUP
# =============================================================================

# Define required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "svglite")

# Check and install packages without attaching them
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg, dependencies = TRUE)
  }
}

# =============================================================================
# FUNCTIONS
# =============================================================================

#' Load and validate data
#' @param filepath Path to data file
#' @return Validated dataframe
load_moai_data <- function(filepath) {
  # Check file exists
  if (!file.exists(filepath)) {
    stop(sprintf("Data file not found: %s", filepath))
  }
  
  # Load based on extension
  ext <- tools::file_ext(filepath)
  
  data <- switch(ext,
    "csv" = utils::read.csv(filepath),
    "xlsx" = readxl::read_excel(filepath),
    stop(sprintf("Unsupported file type: %s", ext))
  )
  
  return(data)
}

#' Calculate summary statistics
#' @param data Dataframe with numeric columns
#' @param group_var Grouping variable (optional)
#' @return Summary statistics dataframe
calculate_summary <- function(data, group_var = NULL) {
  if (!is.null(group_var)) {
    summary_stats <- data %>%
      dplyr::group_by(!!rlang::sym(group_var)) %>%
      dplyr::summarise(
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        sd = stats::sd(value, na.rm = TRUE),
        median = stats::median(value, na.rm = TRUE),
        .groups = 'drop'
      )
  } else {
    summary_stats <- data %>%
      dplyr::summarise(
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        sd = stats::sd(value, na.rm = TRUE),
        median = stats::median(value, na.rm = TRUE)
      )
  }
  
  return(summary_stats)
}

#' Create and save a figure in multiple formats
#' @param plot ggplot object
#' @param filename Base filename (without extension)
#' @param width Figure width in inches
#' @param height Figure height in inches
save_figure <- function(plot, filename, width = 8, height = 6) {
  # Ensure figures directory exists
  if (!dir.exists("../figures")) {
    dir.create("../figures", recursive = TRUE)
  }
  
  base_path <- file.path("../figures", filename)
  
  # Save as SVG (vector format)
  svglite::svglite(paste0(base_path, ".svg"), width = width, height = height)
  print(plot)
  grDevices::dev.off()
  
  # Save as high-resolution PNG
  ggplot2::ggsave(paste0(base_path, ".png"), plot, 
                  width = width, height = height, dpi = 600)
  
  # Save as preview PNG
  ggplot2::ggsave(paste0(base_path, "_preview.png"), plot, 
                  width = width, height = height, dpi = 150)
  
  # Save as PDF
  grDevices::pdf(paste0(base_path, ".pdf"), width = width, height = height)
  print(plot)
  grDevices::dev.off()
  
  cat(sprintf("Figure saved: %s (.svg, .png, _preview.png, .pdf)\n", filename))
}

# =============================================================================
# MAIN ANALYSIS
# =============================================================================

main <- function() {
  cat("=== TEMPLATE ANALYSIS ===\n\n")
  
  # Load data
  cat("Loading data...\n")
  data <- load_moai_data("../data/all_moai_combined.csv")
  cat(sprintf("Loaded %d records\n\n", nrow(data)))
  
  # Data processing
  cat("Processing data...\n")
  processed_data <- data %>%
    dplyr::filter(!is.na(mean_base_angle)) %>%
    dplyr::mutate(
      size_metric = total_length_cm * base_width_cm,
      category = dplyr::case_when(
        location_type == "ROAD" ~ "Road",
        location_type == "AHU" ~ "Ahu",
        TRUE ~ "Other"
      )
    ) %>%
    dplyr::filter(category != "Other")
  
  # Calculate statistics
  cat("Calculating statistics...\n")
  stats_summary <- processed_data %>%
    dplyr::group_by(category) %>%
    dplyr::summarise(
      n = dplyr::n(),
      mean_angle = mean(mean_base_angle, na.rm = TRUE),
      sd_angle = stats::sd(mean_base_angle, na.rm = TRUE),
      .groups = 'drop'
    )
  
  print(stats_summary)
  
  # Statistical test
  if (length(unique(processed_data$category)) == 2) {
    cat("\nPerforming t-test...\n")
    t_result <- stats::t.test(mean_base_angle ~ category, 
                              data = processed_data, 
                              var.equal = FALSE)
    cat(sprintf("t = %.3f, p = %.4f\n", 
                t_result$statistic, t_result$p.value))
  }
  
  # Create visualization
  cat("\nCreating visualization...\n")
  p <- ggplot2::ggplot(processed_data, 
                       ggplot2::aes(x = category, y = mean_base_angle)) +
    ggplot2::geom_boxplot(ggplot2::aes(fill = category), alpha = 0.7) +
    ggplot2::geom_jitter(width = 0.2, alpha = 0.5) +
    ggplot2::scale_fill_manual(values = c("Road" = "#e74c3c", "Ahu" = "#3498db")) +
    ggplot2::labs(
      title = "Template Analysis: Base Angles by Location",
      x = "Location Type",
      y = "Mean Base Angle (degrees)"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      legend.position = "none",
      plot.title = ggplot2::element_text(size = 14, face = "bold")
    )
  
  # Save outputs
  cat("\nSaving outputs...\n")
  save_figure(p, "template_analysis", width = 8, height = 6)
  
  # Save data
  utils::write.csv(stats_summary, "../figures/template_statistics.csv", 
                   row.names = FALSE)
  
  cat("\n=== ANALYSIS COMPLETE ===\n")
}

# =============================================================================
# EXECUTE
# =============================================================================

# Run analysis if script is executed directly
if (!interactive()) {
  tryCatch({
    main()
  }, error = function(e) {
    cat(sprintf("\nERROR: %s\n", e$message))
    quit(status = 1)
  })
}