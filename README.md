# The Walking Moai Hypothesis: Complete Analysis Suite

This repository contains both R statistical analysis code and Python 3D physics simulations to support the paper **"The Walking Moai Hypothesis (Easter Island): Archaeological Evidence, Experimental Validation, and Response to Critics"** by Carl Lipo and Terry Hunt.

## Project Overview

The Walking Moai Hypothesis proposes that the famous Easter Island statues (moai) were "walked" from the quarry to their final destinations using ropes and human power, rather than being transported horizontally on wooden sleds or rollers. This repository provides:

1. **Statistical Analyses (R)**: Examining physical characteristics and spatial distribution of moai found along ancient roads
2. **3D Physics Analysis (Python)**: Calculating center of mass and stability characteristics of moai using 3D mesh analysis

### Recent Updates (January 2025)
- ✅ **Implemented renv** for modern R package management (replacing packrat)
- ✅ Added comprehensive data documentation (DATA_DOCUMENTATION.md)
- ✅ Added Table 1: Orientation analysis of road moai
- ✅ Updated Figure S1: Comprehensive 6-panel hypothesis testing visualization
- ✅ Added Table S1: Statistical test results for hypothesis comparison
- ✅ Cleaned up docs directory - now contains only PDF manuscripts
- ✅ Archived alternative analysis scripts for reproducibility
- ✅ Enhanced documentation and project structure
- ✅ Integrated 33 additional road moai IDs (total: 84)
- ✅ Corrected quarry center to geocentroid (-27.125175°, -109.288170°)
- ✅ **Fixed Figure 2** - Corrected location coding and ratio interpretation (October 2025)

### Important Note: Figure 2 Correction (October 2025)
**The original Figure 2 published in the paper contained errors in location coding and ratio interpretation.** These issues have been corrected in this codebase. The corrected figure properly demonstrates that:
- Road moai (Locations 6 & 7) have wider bases relative to shoulders (ratio ≈ 1.0) - original transport design
- Ahu moai (Location 8) have narrower bases (ratio > 1.0) - reshaped for platform installation

The statistical significance remains robust (p = 0.002), but the interpretation now correctly supports the walking hypothesis. See `docs/Figure_2_correction_notes.txt` for complete details. We thank Dr. Florian Hindenlang (Max-Planck Institute for Plasma Physics) for identifying these issues.

## Quick Start

### R Statistical Analysis
```bash
# Clone the repository
git clone https://github.com/clipo/moai_walking.git
cd moai_walking

# Generate all R figures
cd scripts
Rscript create_distance_dataset.R  # Create distance data (run once)
Rscript run_all_figures.R          # Generate all figures
```

### Python 3D Analysis
```bash
cd python
pip install numpy trimesh matplotlib plotly scipy  # Install dependencies
python moai_analyzer_final.py       # Generate Figure_4 (two-panel)
python moai_analyzer_plotly.py      # Create interactive 3D visualization
```

## Requirements

### For R Analysis
- **R** version 4.0 or higher
- **Required R packages** (will be installed automatically):
  - `readxl` - Reading Excel data files
  - `ggplot2` - Creating publication-quality visualizations
  - `dplyr` - Data manipulation
  - `tidyr` - Data tidying
  - `svglite` - Generating SVG outputs
  - `cowplot` - Combining plots (used in Figure 6)

### For Python 3D Analysis
- **Python** 3.7 or higher (tested with 3.7-3.12)
- **Required Python packages**:
  - `numpy>=1.26.0` - Numerical computations (1.26+ required for Python 3.12)
  - `trimesh>=4.0.10` - 3D mesh processing
  - `matplotlib>=3.8.2` - Static visualizations
  - `plotly>=5.18.0` - Interactive visualizations
  - `scipy>=1.11.4` - Scientific computing (ConvexHull)

