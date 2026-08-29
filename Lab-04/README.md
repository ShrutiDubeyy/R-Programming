\# Lab 4 - Image Recognition and Classification using R



\## Objective



To perform image recognition and classification using R, EBImage, Keras 3, and TensorFlow.



\## Dataset



The experiment uses two classes of images:



\- `p1` to `p6` → Class 0

\- `c1` to `c6` → Class 1



The original images are in WEBP format and are converted to PNG before processing.



\## Steps



1\. Load required R packages.

2\. Convert WEBP images to PNG.

3\. Read images using EBImage.

4\. Resize images to 28 × 28.

5\. Convert images into numerical arrays.

6\. Normalize pixel values.

7\. Create class labels.

8\. Build a neural network using Keras.

9\. Train the model.

10\. Evaluate the model.

11\. Generate predictions.

12\. Generate a confusion matrix and calculate accuracy.



\## Model Architecture



```text

Input: 28 × 28 × 3 = 2352 features

&#x20;         ↓

Dense Layer: 256 neurons

&#x20;         ↓

Dense Layer: 128 neurons

&#x20;         ↓

Dense Layer: 2 neurons

&#x20;         ↓

Softmax Classification

