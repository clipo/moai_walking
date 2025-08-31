================================================================================
                    R SCRIPTS FOR MOAI WALKING HYPOTHESIS ANALYSIS
================================================================================

This directory contains R scripts to generate statistical analyses and figures
for the Walking Moai Hypothesis paper by Lipo and Hunt.

--------------------------------------------------------------------------------
QUICK START
--------------------------------------------------------------------------------

To generate ALL figures at once:

    Rscript create_distance_dataset.R    # Run FIRST (creates distance data)
    Rscript run_all_figures.R            # Generates all 6 figures

To generate individual figures:

    Rscript Figure_2.R    # Base-to-shoulder width ratio comparison
    Rscript Figure_3.R    # Center of mass distribution
    Rscript Figure_5.R    # Base angle vs size (intact road moai)
    Rscript Figure_11.R   # Transport failure hypothesis model
    Rscript Figure_12.R   # Observed distribution with real data
    Rscript Figure_13.R   # Size vs transport distance analysis
    Rscript Figure_S1.R   # Supplemental: 6-panel hypothesis testing
    Rscript Table_1_moai_orientation_analysis.R  # Table 1: Road moai orientations

--------------------------------------------------------------------------------
PREREQUISITES
--------------------------------------------------------------------------------

Required R packages (will be installed automatically if missing):
- readxl     (reading Excel files)
- ggplot2    (creating visualizations)
- dplyr      (data manipulation)
- tidyr      (data reshaping)
- svglite    (SVG output)

To install all packages manually:
    Rscript setup.R

To test your environment:
    Rscript test_environment.R

--------------------------------------------------------------------------------
OUTPUT LOCATION
--------------------------------------------------------------------------------

All figures are saved to: ../figures/

Each figure generates multiple formats:
- .svg         Vector format for publication
- .png         High resolution (600 dpi) for print
- _preview.png Low resolution (150 dpi) for quick viewing
- .pdf         PDF format (some figures)
- .csv         Associated data files

--------------------------------------------------------------------------------
IMPORTANT: ORDER OF EXECUTION
--------------------------------------------------------------------------------

1. FIRST TIME ONLY: Run create_distance_dataset.R
   This creates distance measurements needed by Figures 11, 12, and 13
   
2. Then run any figure script individually OR use run_all_figures.R

--------------------------------------------------------------------------------
FIGURE DESCRIPTIONS
--------------------------------------------------------------------------------

Figure_2.R
  - Compares base-to-shoulder width ratios between ahu and road moai
  - Statistical test: Welch's t-test
  - Key finding: Significant difference (p=0.015)

Figure_3.R  
  - Calculates center of mass distribution for road moai
  - Uses volumetric sectional analysis
  - Key finding: Mean CoM at 0.393 ± 0.006 (below midpoint)

Figure_5.R
  - Analyzes base angle vs size for INTACT road moai only
  - Filters for moai with n.of.pieces == 1
  - Key finding: No correlation despite 20-fold size variation

Figure_11.R
  - Models transport failure hypothesis expectations
  - Shows expected distribution if moai failed randomly
  - Key finding: Concentration near quarry expected

Figure_12.R
  - Shows actual observed distribution using real distance data
  - Uses data from create_distance_dataset.R
  - Key finding: 53.8% within 2km matches prediction

Figure_13.R
  - Analyzes moai size vs transport distance
  - Tests if larger moai traveled shorter distances
  - Key finding: No correlation - size wasn't limiting

Figure_S1.R
  - Supplemental figure with 6-panel comprehensive analysis
  - Compares ceremonial vs transport failure hypotheses
  - Generates both Figure S1 and Table S1 results
  - Key finding: All tests support transport failure hypothesis

Table_1_moai_orientation_analysis.R
  - Analyzes orientation of road moai relative to transport paths
  - Tests if moai faces align with road directions
  - Key finding: Moai orientations consistent with transport positions

--------------------------------------------------------------------------------
SUPPORT SCRIPTS
--------------------------------------------------------------------------------

create_distance_dataset.R
  - Calculates distances from Rano Raraku quarry
  - Must be run before Figures 11, 12, 13
  - Creates: moai_with_distances.csv, road_moai_distances.csv

run_all_figures.R
  - Runs all figure scripts in sequence
  - Handles distance dataset creation automatically
  - Shows success/failure for each figure

test_environment.R
  - Checks R version and package availability
  - Verifies data files are present
  - Reports any missing dependencies

setup.R
  - Installs all required R packages
  - Run if packages are missing

package_loader.R
  - Helper function for loading packages
  - Used by figure scripts internally

init_packrat.R (OPTIONAL)
  - Initializes packrat for package version control
  - Only needed for exact reproducibility

--------------------------------------------------------------------------------
DATA REQUIREMENTS
--------------------------------------------------------------------------------

Scripts expect data files in: ../data/

Required files:
- VanTilburgData.xlsx         (moai measurements)
- Road Moai Data.xlsx         (road moai with coordinates)
- MOAI_DATABASE_PUBLIC.xlsx   (comprehensive database)
- all_moai_combined.csv       (merged dataset)
- Table_1_road_moai_orientation.xlsx (road moai orientation data)

Generated files (created by create_distance_dataset.R):
- moai_with_distances.csv
- road_moai_distances.csv

--------------------------------------------------------------------------------
TROUBLESHOOTING
--------------------------------------------------------------------------------

"No data file found" error:
  - Make sure you're in the scripts/ directory
  - Check that data files exist in ../data/

"object 'n.of.pieces' not found":
  - Column name uses dots not spaces: n.of.pieces

Missing distance data for Figures 11-13:
  - Run create_distance_dataset.R first

Package installation fails:
  - Try: Rscript setup.R
  - Or manually: install.packages("package_name")

--------------------------------------------------------------------------------
ARCHIVED SCRIPTS
--------------------------------------------------------------------------------

The archive/ subdirectory contains:
- Older versions of figure scripts
- Alternative analysis approaches
- Development versions for testing
- Previous implementations before optimization
These are kept for reproducibility but should not be used for final figures.

Key archived scripts:
- Figure_2_alternative_analyses.R - Alternative statistical approaches
- Figure_2_clean.R, Figure_2_diagnostic.R - Development versions
- Figure_3_diagnostic.R, Figure_3_fixed.R - Debugging versions
- Figure_5_*.R - Multiple iterations of base angle analysis
- Figure_12.R, Figure_13.R, Figure_13_old.R - Previous versions
- init_packrat_enhanced.R - Enhanced packrat initialization

--------------------------------------------------------------------------------
NOTES
--------------------------------------------------------------------------------

- All scripts use explicit package::function() notation for clarity
- Scripts will overwrite existing output files when rerun
- Figure outputs follow standardized naming (see OUTPUT_NAMING_STANDARD.md)
- Results are reproducible (no random seeds needed after recent updates)

For questions or issues, see the main README.md in the project root.

================================================================================