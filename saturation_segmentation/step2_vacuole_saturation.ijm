/*
 * Macro that counts vacuoles, measures their area and shape descriptors, calculates the sum. 
 * Returns a table with said measurements and ROIs zip for post-analysis.
 * 
 * Saturation and size threshold values and logit function retrieved from https://doi.org/10.1002/cyto.b.21790
 * Please cite the paper.
 * 
 * Dependencies:
 * - RGB Images
 * 
 * Author: José Serrado Marques
 * Date: 2021/03
 * 
 */

// initialize
print("\\Clear");
run("Set Measurements...", "area shape redirect=None decimal=3");

// variables
max_vacuole_size = 500;

// paths
input = getDir("folder with images to be predicted");
list_files = getFileList(input);

setBatchMode("hide");
for (i = 0; i < lengthOf(list_files); i++) {
	current_file = list_files[i];
	path_current = input + File.separator + current_file;
	if (endsWith(current_file, ".tif")) {
		open(path_current);
		processFile(input);
	}
}

end_time = getTime();
runtime(start_time, end_time);

function processFile(input) { 
	// process opened file. put here your desired workflow
	run("Remove Overlay");
	run("Select None");
	// variables
	table_name = "Vacuoles_areas";
	
	run("Set Measurements...", "area shape redirect=None decimal=3");
	
	img = getTitle();
	img_name = substring(img, 0, indexOf(img, "."));
	
	// get saturarion channel (turn this into a function)
	run("Duplicate...", " ");
	getSaturation();
	
	// Threshold
	setThreshold(0, 29);
	run("Convert to Mask");
	
	// binary (black background selected)
	run("Options...", "iterations=2 count=1 black do=Nothing");
	run("Fill Holes");
	run("Open");
	run("Watershed");
	
	// Analyze particles and extract ROIs
	run("Analyze Particles...", "size=2-" + max_vacuole_size + " circularity=0.2-1.00 show=Masks display clear add");
	selectWindow(img);
	
	// roimanager and table settings
	n = roiManager("count");
	vacuole_count = 0;
	other_count = 0;
	Table.create(table_name);

	// vacuole classification part
	for (i = 0; i < n; i++) {
		// get values from roi to classify it as a vacuole
		area_roi = getResult("Area", i);
		circ_roi = getResult("Circ.", i);
		round_roi = getResult("Round", i);
		solidity_roi = getResult("Solidity", i);
		
		// classification with the logit function from the paper
		roi_classified = logit_func(area_roi, circ_roi, round_roi, solidity_roi);
		if (roi_classified == 1) {
			// label roi
			roiManager("select", i);
			roiManager("rename", "vacuole_" + (vacuole_count + 1));
			Roi.setStrokeColor("green");
	
			// puts these values in the new table
			selectWindow(table_name);
			Table.set("Vacuole", vacuole_count, (vacuole_count + 1));
			Table.set("Area", vacuole_count, area_roi);
			Table.set("Circ.", vacuole_count, circ_roi);
			Table.set("Round", vacuole_count, round_roi);
			Table.set("Solidity", vacuole_count, solidity_roi);
	
			vacuole_count += 1;
		} else {
			roiManager("select", i);
			roiManager("rename", "other_" + (other_count + 1));
			Roi.setStrokeColor("magenta");
			other_count += 1;
		}	
	}
	
	// get areas from classified vacuoles
	total_area = 0;
	for (j = 0; j < Table.size; j++) {
		v = Table.get("Area", j);
		total_area = total_area + v;
	}
	// get mean
	vacuole_mean = total_area / vacuole_count;
	//print(vacuole_count);
	//print(vacuole_mean);
	
	// add area to results table
	Table.set("Sum_Area_Vacuoles", 0, total_area);
	Table.set("Total Vacuoles", 0, vacuole_count);
	Table.set("Mean Area Size", 0, vacuole_mean);
	Table.set("Others", 0, other_count);

	// save rois and vacuoles table
	selectWindow(table_name);
	Table.save(input + File.separator + img_name + "_" + table_name + ".csv");
	roiManager("deselect");
	roiManager("Save", input + File.separator + img_name + "_vacuoleROIs.zip");

	// close all
	close("*");
	selectWindow(table_name);
	run("Close");
	run("Clear Results");
	if (roiManager("count") > 0) {
		roiManager("deselect");
		roiManager("delete");
	}
}


// functions 
function getSaturation() { 
	// retrives only the saturation channel
	run("HSB Stack");
	hsb_image = getTitle();
	Stack.setChannel(2);
	run("Duplicate...", "use");
	selectWindow(hsb_image);
	close();
}


function logit_func(size, circ, roundness, solidity) {
	// uses the logit function from the paper
	// returns true (1) or false (0)
	value = -16.2 + (0.00272 * size) + (5.81 * circ) + (7.054 * roundness) + (10.3 * solidity);
	if (log(value) >= 0.5 && size >= 25) {
		return true
	} else {
		return false
	}
}

function runtime(start_time, end_time) { 
	// print time in minutes and seconds
	total_time = end_time - start_time;
	minutes_remanider = total_time % (60 * 1000);
	minutes = (total_time - minutes_remanider) / (60 * 1000);
	seconds = minutes_remanider / 1000;
	print("Runtime is " + minutes + " minutes and " + seconds + " seconds.\nVacuole vibe check done! Yatta!");	
}



