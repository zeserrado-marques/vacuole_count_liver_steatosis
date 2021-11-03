## Vacuole Count Liver Steatosis

Macro that counts vacuoles in fatty liver tissue, measures their shape descriptors, individual and total area. Returns a table with said measurements and ROIs zip for post-analysis.

Saturation and size threshold values and logit function retrieved from https://doi.org/10.1002/cyto.b.21790  
Please cite the paper if you use these macros.

These macros were developed for H&E stain liver tissue samples.

### How to run
There are two ways to segment the images. Either using the saturation channel or Trainable Weka Segmentation. Download the macro code of which version you prefer to run.

#### Saturation
Open and run _step1_ and _step2_ macros like any another Fiji macro.

#### Weka
After running _step1_:
1. Open the _weka_batch_process.ijm_ file.

2. Run the file and follow its instructions.

3. If you have a lot of images, this might take a while.

4. Saves predicted images in a folder called "Weka_predicted_files".

5. Run _step2_ macro on the "Weka_predicted_files" folder.

If you never used Weka, please read the documentation on what it is and how to use it - https://imagej.net/plugins/tws/

If you use Weka Segmentation, please cite its paper https://doi.org/10.1093/bioinformatics/btx180

### Update Log

##### 2021/06/07
- Introduced a maximum vacuole area size.

##### 2021/07/18
- Removed minimum vacuole area size.

##### 2021/11/03
- Added _weka_batch_process.ijm_.
