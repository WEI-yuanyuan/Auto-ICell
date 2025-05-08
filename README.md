
# Auto-ICell: An Open-Source AI-Enhanced Droplet Microfluidics Platform for High-Throughput Single-Cell Analysis

Auto-ICell is an open-source tool designed to streamline and enhance single-cell analysis in droplet microfluidic systems using state-of-the-art AI-based segmentation models. This platform leverages the powerful **Segment Anything Model (SAM)** to automatically detect and segment cells or features from noisy microscopic images, facilitating high-throughput workflows.

## 🔍 Features

- ✅ Automatic segmentation of microscopy images using Meta's SAM
- ✅ Bounding box visualization for identified cells or regions
- ✅ Noise-robust mask generation
- ✅ Masked region extraction for downstream analysis
- ✅ Export of key annotation metrics (area, IoU, stability)
- ✅ Support for noisy input images (e.g., Gaussian, Salt-and-Pepper noise)

## 🧠 Model

The segmentation is powered by the `vit_h` variant of the [Segment Anything Model (SAM)](https://github.com/facebookresearch/segment-anything), using a pre-trained checkpoint.

## 📂 File Structure

```
├── input_noise/
│   └── 1_noisy_image_gaussian_100_s&p.png   # Input noisy microscopy image
├── sam_vit_h_4b8939.pth                     # Pre-trained SAM model checkpoint
├── filtered_annotation.txt                  # Output annotation metrics
├── 1_50_DL.tif                              # Output image with applied mask
└── main.py                                  # Main Python script
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Auto-ICell.git
cd Auto-ICell
```

### 2. Install Dependencies

Ensure you have Python 3.7+ installed. Then, install the required packages:

```bash
pip install numpy opencv-python matplotlib torch torchvision
```

Also, clone and set up the [Segment Anything repository](https://github.com/facebookresearch/segment-anything) and place the `sam_vit_h_4b8939.pth` checkpoint in the project root.

### 3. Run the Script

```bash
python main.py
```

This will:
- Load the noisy microscopy image
- Apply SAM segmentation
- Generate and apply a binary mask
- Save a filtered version of the image with only masked regions
- Export selected annotation metrics to `filtered_annotation.txt`

### 4. Output

- **Image Preview**: The masked result is shown in a window (if OpenCV GUI is supported).
- **Saved Image**: Processed image is saved as `1_50_DL.tif`.
- **Annotation Metrics**: Key metadata about the segmented region is saved to `filtered_annotation.txt`.

## ⚙️ Configuration

- You can switch between CPU and GPU by modifying the `device` variable:
  ```python
  device = "cpu"  # or "cuda" if using GPU
  ```

- To change the input image, replace `input_noise/1_noisy_image_gaussian_100_s&p.png` with your file path.

## 📝 Sample Annotation Output

```
area: 16456
predicted_iou: 0.9321
stability_score: 0.845
```

## 📌 TODO

- [ ] Support batch image processing
- [ ] Integrate GUI for image input/output
- [ ] Add CSV export for mask statistics
- [ ] Extend compatibility to multi-class segmentation

## 📄 License

This project is released under the MIT License.
