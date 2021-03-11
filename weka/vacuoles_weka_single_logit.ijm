/*
 * Macro that counts vacuoles in fatty liver tissue, measures their area and shape descriptors. 
 * Returns a table with said measurements and ROIs zip for post-analysis.
 * 
 * Use this macro if you segmented the images using WEKA. Please cite the authors.
 * 
 * Size threshold value and logit function retrieved from https://doi.org/10.1002/cyto.b.21790
 * Please cite the paper.
 * 
 * Dependencies:
 * - Pre-classified images
 * 
 * Author: José Serrado Marques
 * Date: 2021/03
 * 
 */
run("Remove Overlay");
run("Select None");
// variables
table_name = "Vacuole vibe check";

run("Set Measurements...", "area shape redirect=None decimal=3");

img = getTitle();
img_name = substring(img, 0, indexOf(img, "."));
bit_depth = bitDepth();

// Threshold
// bit depth == 8 means its a classified image for this particular case
if (bit_depth == 8) {
	run("Duplicate...", " ");
	setThreshold(0, 0);
	run("Convert to Mask");
} else if(bit_depth == 24){
	// if its a rgb image
	run("Duplicate...", " ");
	getSaturation();
	setThreshold(0, 29);
	run("Convert to Mask");
} else {
	// duplicates only the "vacuoles" probability map
	run("Duplicate...", "use");
	setAutoThreshold("Otsu dark");
	run("Convert to Mask");
}

// binary (black background selected)
run("Options...", "iterations=2 count=1 black do=Nothing");
run("Fill Holes");
run("Open");
run("Watershed");

// Analyze particles and extract ROIs
run("Analyze Particles...", "size=2-25000 circularity=0.2-1.00 show=Masks display clear add");
selectWindow(img);

// roimanager and table settings
n = roiManager("count");
vacuole_count = 0;
other_count = 0;

Table.create(table_name);

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
		Overlay.addSelection();

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
		Overlay.addSelection();
		other_count += 1;
	}	
}

// get areas from results
total_area = 0;
for (j = 0; j < Table.size; j++) {
	v = Table.get("Area", j);
	total_area = total_area + v;
}
//print(total_area);

// add area to results table
Table.set("Sum_Area_Vacuoles", 0, total_area);
Table.set("Total Vacuoles", 0, vacuole_count);
Table.set("Others", 0, other_count);


// functions 
function getSaturation() { 
	// retrives saturation channel
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

