# Data Documentation - Walking Moai Hypothesis Project

This document describes all data files used in the Walking Moai Hypothesis analysis. The data includes measurements, locations, and 3D models of Easter Island moai (statues).

## Primary Source Data Files

### 1. VanTilburgData.xlsx
- **Size**: 131.6 KB
- **Source**: Van Tilburg, J.A. (1986) dissertation data
- **Description**: Comprehensive moai measurements database containing physical dimensions for hundreds of moai
- **Key Fields**:
  - Moai ID numbers
  - Physical measurements (height, width, depth)
  - Base-to-shoulder width ratios
  - Location codes
  - Condition/completeness indicators
- **Used By**: Figure_2.R, Figure_3.R, general moai analysis

### 2. MOAI_DATABASE_PUBLIC.xlsx
- **Size**: 493.4 KB
- **Source**: Schumacher, Z. (2013). A geo-spatial database of the monumental statuary (moai) of Easter Island, Chile. MA Thesis, California State University, Long Beach.
- **Description**: Most comprehensive moai database with extensive information including locations, measurements, and archaeological context from Schumacher's geospatial analysis
- **Key Fields**:
  - Complete moai inventory with IDs
  - GPS coordinates (where available)
  - Physical measurements
  - Archaeological site information
  - Historical documentation
  - Geospatial attributes
- **Used By**: create_distance_dataset.R, comprehensive analyses

### 3. Road Moai Data.xlsx
- **Size**: 13.2 KB
- **Source**: Field surveys and GPS measurements
- **Description**: Specific data for moai found along ancient roads with GPS coordinates and base angle measurements
- **Key Fields**:
  - Moai ID
  - GPS latitude and longitude
  - Base angle measurements (degrees)
  - Road association
  - Transport status indicators
- **Used By**: Figure_5.R (base angle analysis), distance calculations

### 4. Table_1_road_moai_orientation.xlsx
- **Size**: 9.6 KB
- **Source**: Field measurements and analysis
- **Description**: Orientation data for road moai relative to transport paths
- **Key Fields**:
  - Moai ID
  - Face orientation (degrees)
  - Road direction
  - Alignment angle
  - Notes on position
- **Used By**: Table_1_moai_orientation_analysis.R

## Merged/Combined Datasets

### 5. all_moai_combined.csv
- **Size**: 5.9 KB
- **Source**: Merged from VanTilburgData.xlsx and MOAI_DATABASE_PUBLIC.xlsx
- **Description**: Unified dataset combining measurements from multiple sources with standardized field names
- **Key Fields**:
  - Moai ID (standardized)
  - Location code (1-6 = ahu sites, 8 = roads)
  - Physical measurements
  - n.of.pieces (intactness indicator: 1 = intact)
  - GPS coordinates (where available)
- **Used By**: Most R analysis scripts, primary working dataset

## Generated Distance Datasets

These files are created by running `scripts/create_distance_dataset.R`:

### 6. moai_with_distances.csv
- **Size**: 6.4 KB
- **Generated From**: all_moai_combined.csv + distance calculations
- **Description**: All moai with calculated distances from Rano Raraku quarry geocentroid
- **Key Fields**:
  - All fields from all_moai_combined.csv
  - distance_from_quarry (meters)
  - Quarry geocentroid: -27.125175°, -109.288170°
- **Used By**: Figure_11.R, Figure_12.R, Figure_13.R

### 7. road_moai_distances.csv
- **Size**: 3.9 KB
- **Generated From**: moai_with_distances.csv filtered for road moai
- **Description**: Subset of road moai (location = 8) with distance measurements
- **Key Fields**:
  - Moai ID
  - GPS coordinates
  - distance_from_quarry (meters)
  - Physical measurements
- **Total Records**: 84 road moai
- **Used By**: Figure_12.R, Figure_13.R, distance analysis