**Important Python 3.12 Note**: If using Python 3.12+, the requirements.txt uses minimum version specifications (>=) rather than pinned versions to ensure compatibility. Python 3.12 requires numpy 1.26 or higher due to removed deprecated features in Python's pkgutil module.

## Repository Structure

```
moai_walking/
├── scripts/                # R statistical analysis scripts
│   ├── Figure_2.R         # Base-to-shoulder width ratio comparison
│   ├── Figure_3.R         # Center of mass distribution for road moai
│   ├── Figure_5.R         # Base angle vs size (intact road moai only)
│   ├── Figure_6.R         # Elevation and slope profiles of moai roads
│   ├── Figure_11.R        # Transport failure hypothesis model
│   ├── Figure_12.R        # Observed distribution using real data
│   ├── Figure_13.R        # Size vs distance analysis
│   ├── Figure_S1.R        # Supplemental: 6-panel comprehensive hypothesis testing
│   ├── Table_1_moai_orientation_analysis.R # Table 1: Road moai orientation analysis
│   ├── create_distance_dataset.R # Generate distance measurements
│   ├── test_environment.R # Test R environment setup
│   ├── run_all_figures.R # Run all analyses sequentially
│   ├── init_renv.R       # Initialize renv (for new setups)
│   ├── setup_renv.R      # Simple renv setup script
│   ├── init_packrat.R    # Initialize packrat (legacy, renv is preferred)
│   ├── setup.R            # Setup script with package installation
│   ├── package_loader.R   # Helper function for loading packages
│   └── archive/           # Older/alternative versions of scripts
│
├── python/                # Python 3D physics analysis scripts
│   ├── moai_analyzer_final.py      # Main 3D analysis - creates Figure_4
│   ├── moai_analyzer_plotly.py     # Interactive 3D visualization
│   ├── output_helper.py            # Output path utility module
│   ├── README.txt                  # Python scripts documentation
│   ├── README.md                   # Python scripts documentation (markdown)
│   └── archive_old_versions/       # Development/test scripts
│
├── data/                  # Input data files
│   ├── DATA_DOCUMENTATION.md      # Complete documentation of all data files
│   ├── VanTilburgData.xlsx        # Van Tilburg (1986) moai measurements
│   ├── Road Moai Data.xlsx        # Road moai with GPS coordinates and base angles
│   ├── MOAI_DATABASE_PUBLIC.xlsx  # Schumacher (2013) geospatial database
│   ├── all_moai_combined.csv      # Merged dataset with all moai measurements
│   ├── SimplifiedMoai.obj          # 3D mesh model (5,150 vertices)
│   ├── moai_road_slope_from_raraku.xlsx  # Slope data: Rano Raraku to South Coast road
│   ├── southcoast_road_only_slope.xlsx   # Slope data: South Coast road segment
│   ├── Table_1_road_moai_orientation.xlsx # Road moai orientation data
│   ├── moai_with_distances.csv*   # Generated: moai with distances from geocentroid
│   ├── road_moai_distances.csv*   # Generated: road moai subset (84 records)
│   └── road_moai_zones.csv*       # Generated: distance zone analysis
│
├── figures/               # Output directory (created automatically)
│   └── [Generated figures in .svg, .png, .pdf, .html formats]
│
├── docs/                  # Documentation
│   ├── Walking Moai Hypothesis-Revised-V2.pdf  # Main manuscript (PDF)
│   └── Supplemental Information.pdf            # Supplemental materials
│
├── renv/                 # renv package management
│   ├── activate.R        # Auto-activation script
│   ├── settings.json     # Project settings
│   └── library/          # Project-specific package library (git-ignored)
├── renv.lock            # Package versions snapshot (3000+ lines)
├── .Rprofile            # Auto-activates renv when opening project
├── CLAUDE.md            # Project guidelines for AI assistance
├── LICENSE              # MIT License
└── README.md            # This file

* Generated files (created by create_distance_dataset.R)
```

## Installation & Setup

### Option 1: Using renv for Full Reproducibility (Recommended)

