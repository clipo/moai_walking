# The Walking Moai Hypothesis: Data Analysis and Figures

This repository contains the R code and data needed to produce the figures for the paper **"The Walking Moai Hypothesis (Easter Island): Archaeological Evidence, Experimental Validation, and Response to Critics"** by Carl Lipo and Terry Hunt.

## Project Overview

The Walking Moai Hypothesis proposes that the famous Easter Island statues (moai) were "walked" from the quarry to their final destinations using ropes and human power, rather than being transported horizontally on wooden sleds or rollers. This repository provides the statistical analyses and visualizations that support this hypothesis by examining the physical characteristics and spatial distribution of moai found along ancient roads.

## Requirements

- R (version 4.0 or higher recommended)
- R packages:
  - `readxl` - For reading Excel data files
  - `ggplot2` - For creating publication-quality visualizations
  - `dplyr` - For data manipulation
  - `tidyr` - For data tidying
  - `svglite` - For generating SVG outputs

### Installing Required Packages

```r
install.packages(c("readxl", "ggplot2", "dplyr", "tidyr", "svglite"))
```

## Repository Structure

```
moai_walking_paper_code/
├── R Scripts/
│   ├── Figure_2.R      # Base-to-shoulder width ratio comparison
│   ├── Figure_3.R      # Center of mass distribution for road moai
│   ├── Figure_5.R      # Base angle vs size relationship
│   ├── Figure_11.R     # Transport failure hypothesis model
│   ├── Figure_12.R     # Observed vs expected distribution comparison
│   └── Figure_13.R     # Moai size vs transport distance analysis
│
├── Data Files/
│   ├── VanTilburgData.xlsx        # Van Tilburg (1986) moai measurements
│   ├── Road Moai Data.xlsx        # Specific road moai measurements
│   ├── MOAI_DATABASE_PUBLIC.xlsx  # Public moai database
│   └── all_moai_combined.csv      # Combined moai dataset
│
├── figures/                       # Output directory (created automatically)
└── moai_walking_paper_code.Rproj  # R project file
```

## Running the Analysis

Each figure can be generated independently by running the corresponding R script:

```r
# Generate Figure 2 - Base-to-shoulder width ratio comparison
source("Figure_2.R")

# Generate Figure 3 - Center of mass distribution
source("Figure_3.R")

# Generate Figure 5 - Base angle vs size relationship
source("Figure_5.R")

# Generate Figure 11 - Transport failure hypothesis
source("Figure_11.R")

# Generate Figure 12 - Observed vs expected distribution
source("Figure_12.R")

# Generate Figure 13 - Size vs distance analysis
source("Figure_13.R")
```

Alternatively, run all analyses at once:

```r
# Run all figure scripts
source("Figure_2.R")
source("Figure_3.R")
source("Figure_5.R")
source("Figure_11.R")
source("Figure_12.R")
source("Figure_13.R")
```

## Figure Descriptions

### Figure 2: Base-to-Shoulder Width Ratios
Compares the ratio of base width to shoulder width between ahu moai (statues on ceremonial platforms) and road moai (statues found along transport routes). Uses Welch's t-test to demonstrate statistically significant differences between the two groups, supporting the hypothesis that road moai were designed differently for transport.

### Figure 3: Center of Mass Distribution
Analyzes the spatial distribution of moai center of mass locations along roads using geospatial coordinates and distance calculations. This analysis helps understand how moai were positioned during transport.

### Figure 5: Base Angle vs Size Relationship
Examines the relationship between moai base angle and size (length × width) for intact road moai. The base angle is crucial for the walking hypothesis as it affects the statue's ability to be "walked" upright.

### Figure 11: Transport Failure Hypothesis Model
Models the expected distribution of road moai if transport failures were the primary reason for their locations. Shows that under this hypothesis, most moai should be concentrated near the quarry.

### Figure 12: Observed vs Expected Distribution
Compares the actual observed distribution of road moai with the transport failure model predictions, demonstrating that the observed pattern differs significantly from what would be expected if moai locations were due to transport failures.

### Figure 13: Size vs Transport Distance
Analyzes whether larger moai were transported shorter distances, testing whether size limitations affected transport success. Examines patterns across different transport phases.

## Data Files

- **VanTilburgData.xlsx**: Comprehensive moai measurements from Van Tilburg's 1986 research
- **Road Moai Data.xlsx**: Specific measurements and locations of moai found along roads
- **MOAI_DATABASE_PUBLIC.xlsx**: Public database of moai information
- **all_moai_combined.csv**: Combined dataset integrating multiple sources

## Output

All figures are saved in the `figures/` directory in three formats:
1. **SVG** - Vector format for publication
2. **PNG (600 dpi)** - High-resolution raster format for print
3. **PNG (150 dpi)** - Preview version for quick viewing

## Statistical Methods

The analyses employ various statistical methods including:
- Welch's t-test for comparing groups with unequal variances
- Spatial analysis using Haversine distance calculations
- Distribution modeling and comparison
- Correlation analysis

## Citation

If you use this code or data in your research, please cite:

Lipo, C. and Hunt, T. (2024). The Walking Moai Hypothesis (Easter Island): Archaeological Evidence, Experimental Validation, and Response to Critics. [Journal Name], [Volume], [Pages].

## License

[License information to be added]

## Contact

For questions about this repository or the research, please contact:
- Carl Lipo: [email]
- Terry Hunt: [email]