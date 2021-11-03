/*
 * Classifies the images inside a folder with WEKA according to the trained classifier/model. 
 * Depending on image file size and number, this process can take a very long time. Ideally, run it overnight on a workstation.
 * 
 * Author: José Serrado Marques
 * Date: 2021-06-09
 * 
 * Please cite WEKA paper if you use this macro. Many thanks.
 * 
 * 
 */

// paths
#@ String(value="Please choose the trained WEKA classifier file", visibility="MESSAGE") ;
#@ File (style="read") inputFile ;
class_model_path = inputFile;
exit;

input = getDir("Files to be predicted by Weka");
list_files = getFileList(input);
output = input + File.separator + "Weka_predicted_files";
File.makeDirectory(output);


// runs the weka processing
start_time = getTime();
print("Start weka prediction");
for (i = 0; i < list_files.length; i++) {
	current_file = list_files[i];
	path_current = input + File.separator + current_file;
	print(current_file);
	if (endsWith(current_file, ".tif")) {
		open(path_current);
		img = getTitle();
		img_name = substring(img, 0, lastIndexOf(img, "."));
		run("Trainable Weka Segmentation");
		wait(4000);
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", class_model_path);
		call("trainableSegmentation.Weka_Segmentation.applyClassifier", input, current_file, "showResults=true", "storeResults=false", "probabilityMaps=false", "");
		//wait(1000);
		selectWindow("Classification result");
		saveAs("tiff", output + File.separator + img_name + "_classified.tif");
		close("*");
	}
}

end_time = getTime();
runtime(start_time, end_time);
selectWindow("Log");

function runtime(start_time, end_time) { 
	// print time in minutes and seconds
	total_time = end_time - start_time;
	minutes_remanider = total_time % (60 * 1000);
	minutes = (total_time - minutes_remanider) / (60 * 1000);
	seconds = minutes_remanider / 1000;
	print("Runtime is " + minutes + " minutes and " + seconds + " seconds.\n Nice!");
}

