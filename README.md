## Auto-ICell-Matlab-codes
Auto-ICell: An Open-Source AI-Enhanced Droplet Microfluidics Platform for High-Throughput Single-Cell Analysis

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
