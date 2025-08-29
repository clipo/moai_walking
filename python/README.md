# Python 3D Physics Analysis

This directory contains Python scripts for analyzing the 3D physics properties of moai statues, particularly center of mass and stability characteristics.

## Reproducibility (Python Equivalent to R's packrat)

We provide multiple options for creating reproducible Python environments, similar to R's packrat:

### Option 1: Automated Setup Script (Recommended - Most Like packrat)

```bash
# Initial setup - creates virtual environment with locked package versions
python setup_python.py

# Activate the environment
source activate_moai.sh  # Linux/Mac
activate_moai.bat        # Windows

# Run analysis
python moai_analyzer_final.py
python moai_analyzer_plotly.py

# Update lock file after package changes
python setup_python.py --freeze
```

### Option 2: Using requirements-lock.txt (Manual)

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install exact package versions (like packrat.lock)
pip install -r requirements-lock.txt

# Or install minimum versions for compatibility
pip install -r requirements.txt
```

### Option 3: Conda Environment (environment.yml)

```bash
# Create environment with exact Python and package versions
conda env create -f environment.yml
conda activate hotuiti

# Update after changes
conda env update -f environment.yml
```

### Option 4: Pipenv (Most Similar to packrat)

```bash
# Install pipenv
pip install pipenv

# Install from Pipfile with locked versions
pipenv install

# Run scripts in isolated environment
pipenv run python moai_analyzer_final.py

# Update lock file (like packrat::snapshot())
pipenv lock
```

## Quick Start (Standard Installation)

```bash
# Install dependencies
pip install -r requirements.txt

# Run analysis
python moai_analyzer_final.py       # Main 3D analysis
python moai_analyzer_plotly.py      # Interactive visualization
python calculate_lean_angle.py      # Detailed lean calculations
```

### Using Docker

```bash
# Build the Docker image
docker build -t moai-3d-analysis .

# Run with docker-compose (recommended)
docker-compose up

# Or run specific scripts
docker-compose run moai-3d-analysis python moai_analyzer_plotly.py
docker-compose run moai-3d-analysis python calculate_lean_angle.py

# Run without docker-compose
docker run -v $(pwd)/../data:/data:ro -v $(pwd)/../figures:/figures moai-3d-analysis
```

## Output Files

All outputs are saved to:
- **Local execution**: `../figures/` directory
- **Docker execution**: `/figures/` (mapped to `../figures/`)

Generated files include:
- `moai_analysis_final_600dpi.png` - High-resolution visualization
- `moai_analysis_final.svg` - Vector format
- `moai_analysis_interactive.html` - Interactive 3D model (from plotly script)

## Scripts Overview

| Script | Purpose | Key Output |
|--------|---------|------------|
| `moai_analyzer_final.py` | Main 3D COM analysis with matplotlib | PNG & SVG visualizations |
| `moai_analyzer_plotly.py` | Interactive 3D visualization | HTML interactive model |
| `moai_analyzer_headless.py` | Server-friendly version (no display) | Analysis results only |
| `calculate_lean_angle.py` | Detailed lean angle calculations | Numerical results |
| `test_base_outline.py` | Base footprint verification | Base shape analysis |
| `test_integration.py` | Verify setup and dependencies | Installation check |

## Dependencies

Core packages (see `requirements.txt`):
- `trimesh==4.0.10` - 3D mesh processing
- `numpy==1.24.4` - Numerical computations
- `scipy==1.11.4` - Scientific computing
- `matplotlib==3.8.2` - 2D/3D plotting
- `plotly==5.18.0` - Interactive visualizations
- `kaleido==0.2.1` - Static image export from plotly

## Data Requirements

The scripts expect the 3D model at: `../data/SimplifiedMoai.obj`

This is a simplified mesh with:
- 5,150 vertices
- 10,296 triangular faces
- Scale: 1 unit = 4.894 meters (actual moai height: 7.35m)

## Docker Notes

The Docker setup includes:
- All required system dependencies (gcc, g++, libgeos-dev, libspatialindex-dev)
- Non-interactive backend for matplotlib (Agg)
- Proper volume mounts for data access and output saving

Volume mounts in docker-compose.yml:
- `../data:/data:ro` - Read-only access to 3D model
- `../figures:/figures` - Output directory for generated files

## Troubleshooting

1. **"No module named 'trimesh'"**: Install dependencies with `pip install -r requirements.txt`
2. **"Could not save static images"**: Already fixed - kaleido is now included
3. **Display issues**: Use `moai_analyzer_headless.py` or run in Docker
4. **File not found**: Ensure you're running from the `python/` directory