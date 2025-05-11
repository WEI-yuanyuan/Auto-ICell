import sys
import cv2
import numpy as np
import matplotlib.pyplot as plt
from segment_anything import sam_model_registry, SamAutomaticMaskGenerator

def show_bbox(image, bbox, thickness=2): # Function to draw bounding boxes
    x1, y1, width, height = bbox
    x2 = x1 + width
    y2 = y1 + height
    color = (0, 255, 0)  # Green color for bounding box
    image = cv2.rectangle(image, (x1, y1), (x2, y2), color, thickness)
    return image

# Load the model
sys.path.append("..")
sam_checkpoint = "sam_vit_h_4b8939.pth"
model_type = "vit_h"
device = "cpu" # Change this to "cuda" to use the GPU
sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
sam.to(device=device)
mask_generator = SamAutomaticMaskGenerator(sam)

# Load the image
tarImg = cv2.imread('input_noise/1_noisy_image_gaussian_100_s&p.png')
tarImg_rgb = cv2.cvtColor(tarImg, cv2.COLOR_BGR2RGB)

# # Generate masks
annotations = mask_generator.generate(tarImg_rgb)
# print(annotations)
ann = annotations[1]
uint8_mask = (ann['segmentation'] * 255).astype(np.uint8)
# bbox = ann['bbox']
# tarImg_rgb = show_bbox(tarImg_rgb, bbox)

# Apply the mask to the image
for i in range(3):
    tarImg_rgb[:, :, i] = np.where(uint8_mask == 255, tarImg_rgb[:, :, i], tarImg_rgb[:, :, i] * 0)

# Convert back to BGR for OpenCV compatibility
tarImg_bgr = cv2.cvtColor(tarImg_rgb, cv2.COLOR_RGB2BGR)

# Assuming 'ann' contains the annotation you're interested in
filtered_annotation = {
    'area': ann['area'],
    'predicted_iou': ann['predicted_iou'],
    'stability_score': ann['stability_score']
}

# Save the filtered annotation to a TXT file
output_path = 'filtered_annotation.txt'
with open(output_path, 'w') as f:
    for key, value in filtered_annotation.items():
        f.write(f'{key}: {value}\n')

print(f"Filtered annotation saved to {output_path}")

# Display the image
cv2.imshow('Image with Mask and Bounding Box', tarImg_bgr)
cv2.waitKey(0)
cv2.destroyAllWindows()

# Save the modified image
cv2.imwrite('1_50_DL.tif', tarImg_bgr)
# for ann in annotations:
#     bbox = ann['bbox']
#     tarImg_rgb = show_bbox(tarImg_rgb, bbox)
# # Convert back to BGR for OpenCV compatibility
# tarImg_bgr = cv2.cvtColor(tarImg_rgb, cv2.COLOR_RGB2BGR)

# # Display the image
# cv2.imshow('Image with Mask and Bounding Box', tarImg_bgr)
# cv2.waitKey(0)
# cv2.destroyAllWindows()

