# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a scientific research project analyzing Easter Island moai (statues) data to support the "Walking Moai Hypothesis". The project includes:

1. **Statistical Analysis (R)**: Comparing characteristics between moai found on ceremonial platforms (ahu) versus those found along transport routes (roads)
2. **3D Physics Analysis (Python)**: Calculating center of mass and stability characteristics using 3D mesh analysis

## Repository Structure

```
moai_walking/
├── scripts/          # R statistical analysis scripts
├── python/           # Python 3D physics analysis scripts
├── data/            # Input data files, 3D models, and generated datasets
├── figures/         # Output visualizations (SVG, PNG, HTML)
└── docs/            # Documentation
```

## Development Environment

### R Environment
- **Language**: R (version 4.0+)
- **Project Type**: Statistical analysis and data visualization
- **R Project**: `moai_walking_paper_code.Rproj`
- **Package Management**: Optional packrat support for reproducibility

### Python Environment
- **Language**: Python (3.7-3.12, tested with 3.10 and 3.12)
- **Project Type**: 3D mesh analysis and physics calculations
- **Key Library**: trimesh for 3D mesh processing
- **Visualization**: matplotlib and plotly for outputs
- **Compatibility Note**: Python 3.12 requires numpy>=1.26.0

## Key Libraries

### R Packages
- `readxl` - Reading Excel data files
- `ggplot2` - Creating publication-quality visualizations
- `dplyr` - Data manipulation
- `tidyr` - Data tidying
- `svglite` - Generating SVG outputs

### Python Packages (minimum versions for compatibility)
- `trimesh>=4.0.10` - 3D mesh processing and analysis
- `numpy>=1.26.0` - Numerical computations (1.26+ required for Python 3.12)
- `scipy>=1.11.4` - Scientific computing
- `matplotlib>=3.8.2` - 2D/3D plotting
- `plotly>=5.18.0` - Interactive 3D visualizations

## Code Style Requirements

- **Use explicit package notation**: Always use `package::function()` instead of library() calls
- **No demo data**: Never generate synthetic/random data - require real data with clear error messages
- **Consistent file paths**: Scripts run from `scripts/` directory, data in `../data/`, outputs to `../figures/`
- **Error handling**: Provide informative error messages when data is missing
- **Reproducibility**: Set seed to 42 when randomization is used

## Running the Analysis

### R Statistical Analysis
```bash
cd scripts
Rscript create_distance_dataset.R  # Generate distance data (run once)
Rscript run_all_figures.R          # Generate all figures

# Individual figures
Rscript Figure_2.R                  # Base-to-shoulder width ratio comparison
Rscript Figure_3.R                  # Center of mass distribution
Rscript Figure_5.R                  # Base angle vs size (intact moai only)
Rscript Figure_11.R                 # Transport failure hypothesis model
Rscript Figure_12.R                 # Observed distribution with real data
Rscript Figure_13.R                 # Size vs transport distance
```

### Python 3D Analysis
```bash
cd python
pip install -r requirements.txt     # Install dependencies (first time)

python moai_analyzer_final.py       # Main 3D analysis (Figure 4)
python moai_analyzer_plotly.py      # Interactive 3D visualization
python calculate_lean_angle.py      # Lean angle calculations
```

## Data Sources

### Primary Data Files
- **VanTilburgData.xlsx** - Van Tilburg (1986) comprehensive moai measurements
- **Road Moai Data.xlsx** - Road moai with GPS coordinates and base angles
- **MOAI_DATABASE_PUBLIC.xlsx** - Public database with extensive moai information
- **all_moai_combined.csv** - Merged dataset from multiple sources
- **SimplifiedMoai.obj** - 3D mesh model for physics analysis (5,150 vertices)

### Generated Data Files
Created by `create_distance_dataset.R`:
- **moai_with_distances.csv** - All moai with calculated distances from Rano Raraku quarry
- **road_moai_distances.csv** - Road moai subset with distance measurements

## Output Standards

### Figure Naming Convention
All figures use the format: `Figure_N_description` where N is the figure number

### Required Output Formats
1. **SVG** - Vector format for publication
2. **PNG 600 dpi** - High-resolution for print
3. **PNG 150 dpi** - Preview version (suffix: `_preview.png`)
4. **PDF** - For certain figures (optional)

### Data Outputs
- CSV files with processed data and statistics
- Named consistently with their corresponding figures

## Key Data Processing Rules

### Location Coding
- Locations 1-6 = ahu sites (completed moai on platforms)
- Location 8 = roads/transport routes (moai in transport)

### Intact Moai Identification
- Intact moai have `n.of.pieces == 1` (note: column uses dots, not spaces)
- Filter intact road moai: `filter(n.of.pieces == "1" | n.of.pieces == 1)`

### Distance Calculations
- Quarry geocentroid: -27.125175°, -109.288170° (calculated from 318 bedrock quarry moai)
- Use Euclidean approximation (suitable for Easter Island's small area):
  ```r
  lat_diff <- (lat2 - lat1) * 111000  # meters
  lon_diff <- (lon2 - lon1) * 99000   # meters at Easter Island latitude
  distance <- sqrt(lat_diff^2 + lon_diff^2)
  ```

### 3D Physics Calculations (Python)
- **Center of Mass**: Calculated using weighted average of triangle centroids
- **Scaling**: 1 unit in OBJ = 4.894 meters (actual moai height: 7.35m)
- **Coordinate System**: Y=vertical (height), X=width, Z=depth
- **Stability Analysis**: COM projection must fall within base footprint
- **Base Detection**: Vertices with Y < (min_Y + 0.05) threshold

## Statistical Analysis Standards

- **Group Comparisons**: Use Welch's t-test for unequal variances
- **Report Format**: Always include test statistic, p-value, and sample sizes
- **Significance Level**: α = 0.05
- **Figure Captions**: Include statistical results in captions

## Common Issues and Solutions

1. **Column name with spaces**: R converts "n of pieces" to "n.of.pieces"
2. **Missing distance data**: Run `create_distance_dataset.R` first
3. **Package conflicts**: Use explicit `package::function()` notation
4. **File paths**: Always use relative paths from `scripts/` directory

## Testing and Verification

- **Test environment**: Run `test_environment.R` to check setup
- **Test all figures**: Run `run_all_figures.R` to verify all analyses
- **Packrat testing**: Initialize with `init_packrat.R` for full reproducibility

## Important Notes for AI Assistance

- Never create new files unless explicitly requested
- Always prefer editing existing files over creating new ones
- Do not create documentation files proactively
- Use real data only - no synthetic/demo data generation
- Follow the explicit package notation convention
- Ensure all analyses are reproducible and documented