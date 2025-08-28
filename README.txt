================================================================================
                    WALKING MOAI HYPOTHESIS - ANALYSIS CODE
================================================================================

This repository contains the complete analysis code and data for testing the 
Walking Moai Hypothesis on Easter Island statue transport.

================================================================================
FAST START GUIDE - GENERATE ALL FIGURES IN 5 MINUTES
================================================================================

Prerequisites:
- R (version 4.0 or higher)
- Python 3 (version 3.7-3.11) with pip
- Git

Quick Setup Steps:

1. CLONE THE REPOSITORY
   git clone https://github.com/clipo/moai_walking.git
   cd moai_walking

2. INSTALL R PACKAGES (run from project root)
   Rscript setup.R

3. GENERATE DISTANCE DATASETS (required first time only)
   Rscript scripts/create_distance_dataset.R
   Note: This uses data/all_moai_combined.csv which is included in the repository

4. GENERATE ALL FIGURES AT ONCE
   Rscript scripts/run_all_figures.R

That's it! All figures will be in the figures/ directory.

================================================================================
GENERATE INDIVIDUAL FIGURES
================================================================================

If you want to generate specific figures:

From the scripts directory:
   cd scripts
   
   Rscript Figure_2.R    # Base-to-shoulder width ratio comparison
   Rscript Figure_3.R    # Center of mass distribution  
   Rscript Figure_5.R    # Base angle vs size (intact moai)
   Rscript Figure_11.R   # Transport failure model
   Rscript Figure_12.R   # Observed distribution analysis
   Rscript Figure_13.R   # Size vs transport distance

================================================================================
PYTHON 3D ANALYSIS (FIGURE 4)
================================================================================

For the 3D mesh analysis figures:

1. INSTALL PYTHON PACKAGES
   cd python
   pip install -r requirements.txt

2. RUN 3D ANALYSIS
   python moai_analyzer_final.py      # Generate static Figure 4
   python moai_analyzer_plotly.py     # Generate interactive 3D visualization

================================================================================
OUTPUT FILES
================================================================================

All figures are saved in the figures/ directory in multiple formats:
- High-resolution PNG (600 dpi) for publication
- Preview PNG (150 dpi) for quick viewing  
- SVG vector format for editing
- PDF for manuscripts
- CSV data files for verification

================================================================================
PROJECT STRUCTURE
================================================================================

moai_walking/
├── data/                  # Input data files and 3D models
├── figures/              # Output figures (generated)
├── scripts/              # R analysis scripts
├── python/               # Python 3D analysis scripts
├── setup.R               # Package installer
└── README.txt            # This file

================================================================================
TROUBLESHOOTING
================================================================================

PROBLEM: "trying to use CRAN without setting a mirror"
SOLUTION: Pull the latest version - this has been fixed
   git pull origin main
   Rscript setup.R

PROBLEM: "Package X not found"  
SOLUTION: Run the setup script
   Rscript setup.R

PROBLEM: "File not found" errors when running figures
SOLUTION: Generate the distance datasets first
   Rscript scripts/create_distance_dataset.R

PROBLEM: Python ImportError
SOLUTION: Install Python packages
   cd python
   pip install -r requirements.txt

PROBLEM: Figures look different from paper
SOLUTION: Check R and package versions
   Rscript -e "sessionInfo()"

================================================================================
REPRODUCIBILITY
================================================================================

For enhanced reproducibility using packrat (optional):
   Rscript init_packrat.R
   
This creates a project-specific package library ensuring consistent versions.

================================================================================
DATA SOURCES
================================================================================

Primary datasets:
- VanTilburgData.xlsx: Van Tilburg (1986) moai measurements
- MOAI_DATABASE_PUBLIC.xlsx: Comprehensive moai database
- SimplifiedMoai.obj: 3D mesh model (5,150 vertices)
- Road Moai Data.xlsx: Road moai with GPS coordinates and base angles
- all_moai_combined.csv: Merged dataset with all moai measurements

Generated datasets (created by create_distance_dataset.R):
- moai_with_distances.csv: All moai with calculated distances from quarry
- road_moai_distances.csv: Road moai subset with distances
- road_moai_zones.csv: Distance zone analysis for transport failure model

Note: All distances are calculated from the geocentroid of 318 bedrock 
quarry moai (-27.125175°, -109.288170°), representing the actual center 
of quarrying activity at Rano Raraku.

================================================================================
CITATION
================================================================================

If you use this code in your research, please cite:
[Citation information will be added upon publication]

================================================================================
LICENSE
================================================================================

This code is released under the MIT License. See LICENSE file for details.

================================================================================
CONTACT
================================================================================

For questions or issues:
- Open an issue on GitHub: https://github.com/clipo/moai_walking/issues
- Contact: [Author contact information]

================================================================================