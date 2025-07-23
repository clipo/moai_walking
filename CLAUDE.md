# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a scientific research project analyzing Easter Island moai (statues) data to support the "Walking Moai Hypothesis". The project compares characteristics between moai found on ceremonial platforms (ahu) versus those found along transport routes (roads).

## Development Environment

- **Language**: R
- **Project Type**: Statistical analysis and data visualization for academic research
- **R Project**: `moai_walking_paper_code.Rproj`

## Key Libraries

All R scripts use these core libraries:
- `readxl` - Reading Excel data files
- `ggplot2` - Creating publication-quality visualizations
- `dplyr` - Data manipulation
- `tidyr` - Data tidying
- `svglite` - Generating SVG outputs

## Running the Analysis

Each figure script can be run independently:
```r
source("Figure_2.R")  # Generates base-to-shoulder width ratio comparison
source("Figure_3.R")  # Additional analysis
source("Figure_5.R")  # Further visualizations
# etc.
```

## Data Sources

- **VanTilburgData.xlsx** - Primary dataset from Van Tilburg (1986) research
- **Road Moai Data.xlsx** - Specific road moai measurements
- **MOAI_DATABASE_PUBLIC.xlsx** - Public moai database
- **all_moai_combined.csv** - Combined dataset

## Output Structure

All figures are saved to the `figures/` directory in three formats:
1. SVG (vector format for publication)
2. PNG at 600 dpi (high-resolution for print)
3. PNG at 150 dpi (preview version)

## Analysis Patterns

Scripts follow a consistent pattern:
1. Load required libraries
2. Read Excel data using `read_excel()`
3. Process data with `dplyr` pipeline
4. Perform statistical tests (e.g., Welch's t-test)
5. Create visualizations with `ggplot2`
6. Save outputs in multiple formats

## Key Data Processing

- **Location Coding**: 
  - Locations 1-6 = ahu sites (completed moai on platforms)
  - Location 8 = roads/transport routes (moai in transport)
- **Common Calculations**: Base-to-shoulder width ratios, center of mass analysis
- **Statistical Tests**: Welch's t-test for group comparisons

## Code Style

- Use tidyverse-style pipelines (`%>%`)
- Comprehensive commenting for data processing steps
- Generate both statistical output and figure captions
- Include sample sizes and p-values in visualizations