# Archived Python Scripts

This folder contains older iterations of the moai 3D analysis scripts that were created during development.

## Contents

### Early Versions
- `moai_analyzer.py` - Original basic version
- `moai_analyzer_corrected.py` - Version with corrected coordinate system
- `moai_analyzer_enhanced.py` - Version with enhanced surface rendering

### Alternative Versions
- `moai_analyzer_plotly_simple.py` - Simplified version of plotly visualization

## Current Main Versions

The main versions in `python/` are:
- `moai_analyzer_final.py` - Complete 3D analysis with matplotlib visualization
- `moai_analyzer_plotly.py` - Interactive 3D visualization with plotly (includes kaleido fixes)
- `moai_analyzer_headless.py` - Server-friendly version without display

## Key Improvements in Final Versions

1. Proper output path handling (output_helper.py)
2. Fixed font style issues in plotly (using HTML tags for italic)
3. Kaleido package included for static export
4. Correct paths to data files (../data/SimplifiedMoai.obj)
5. Better base outline detection and visualization