✅ **renv is now implemented in this project!** Simply clone and restore:

```r
# Clone the repository
git clone https://github.com/clipo/moai_walking.git
cd moai_walking

# Open R and restore the exact package environment
renv::restore()  # This installs all packages with exact versions from renv.lock
```

**Why renv?**
- ✅ Already configured with `renv.lock` file
- ✅ Ensures exact reproducibility across all machines
- ✅ Faster than packrat with shared global cache
- ✅ Better RStudio integration
- ✅ Active development and support

### Option 2: Standard Installation (Quick start without renv)

```r
# From R console in project directory
source("scripts/setup.R")  # Installs all required packages
```

### Option 3: Manual Package Installation

```r
install.packages(c("readxl", "ggplot2", "dplyr", "tidyr", "svglite", "cowplot"))
```

### Option 4: Using Packrat (Legacy - not recommended)

```r
# Packrat is still available but renv is strongly preferred
source("scripts/init_packrat.R")
packrat::restore()
```

## Running the Analyses

### Generate All Figures at Once

```bash
cd scripts
Rscript create_distance_dataset.R  # Create distance data (first time only)
Rscript run_all_figures.R          # Generate all figures
```

### Generate Individual Figures

```bash
cd scripts

# Figure 2: Base-to-shoulder width ratios
Rscript Figure_2.R

# Figure 3: Center of mass distribution
Rscript Figure_3.R

# Figure 5: Base angle vs size (intact road moai)
Rscript Figure_5.R

# Figure 11: Transport failure hypothesis model
Rscript Figure_11.R

# Figure 12: Observed distribution with real data
Rscript Figure_12.R

# Figure 13: Size vs transport distance analysis
Rscript Figure_13.R

# Figure S1 (Supplemental): Ceremonial vs transport failure hypothesis testing
Rscript Figure_S1.R  # Generates Figure S1 and Table S1
```

### Test Your Environment

```bash
cd scripts
Rscript test_environment.R  # Checks packages and data availability
```

## Python 3D Analysis (Figure 4)

### Prerequisites

- Python 3 (versions 3.7-3.11 tested)
- pip package manager

### Installation & Setup

#### Quick Start (Standard Installation)

```bash
# Navigate to python directory from project root
cd python

# Install required packages
pip install -r requirements.txt
```

#### Reproducible Setup (Like R's packrat)

For exact reproducibility across machines, we provide multiple options:

**Option 1: Automated Setup Script (Recommended)**
```bash
cd python
python setup_python.py          # Creates venv and installs locked versions
source activate_moai.sh         # Linux/Mac
activate_moai.bat               # Windows
```

**Option 2: Manual with Locked Versions**
```bash
cd python
python -m venv venv
source venv/bin/activate        # Linux/Mac (or venv\Scripts\activate on Windows)
pip install -r requirements-lock.txt
```

**Option 3: Using Conda**
```bash
cd python
conda env create -f environment.yml
conda activate hotuiti
```

**Option 4: Using Pipenv**
```bash
cd python
pip install pipenv
pipenv install
pipenv run python moai_analyzer_final.py
```

See `python/PYTHON_REPRODUCIBILITY.md` for detailed instructions on all methods.

Required packages with locked versions:
- `trimesh==4.0.10` - 3D mesh processing and analysis
- `numpy==1.24.4` - Numerical computations (1.26+ for Python 3.12)
- `scipy==1.11.4` - Scientific computing
- `matplotlib==3.8.2` - Static visualization
- `plotly==5.18.0` - Interactive 3D visualization

**Note**: Use `requirements-lock.txt` for exact reproducibility or `requirements.txt` for minimum compatible versions.

### Generating Figure 4

#### Option 1: Run from python directory
```bash
cd python
python moai_analyzer_final.py

# Output files created:
# - ../figures/Figure_4_moai_analysis.svg (vector format)
# - ../figures/Figure_4_moai_analysis_600dpi.png (600 dpi for publication)
# - ../figures/moai_analysis_final.svg
# - ../figures/moai_analysis_final_600dpi.png
```

