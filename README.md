## Vacuole Count Liver Steatosis

Macro that counts vacuoles in fatty liver tissue, measures their shape descriptors, individual and total area. Returns a table with said measurements and ROIs zip for post-analysis.

Saturation and size threshold values and logit function retrieved from https://doi.org/10.1002/cyto.b.21790  
Please cite the paper if you use these macros.

These macros were developed for H&E stain liver tissue samples.

### How to run
There are two ways to segment the images. Either using the saturation channel or Trainable Weka Segmentation. Download the macro code of which version you prefer to run.

##### Saturation
Open and run _step1_ and _step2_ macros like any another Fiji macro.

##### Weka
After running _step1_:
1. Open an image on Weka

2. Click "Load Classifier"

3. Open the vacuoles.model file (or another classifier that you trained)

4. Then click "Apply Classifier"

5. Select image files to be predicted/segmented

6. If they're more than 3, save them in a folder (e.g. create a folder called "classified" and save the predicted images there)

7. Wait a bit. Weka is not the fastest plugin

8. After prediction, run _step2_ macro

#### Update Log

##### 2020/07/06
- Introduced a maximum vacuole area size.