### 8. road_moai_zones.csv
- **Size**: 250 bytes
- **Generated From**: road_moai_distances.csv analysis
- **Description**: Summary of road moai distribution by distance zones
- **Key Fields**:
  - Distance zone (0-2km, 2-4km, 4-6km, etc.)
  - Count of moai in each zone
  - Percentage of total
- **Used By**: Figure_11.R, Figure_12.R (transport failure model)

## 3D Model Data

### 9. SimplifiedMoai.obj
- **Size**: 678.9 KB
- **Format**: Wavefront OBJ 3D mesh
- **Description**: Simplified 3D mesh model of a representative moai statue
- **Specifications**:
  - Vertices: 5,150
  - Faces: 10,296 triangles
  - Scale: 1 unit = 4.894 meters
  - Actual moai height: 7.35 meters
  - Coordinate system: Y=vertical (height), X=width, Z=depth
- **Used By**: Python 3D analysis scripts (moai_analyzer_final.py, moai_analyzer_plotly.py)

## Topographical/Slope Data

### 10. moai_road_slope_from_raraku.xlsx
- **Size**: 64.5 KB
- **Source**: GPS elevation measurements along roads
- **Description**: Elevation and slope data for the main road from Rano Raraku quarry to the south coast
- **Key Fields**:
  - Distance along road (meters)
  - Elevation (meters above sea level)
  - Slope percentage
  - GPS waypoints
- **Used By**: Figure_6.R (elevation profile analysis)

### 11. southcoast_road_only_slope.xlsx
- **Size**: 131.9 KB
- **Source**: Detailed GPS survey of south coast road segment
- **Description**: High-resolution elevation data for the south coast road section
- **Key Fields**:
  - Distance markers
  - Elevation profile
  - Slope calculations
  - Road condition notes
- **Used By**: Figure_6.R (detailed slope analysis)

## Data Processing Notes

### Location Codes
- **1-6**: Ahu sites (ceremonial platforms with completed moai)
- **7**: Quarry sites at Rano Raraku
- **8**: Roads/transport routes (moai in transport)

### Intactness Indicator
- **n.of.pieces = 1**: Intact moai
- **n.of.pieces > 1**: Broken/fragmented moai
- Note: Column name uses dots (n.of.pieces) not spaces due to R naming conventions

### Distance Calculations
- **Reference Point**: Rano Raraku quarry geocentroid
- **Coordinates**: -27.125175° latitude, -109.288170° longitude
- **Method**: Euclidean approximation suitable for Easter Island's small area
- **Formula**: 
  - lat_diff = (lat2 - lat1) × 111,000 meters
  - lon_diff = (lon2 - lon1) × 99,000 meters (at Easter Island latitude)
  - distance = √(lat_diff² + lon_diff²)

### Data Quality Notes
- GPS coordinates are available for most road moai but not all ahu moai
- Base angle measurements are primarily available for intact road moai
- Some moai have multiple measurement records from different surveys
- The quarry geocentroid was calculated from 318 bedrock quarry moai locations

## File Update History
- **August 2024**: Added 33 additional road moai IDs, updated to 84 total
- **August 2024**: Corrected quarry center to geocentroid calculation
- **January 2025**: Added Table_1_road_moai_orientation.xlsx for orientation analysis

## Usage Guidelines
1. Always run `create_distance_dataset.R` before using distance-dependent analyses
2. Check for intact moai using `n.of.pieces == 1` filter
3. Use location code 8 to filter for road moai
4. Verify GPS coordinates are present before distance calculations
5. The 3D model (SimplifiedMoai.obj) represents a typical moai, not a specific statue

## Citation
When using these datasets, please cite:
- Van Tilburg, J.A. (1986) for VanTilburgData.xlsx
- Schumacher, Z. (2013). A geo-spatial database of the monumental statuary (moai) of Easter Island, Chile. MA Thesis, California State University, Long Beach. (for MOAI_DATABASE_PUBLIC.xlsx)
- Lipo, C. and Hunt, T. (2025) for compiled and processed datasets