#### Option 2: Run from project root
```bash
python python/moai_analyzer_final.py
```

The figure shows:
- **Panel A**: 3D mesh with center of mass (red sphere) and vertical projection line
- **Panel B**: Top-down view showing COM projection within base polygon

### Interactive 3D Visualization (Optional)

```bash
# From python directory:
cd python
python moai_analyzer_plotly.py

# OR from project root:
python python/moai_analyzer_plotly.py

# Output files:
# - figures/Figure_4_moai_analysis_interactive.html
# - figures/moai_analysis_interactive.html
```

Open the HTML files in a web browser to:
- Rotate the 3D model with mouse drag
- Zoom with scroll wheel
- Pan with right-click drag
- Toggle visibility of different elements

### Additional Analysis Scripts

```bash
# From python directory:
cd python
python calculate_lean_angle.py     # Calculate maximum lean angles
python test_base_outline.py        # Test base outline detection

# OR from project root:
python python/calculate_lean_angle.py
python python/test_base_outline.py
```

### 3D Analysis Key Findings

Our physics-based analysis of the 3D moai model reveals:

| Metric | Value | Significance |
|--------|-------|--------------|
| **COM Height** | 40.6% of total height (2.99m from base) | Low COM ensures stability |
| **Forward Lean** | 4.9° | Engineered instability for walking |
| **Front Edge Distance** | 14cm | COM projects near front edge |
| **COM Offset** | 23cm backward, 34cm left | Asymmetric design |
| **Base Dimensions** | 2.64m × 2.10m | D-shaped footprint |

The 3D analysis confirms that moai were designed with inherent stability for upright transport.

## Figure Descriptions & Key Findings

### R Statistical Analysis Figures

| Figure | Description | Key Finding |
|--------|-------------|-------------|
| **Figure 2** | Shoulder-to-base width ratio comparison between ahu and road moai | ⚠️ **Corrected (Oct 2025)**: Road moai have wider bases (ratio=1.025), ahu moai have narrower bases (ratio=1.132). Statistically significant difference (t=3.181, p=0.002) supports walking hypothesis |
| **Figure 3** | Center of mass distribution for road moai | Consistent CoM (0.392±0.006) indicates standardized construction |
| **Figure 5** | Base angle vs size for intact road moai | Negligible correlation despite 20-fold size variation shows standardized angles (5-14°) |
| **Figure 11** | Transport failure hypothesis model | Expected concentration near quarry under failure hypothesis |
| **Figure 12** | Observed road moai distribution | 41.7% within 2km of quarry (35/84 moai) shows transport challenges |
| **Figure 13** | Moai size vs transport distance | No correlation between size and distance - size wasn't limiting factor |
| **Figure S1** | Hypothesis testing (supplemental) | 6-panel comprehensive comparison of ceremonial vs transport failure hypotheses |
| **Table S1** | Statistical test results (supplemental) | All 6 tests support transport failure, 0 support ceremonial placement |
| **Table 1** | Road moai orientation analysis | Analysis of moai orientations relative to roads and transport paths |

### Python 3D Analysis Outputs

| Figure | File | Description |
|--------|------|-------------|
| **Figure 4** | Figure_4_moai_analysis_600dpi.png | Two-panel view: 3D mesh with COM + top-down base analysis |
| **Interactive** | Figure_4_moai_analysis_interactive.html | Rotatable 3D model for exploration |
| **Vector** | Figure_4_moai_analysis.svg | Publication-quality vector format |

## Data Files

### Primary Data Sources
- **VanTilburgData.xlsx**: Van Tilburg (1986) moai measurements
- **MOAI_DATABASE_PUBLIC.xlsx**: Schumacher (2013) MA thesis geospatial database
- **Road Moai Data.xlsx**: Road moai with GPS coordinates and base angles
- **DATA_DOCUMENTATION.md**: Complete documentation of all data files with full citations
- **all_moai_combined.csv**: Merged dataset combining multiple sources
- **SimplifiedMoai.obj**: 3D mesh model (5,150 vertices, 10,296 faces)

