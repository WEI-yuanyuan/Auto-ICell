# Auto-ICell-Matlab-codes
Auto-ICell: An Open-Source AI-Enhanced Droplet Microfluidics Platform for High-Throughput Single-Cell Analysis

# Requirements
MATLAB R2018a or later
Image Processing Toolbox
Optional: mtimesx for fast matrix operations

## Folder Structure

Project Root/
|
├── RGB-based image analysis/
| ├── Sample frames/ # Input .tif images
| ├── Output/ # ROI masks, results
| ├── plot_distribution.m # Main RGB analysis script
| ├── rgb_deconvolve.m # RGB color separation
| └── show2d.m # Image display
|
├── HSV-based image analysis and image register/
| ├── Sample3/, sample2/ # Input image sequences
| ├── Output/ # Aligned & segmented results
| ├── test2.m # HSV segmentation and analysis
| ├── test2_vBB.m # Registration + segmentation
| ├── calculateCrossCorrelationMap.m
| ├── getMaxByCentroid.m
| └── show2d.m

yaml

Copy

---

## Usage

1. Place `.tif` images into the corresponding `Sample*` folder.
2. Run one of the main scripts based on your task:

```matlab
% RGB-based analysis
plot_distribution

% HSV-based segmentation
test2

% HSV + registration
test2_vBB
Outputs
ROI-enhanced images and masks
Area statistics and intensity distribution plots
Registered image sequences
Requirements
MATLAB R2018a or later
Image Processing Toolbox
Optional: mtimesx for fast matrix operations


## License
This project is intended for academic and research use. Please contact the authors for permission if you plan to use it for commercial purposes.
