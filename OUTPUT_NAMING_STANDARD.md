# Output Naming Standards

This document defines the standardized naming conventions for all figure outputs to ensure consistency when scripts are rerun.

## ✅ Current Naming Standards (Already Implemented)

### R Figure Outputs

Each R script generates files with these exact names:

#### **Figure 2** (`scripts/Figure_2.R`)
- `Figure_2_moai_ratio_comparison.svg`
- `Figure_2_moai_ratio_comparison.png` (600 dpi)
- `Figure_2_moai_ratio_comparison_preview.png` (150 dpi)

#### **Figure 3** (`scripts/Figure_3.R`)
- `Figure_3_com_distribution.svg`
- `Figure_3_com_distribution.png` (600 dpi)
- `Figure_3_com_distribution_preview.png` (150 dpi)
- `Figure_3_com_data.csv`

#### **Figure 5** (`scripts/Figure_5.R`)
- `Figure_5_intact_road_moai.svg`
- `Figure_5_intact_road_moai.png` (600 dpi)
- `Figure_5_intact_road_moai_preview.png` (150 dpi)
- `Figure_5_intact_road_moai.pdf`
- `Figure_5_intact_road_moai_data.csv`
- `Figure_5_intact_road_moai_stats.csv`

#### **Figure 11** (`scripts/Figure_11.R`)
- `Figure_11_transport_failure_expectation.svg`
- `Figure_11_transport_failure_expectation.png` (600 dpi)
- `Figure_11_transport_failure_expectation_preview.png` (150 dpi)
- `Figure_11_transport_failure_expectation.pdf`

#### **Figure 12** (`scripts/Figure_12.R`)
- `Figure_12_distribution_analysis.png` (600 dpi)
- `Figure_12_distribution_analysis_preview.png` (150 dpi)
- `Figure_12_distribution_analysis.pdf`
- `Figure_12_distribution_ggplot.svg`
- `Figure_12_statistics.csv`
- `Figure_12_histogram_data.csv`

#### **Figure 13** (`scripts/Figure_13.R`)
- `Figure_13_size_distance_analysis.png` (600 dpi)
- `Figure_13_size_distance_analysis_preview.png` (150 dpi)
- `Figure_13_size_distance_analysis.pdf`
- `Figure_13_analysis_data.csv`
- `Figure_13_phase_statistics.csv`
- `Figure_13_summary_statistics.csv`
- `Figure_13_caption.txt`

### Python 3D Analysis Outputs (Figure 4)

#### **moai_analyzer_final.py**
- `Figure_4_moai_analysis_600dpi.png`
- `Figure_4_moai_analysis.svg`

#### **moai_analyzer_plotly.py**
- `Figure_4_moai_analysis_interactive.html`
- `Figure_4_moai_analysis_plotly_600dpi.png`
- `Figure_4_moai_analysis_plotly.svg`

## Naming Convention Rules

1. **R Figures**: `Figure_[N]_[descriptive_name].[ext]`
   - Always start with uppercase "Figure_"
   - Use underscores between words
   - Include figure number (2, 3, 5, 11, 12, 13)
   - Descriptive name reflects content

2. **Python Outputs**: `Figure_4_moai_analysis_[variant].[ext]`
   - Always start with "Figure_4_moai_analysis"
   - Optional variant: "plotly", "interactive"
   - High-res PNGs include "_600dpi" suffix

3. **File Types**:
   - `.svg` - Vector graphics
   - `.png` - Raster at 600 dpi (high-res)
   - `_preview.png` - Raster at 150 dpi (preview)
   - `.pdf` - PDF format (selected figures)
   - `.csv` - Data files
   - `.html` - Interactive visualizations

## Important Notes

- **No changes needed** - All scripts already use these standardized names
- **Overwriting**: When scripts are rerun, they will overwrite existing files with the same names
- **No version numbers**: We don't append dates or version numbers
- **Consistent paths**: All outputs go to `../figures/` from script location

## Testing Compliance

To verify naming standards are maintained:

```bash
# R scripts
cd scripts
Rscript Figure_2.R  # Check output names match standard

# Python scripts  
cd python
python moai_analyzer_final.py  # Check output names match standard
```

All current scripts comply with these standards and will consistently produce the same filenames when rerun.