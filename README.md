# Auto-ICell-Matlab-codes
Auto-ICell: An Open-Source AI-Enhanced Droplet Microfluidics Platform for High-Throughput Single-Cell Analysis

# Requirements
MATLAB R2018a or later
Image Processing Toolbox
Optional: mtimesx for fast matrix operations

# Folder Structure
Project Root/
|
├── RGB-based image analysis/
|   ├── Output/
|   │   ├── channel_region.tif
|   │   └── parameters.mat
|   ├── Sample frames/
|   │   └── *.tif              # Input sample frames
|   ├── plot_distribution.m
|   ├── rgb_deconvolve.m
|   └── show2d.m
|
├── HSV-based image analysis and image register/
|   ├── Output/
|   │   ├── Aligned/
|   │   ├── Segmented/
|   │   ├── Segmented_Plasma/
|   │   └── Segmented_RBC/
|   ├── sample2/
|   ├── Sample3/
|   │   └── *.tif              # Timestamped image frames
|   ├── test2.m
|   ├── test2_vBB.m
|   ├── calculateCrossCorrelationMap.m
|   ├── getMaxByCentroid.m
|   └── show2d.m

---

## Key Features

- RGB-based segmentation and color deconvolution
- HSV-based plasma and RBC segmentation
- Image registration using normalized cross-correlation
- Intensity distribution plotting over time or space
- Batch processing of `.tif` microscopy images
- Custom color separation using stain vectors

---

## RGB-Based Image Analysis

**Location**: `RGB-based image analysis/`

### Main Script: `plot_distribution.m`

- Performs background correction over all frames
- Detects the analysis region based on red channel contrast
- Applies color deconvolution using `rgb_deconvolve.m`
- Plots and saves spatial intensity distributions of RBC (red) and plasma (blue)

### Supporting Functions

- `rgb_deconvolve.m`: Separates RGB signals into independent stain channels
- `show2d.m`: Utility to visualize grayscale or magnitude images

### Inputs

- `.tif` image frames in `Sample frames/`

### Outputs

- ROI-enhanced images: `Output/ROI-*.tif`
- Distribution plots: `Output/Distribution-*.tif`
- Detected region mask: `Output/channel_region.tif`
- Background data: `Output/parameters.mat`

---

## HSV-Based Image Analysis and Registration

**Location**: `HSV-based image analysis and image register/`

### Main Scripts

#### `test2_vBB.m` (Image Registration and Segmentation)

- Registers image sequence based on S-channel similarity
- Defines channel region by overlapping top 10 frames
- Segments RBC and plasma by HSV saturation thresholding
- Saves segmented frames and logs areas

#### `test2.m` (Segmentation and Intensity Evaluation)

- Converts RGB to grayscale to extract RBC masks
- Computes normalized red intensity over time
- Applies color deconvolution on RBC/plasma channels
- Plots intensity profiles and differential values

### Registration Functions

- `calculateCrossCorrelationMap.m`: Computes cross-correlation map using FFT
- `getMaxByCentroid.m`: Finds peak offset using centroid of the correlation peak

### Visualization

- `show2d.m`: Displays segmentation and region definition results
- Saved plots include area curves and RBC/plasma ratio over time

### Outputs

- `Aligned/`: Registered image frames
- `Segmented_RBC/`, `Segmented_Plasma/`: Highlighted masks
- `AreaRBCPlasma.fig`, `RatioOfArea.fig`: Area statistics visualizations

---

## Example Workflow

1. Place your `.tif` image sequence into `RGB-based image analysis/Sample frames/` or `HSV-based image analysis and image register/Sample3/`
2. For RGB processing, run:

```matlab
plot_distribution

# License
This project is intended for academic and research use. Please contact the authors for permission if you plan to use it for commercial purposes.
