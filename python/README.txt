================================================================================
                    PYTHON 3D PHYSICS ANALYSIS FOR MOAI STATUES
================================================================================

This directory contains Python scripts for analyzing the 3D physics properties
of moai statues, particularly center of mass and stability characteristics.

--------------------------------------------------------------------------------
QUICK START
--------------------------------------------------------------------------------

1. Install dependencies (choose one method):

   OPTION A: Automated setup (like R's packrat):
      python setup_python.py
      source activate_moai.sh  # Linux/Mac
      activate_moai.bat        # Windows

   OPTION B: Manual with exact versions:
      pip install -r requirements-lock.txt

   OPTION C: Manual with minimum versions:
      pip install -r requirements.txt

2. Run the main 3D analysis (creates Figure_4):
    python moai_analyzer_final.py

3. Create interactive visualization:
    python moai_analyzer_plotly.py

--------------------------------------------------------------------------------
MAIN ANALYSIS SCRIPTS
--------------------------------------------------------------------------------

moai_analyzer_final.py (PRIMARY)
  - Complete 3D center of mass analysis using matplotlib
  - Creates Figure_4_moai_analysis_600dpi.png with both panels:
    * Panel A: 3D view with center of mass visualization
    * Panel B: Top-down view showing base outline and COM projection
  - Publication-quality output (PNG and SVG)
  - Key findings: COM at 40.6% height, 4.9° forward lean

moai_analyzer_plotly.py
  - Interactive 3D visualization using Plotly
  - Creates Figure_4_moai_analysis_interactive.html
  - Rotatable, zoomable 3D model for exploration
  - Shows single 3D view (no Panel B needed for interactive)
  - Best for presentations and web viewing

output_helper.py
  - Utility module for managing output paths
  - Ensures all figures are saved to ../figures/ directory
  - Used internally by both analysis scripts

--------------------------------------------------------------------------------
OUTPUT FILES (in ../figures/)
--------------------------------------------------------------------------------

From moai_analyzer_final.py:
  - Figure_4_moai_analysis_600dpi.png    (Two-panel static figure)
  - Figure_4_moai_analysis.svg           (Vector format)

From moai_analyzer_plotly.py:
  - Figure_4_moai_analysis_interactive.html  (Interactive 3D)
  - Figure_4_moai_analysis_plotly_600dpi.png (Static 3D only)
  - Figure_4_moai_analysis_plotly.svg        (Vector 3D only)

--------------------------------------------------------------------------------
DATA REQUIREMENTS
--------------------------------------------------------------------------------

3D Model: ../data/SimplifiedMoai.obj
  - Format: Wavefront OBJ
  - Vertices: 5,150
  - Faces: 10,296 triangles
  - Coordinate system: Y=vertical, X=width, Z=depth

--------------------------------------------------------------------------------
KEY FINDINGS
--------------------------------------------------------------------------------

Center of Mass Analysis:
  - Height: 40.6% of total (2.99m from base on 7.35m moai)
  - Forward lean angle: 4.9°
  - Distance to front edge: 14cm
  - COM offset from base center: 23cm backward, 34cm left

These measurements support the walking hypothesis - moai were designed with
forward-leaning center of mass to facilitate rocking transport.

--------------------------------------------------------------------------------
REPRODUCIBILITY (PYTHON EQUIVALENT TO R'S PACKRAT)
--------------------------------------------------------------------------------

We provide multiple options for reproducible environments:

1. setup_python.py (RECOMMENDED - Most like packrat):
   - Automated virtual environment creation
   - Installs exact package versions from requirements-lock.txt
   - Creates activation helpers (activate_moai.sh/bat)
   - Update lock file with: python setup_python.py --freeze

2. requirements-lock.txt (Like packrat.lock):
   - Contains exact package versions
   - Ensures identical results across machines
   - Use: pip install -r requirements-lock.txt

3. Conda environment.yml:
   - Includes Python version (3.10.13)
   - Use: conda env create -f environment.yml

4. Pipenv (Pipfile):
   - Modern dependency management
   - Use: pipenv install

5. Poetry (pyproject.toml):
   - Advanced dependency resolution
   - Use: poetry install

See PYTHON_REPRODUCIBILITY.md for detailed instructions.

--------------------------------------------------------------------------------
DEPENDENCIES
--------------------------------------------------------------------------------

Core packages with locked versions:
  - numpy==1.24.4        (numerical computing)
  - trimesh==4.0.10      (3D mesh processing)
  - matplotlib==3.8.2    (static visualizations)
  - plotly==5.18.0       (interactive visualizations)
  - scipy==1.11.4        (ConvexHull for base outline)

Optional:
  - kaleido==0.2.1       (static export from plotly)

For exact reproducibility: pip install -r requirements-lock.txt
For latest compatible: pip install -r requirements.txt

--------------------------------------------------------------------------------
ARCHIVED FILES
--------------------------------------------------------------------------------

The archive_old_versions/ folder contains development versions:
  - calculate_lean_angle.py    (Initial angle calculations)
  - test_base_outline.py       (Base detection testing)
  - test_integration.py        (Environment testing)
  - moai_analyzer_headless.py  (Server-side version)

--------------------------------------------------------------------------------
INTEGRATION WITH R ANALYSIS
--------------------------------------------------------------------------------

These Python scripts generate Figure 4 for the main paper, providing 3D
physics analysis that complements the statistical analyses in R:

R Scripts (statistical analysis):
  - Figure_2.R, Figure_3.R, etc. - morphometric comparisons
  - Figure_13.R - transport success analysis

Python Scripts (3D physics):
  - Figure_4 - center of mass and stability analysis

Together they demonstrate that moai morphology (analyzed in R) and physics
(analyzed in Python) both support the walking transport hypothesis.

--------------------------------------------------------------------------------
COORDINATE SYSTEM NOTES
--------------------------------------------------------------------------------

Model coordinates:
  - Y axis: Vertical (height from base to head)
  - X axis: Width (side to side)
  - Z axis: Depth (back to front)
  - Front faces positive Z direction

Scaling:
  - Scale factor: 4.894 (converts model units to meters)
  - Target height: 7.35m (average road moai)

Base detection:
  - Vertices within 5cm of ground (Y < base_y + 0.05)
  - Slice at 10cm for cleaner outline
  - Grid-based boundary detection (25x25 resolution)

================================================================================