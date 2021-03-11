/*
 * Make composite images RGB and set correct scale.
 * input - tif files
 * images must be 40x for correct pixel scaling
 * 
 * Author: José Serrado Marques
 * Date: 2021/02
 */

// variables
pixel_width = 0.4433;
pixel_height = 0.4433;
unit = "um";

// paths
input = getDir("folder with images to be predicted");
list_files = getFileList(input);
output = input + File.separator + "RGB_images";
File.makeDirectory(output);

setBatchMode("hide");
for (i = 0; i < lengthOf(list_files); i++) {
	current_file = list_files[i];
	path_current = input + File.separator + current_file;
	if (endsWith(current_file, ".tif")) {
		open(path_current);
		processFile(output, pixel_width, pixel_height, unit);	
	}
}

function processFile(output, pixel_width, pixel_height, unit) { 
	// process opened file. put here your desired workflow

	// variables
	getDimensions(width, height, channels, slices, frames);
	channels = channels;
	bit_depth = bitDepth();
	img = getTitle();
	img_name = substring(img, 0, indexOf(img, "."));
	Stack.getUnits(X, Y, Z, Time, Value);

	// put correct scale into image
	if (X != "micron" && X != "µm") {
		Stack.setXUnit(unit);
		run("Properties...", "channels=" + channels + " slices=1 frames=1 pixel_width=" + pixel_width + " pixel_height=" + pixel_height + " voxel_depth=1");
	}
	
	// saves an RGB image
	if (bit_depth != 24) {
		if (channels == 3) {
			run("RGB Color");
			rename(img_name);
			saveAs("tiff", output + File.separator + img_name + ".tif");
		}	
	} else {
		saveAs("tiff", output + File.separator + img_name + ".tif");
	}
}