### Generated Data Files
Run `create_distance_dataset.R` to generate:
- **moai_with_distances.csv**: All moai with calculated distances from quarry geocentroid
- **road_moai_distances.csv**: Road moai subset with distance measurements (84 records)
- **road_moai_zones.csv**: Distance zone analysis for transport failure model

**Important**: All distances are calculated from the geocentroid of 318 bedrock quarry moai 
at coordinates -27.125175°, -109.288170°. This represents the actual center of quarrying 
activity at Rano Raraku, providing more accurate distance measurements than using a general 
quarry location.

## Output Files

All figures are saved in three formats:
- **.svg** - Vector format for publication
- **.png** - High-resolution (600 dpi) for print
- **_preview.png** - Lower resolution (150 dpi) for quick viewing

Additional outputs:
- **.csv** files with processed data and statistics
- **.pdf** versions of figures

## Code Style

This project follows clean R coding practices:
- **Explicit notation**: Uses `package::function()` for clarity
- **No side effects**: Minimal use of `library()` to avoid namespace pollution
- **Real data only**: No synthetic/demo data generation
- **Clear errors**: Informative messages when data is missing
- See `R_STYLE_GUIDE.md` for complete coding standards

## Troubleshooting

### Common Issues and Solutions

1. **"No data file found" error**
   - Ensure you're running scripts from the `scripts/` directory
   - Check that data files exist in `../data/` relative to scripts

2. **"object 'n.of.pieces' not found"**
   - The column name uses dots not spaces: `n.of.pieces` not `n of pieces`
   - This is how R handles spaces in column names from CSV files

3. **Missing distance data for Figures 11-13**
   - Run `create_distance_dataset.R` first to generate distance measurements

4. **Package installation fails**
   - Try running `source("scripts/setup.R")` with a fresh R session
   - Ensure you have write permissions to the R library directory

## Reproducibility Notes

### R Environment
- **R Version**: Tested with R 4.4.0
- **Package Management**: ✅ **renv implemented** (see `renv.lock` for exact versions)
- **Automatic Activation**: `.Rprofile` automatically loads renv when you open the project
- **To Reproduce**: Simply run `renv::restore()` after cloning

### Python Environment
- **Python Version**: 3.10.13 recommended (compatible with 3.7-3.12)
- **Package Management**: Multiple options provided (similar to packrat)
- **Package Versions**: See `python/requirements-lock.txt` for exact versions
- **Setup**: Run `python python/setup_python.py` for automated setup

### General
- **Random Seed**: Set to 42 where applicable for reproducible results
- **Distance Calculations**: Using Euclidean approximation suitable for Easter Island's small area
- **Quarry Location**: Rano Raraku geocentroid at -27.125175°, -109.288170°

## Citation

If you use this code or data in your research, please cite:

```bibtex
@article{lipo2025walking,
  title={The Walking Moai Hypothesis (Easter Island): Archaeological Evidence, 
         Experimental Validation, and Response to Critics},
  author={Lipo, Carl and Hunt, Terry},
  journal={Journal of Archaeological Science},
  year={2025},
  note={In preparation}
}
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new analysis'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- Carl Lipo: clipo@binghamton.edu
- Terry Hunt: tlhunt@arizona.edu

## Acknowledgments

- Van Tilburg, J.A. (1986) for the comprehensive moai measurement database
- The Rapa Nui (Easter Island) community for preserving their cultural heritage
- All contributors to the Walking Moai Hypothesis research

## Verification Status

✅ **All analyses verified and reproducible** (see [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md))
- All figures successfully generate from source data
- All required packages available and tested
- Distance calculations implemented and validated
- Code follows scientific reproducibility standards