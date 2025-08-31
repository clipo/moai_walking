# Archived R Scripts

This folder contains older or alternative versions of figure generation scripts that were created during development but are no longer the primary versions.

## Contents

### Figure 2 Versions
- `Figure_2_diagnostic.R` - Diagnostic version with additional checks
- `Figure_2_clean.R` - Version using explicit package::function() notation
- `Figure_2_alternative_analyses.R` - Alternative statistical approaches

### Figure 3 Versions
- `Figure_3_diagnostic.R` - Diagnostic version with data exploration
- `Figure_3_fixed.R` - Earlier fix for distance calculations

### Figure 5 Versions
- `Figure_5.R` - Original version (before intact moai filtering)
- `Figure_5_clean.R` - Clean version with explicit notation
- `Figure_5_data_exploration.R` - Data exploration version
- `Figure_5_improved.R` - Intermediate improved version

### Figure 12 & 13 Versions
- `Figure_12.R` - Original version with demo data generation
- `Figure_13.R` - Original version with demo data generation

## Note

The main versions in `scripts/` are the latest, tested versions that:
- Use real data (no demo/synthetic data generation)
- Include proper error handling
- Have been verified to produce correct results
- Figure_5.R now filters for intact road moai only (n.of.pieces == 1)
- Figure_12.R and Figure_13.R now use the distance datasets from create_distance_dataset.R