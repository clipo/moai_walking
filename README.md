# The Walking Moai Hypothesis: Data Analysis and Figures

This repository contains the R code and data needed to produce the figures for the paper **"The Walking Moai Hypothesis (Easter Island): Archaeological Evidence, Experimental Validation, and Response to Critics"** by Carl Lipo and Terry Hunt.

## Project Overview

The Walking Moai Hypothesis proposes that the famous Easter Island statues (moai) were "walked" from the quarry to their final destinations using ropes and human power, rather than being transported horizontally on wooden sleds or rollers. This repository provides the statistical analyses and visualizations that support this hypothesis by examining the physical characteristics and spatial distribution of moai found along ancient roads.

## Requirements

- R (version 4.0 or higher recommended)
- R packages (automatically installed when running scripts):
  - `readxl` - For reading Excel data files
  - `ggplot2` - For creating publication-quality visualizations
  - `dplyr` - For data manipulation
  - `tidyr` - For data tidying
  - `svglite` - For generating SVG outputs
  - Additional packages for specific analyses:
    - `geosphere` and `purrr` (for Figure 3)
    - `scales` (for Figure 5)
    - `ragg` (for high-quality graphics in Figures 11-13)

### Setup and Installation

#### Option 1: Using Packrat for Full Reproducibility (Recommended)
Packrat creates a private package library for this project, ensuring exact package versions are preserved:

```r
# First time setup - initialize packrat
source("init_packrat.R")

# After packrat is initialized, for subsequent runs:
source("setup.R")
```

This approach:
- Creates a project-specific package library
- Captures exact package versions in packrat.lock
- Ensures complete reproducibility across different machines
- Automatically installs the correct package versions

To restore the environment on a new machine with packrat already initialized:
```r
packrat::restore()
```

#### Option 2: Standard Setup
If you prefer not to use packrat, run the setup script:

```r
source("setup.R")
```

This will:
- Check for missing packages
- Install any packages that aren't already installed
- Verify all packages load correctly
- Display version information for reproducibility

#### Option 3: Manual Installation
```r
install.packages(c("readxl", "ggplot2", "dplyr", "tidyr", "svglite", 
                   "geosphere", "purrr", "scales", "ragg"))
```

#### Option 4: Automatic Installation When Running Scripts
Each R script includes automatic package checking and installation. Simply run any script and it will install missing packages automatically.

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
├── Setup & Utilities/
│   ├── init_packrat.R  # Initialize packrat for reproducibility
│   ├── setup.R         # Setup script with packrat support
│   └── package_loader.R # Helper function for loading packages
│
├── Packrat Files (if initialized)/
│   ├── packrat/        # Packrat private library (git-ignored)
│   └── packrat.lock    # Package version lockfile
│
├── Data Files/
│   ├── VanTilburgData.xlsx        # Van Tilburg (1986) moai measurements
│   ├── Road Moai Data.xlsx        # Specific road moai measurements
│   ├── MOAI_DATABASE_PUBLIC.xlsx  # Public moai database
│   └── all_moai_combined.csv      # Combined moai dataset
│
├── figures/                       # Output directory (created automatically)
├── README.md                      # This file
├── CLAUDE.md                      # AI assistance documentation
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

Lipo, C. and Hunt, T. (2025). The Walking Moai Hypothesis (Easter Island): Archaeological Evidence, Experimental Validation, and Response to Critics. [Journal of Archaeological Science], [TBD], [TBD].

## License

[License information to be added]

## Contact

For questions about this repository or the research, please contact:
- Carl Lipo: [clipo@binghamton.edu]
- Terry Hunt: [tlhunt@arizona.edu]
