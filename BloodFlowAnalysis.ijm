/* Julian Schroers 2024/04/16

This macro expects a folder with multiple xy-images from Zen software. The purpose is to
draw manually 10 lines per line scan corresponding to the angle of the recorded blood flow.
The mean blood flow velocity and the standard deviation are calculated. x axis should be time,
y axis should be distance. 

Adjust number of lines here: line 99
Adjust number of lines here: line 102
Adjust number of lines here: line 105
Adjust here if your xy-image is not in channel 2: line 125

*/

function CloseAllWindows() {
	
	while(nImages > 0) {
		
		selectImage(nImages);
		close();
		
	}
}

function InputDirectoryRaw() {

	dirIn = getDirectory("Please choose the RAW input root directory");

	// Macro checks that you choose a directory and outputs the input path
	if (lengthOf(dirIn) == 0) {
		print("Exit!");
		exit();
			
	} else {

		// Output the path
		return dirIn;
			
	}
	
}

// Output directory
function OutputDirectory(outputPath, year, month, dayOfMonth, second) {

	// Use the dirIn path to create the output path directory
	dirOutRoot = outputPath;

	// Change the path 
	lastSeparator = lastIndexOf(dirOutRoot, File.separator);
	dirOutRoot = substring(dirOutRoot, 0, lastSeparator);
	
	// Split the string by file separtor
	splitString = split(dirOutRoot, File.separator); 
	for(i=0; i<splitString.length; i++) {

		lastString = splitString[i];
		
	} 

	// Remove the end part of the string
	indexLastSeparator = lastIndexOf(dirOutRoot, lastString);
	dirOutRoot = substring(dirOutRoot, 0, indexLastSeparator);

	// Use the new string as a path to create the output directory
	dirOutRoot = dirOutRoot + "MacroResults_" + year + "-" + month + "-" + dayOfMonth + "_0" + second + File.separator;
	
	dirOutRoot_array = newArray(2);
	dirOutRoot_array[0] = dirOutRoot;
	dirOutRoot_array[1] = lastString;
	
	return dirOutRoot_array;
	
}

macro BloodFlowAnalysis {
	
	CloseAllWindows();

	// Get the starting time
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// Choose the input root directory
	dirIn = InputDirectoryRaw();
	outputPath = dirIn;

	// Get the list of file in the input directory
	fileList = getFileList(dirIn);
	
	dirOutRoot_array = OutputDirectory(outputPath, year, month, dayOfMonth, second);
	
	if (!File.exists(dirOutRoot_array[0])) {	
		
		File.makeDirectory(dirOutRoot_array[0]);
		
	}
	
	// Adjust the number of lines here
	lines_number = 10;
	
	// Adjust micrometer per pixel here
	voxel_width_um = 0.1657;
	
	// Adjust seconds per pixel here
	voxel_height_sec = 0.000146;
	
	csv_text = "folder\ttitle\tmean\tsd\tlines_number";
	csv_text_lines = "folder\ttitle\tnumber\tum_per_sec";
	
	// Open the file located in the input directory
	for (n=0; n<fileList.length; n++) {

		// Check the input file format .tiff or .czi
		if (endsWith(fileList[n], '.tiff') || endsWith(fileList[n], '.tif') || endsWith(fileList[n], '.czi')) {

			// Open the input raw image
			open(dirIn + fileList[n]);
			whole_image_title = getTitle();

			// Remove file extension .something
            dotIndex = indexOf(whole_image_title, ".");
            title = substring(whole_image_title, 0, dotIndex);

			// Our data consisted of two channels and only the second channel included blood flow data
			waitForUser("New image " + title + ":\nSplit channels and choose channel 2");
			
			// Get information on dataset
			whole_image_title = getTitle();
			width = getWidth();
			height = getHeight();
			width_area = width/lines_number;
			height_area = height/lines_number;
			um_per_s = newArray(lines_number);
			sum = 0;
			
			// 10 repetitions of setting lines parallel to blood flow
			for (i = 1; i < lines_number+1; i++) {
				
				selectImage(whole_image_title);
				
				if (i<5) {
					makeRectangle(0, height_area*(i-1), width, height_area);
					run("Duplicate...", "title=image_" + i);
				} else {
					makeRectangle(0, height_area*(i-1), width, height - (lines_number-1)*height_area);
					run("Duplicate...", "title=image_" + i);
				}
				
				waitForUser("Set line " + i);
				getLine(line_x1, line_y1, line_x2, line_y2, lineWidth);
				
				line_width_pixel = line_x2 - line_x1;
				line_height_pixel = line_y2 - line_y1;
				
				line_width_um = line_width_pixel * voxel_width_um;
				line_height_sec = line_height_pixel * voxel_height_sec;
				
				um_per_s[i] = line_width_um/line_height_sec;
				
				sum = sum + um_per_s[i];
				
				close("image_" + i);
				
				csv_text_lines = csv_text_lines + "\n" + dirOutRoot_array[1] + "\t" + title + "\t" + i + "\t" + um_per_s[i];
				print("Line " + i + ":\nx1: " + line_x1 + ", x2: " + line_x2 + ", y1: " + line_y1 + ", y2: " + line_y2 + "\nwidth (pixel): " + line_width_pixel + ", width (um): " + line_width_um + "\nheight (pixel): " + line_height_pixel + ", height (sec): " + line_height_sec + "\num/sec: " + um_per_s[i] + "\n\n");
			}
			
			mean = sum/lines_number;
			
			variance = 0;
			
			for (j = 0; j < lines_number; j++) {
				variance += Math.pow(um_per_s[j+1] - mean, 2);
			}
			
			variance /= lines_number;
			standardDeviation = Math.sqrt(variance);
			
			if (mean < 0) {
				mean = mean * (-1);
			}
			
			print(title + ":\nMean (um/s): " + mean + "\nSD: " + standardDeviation + "\n\n");
			waitForUser("Mean (um/s): " + mean + "\nSD: " + standardDeviation);
			
			csv_text = csv_text + "\n" + dirOutRoot_array[1] + "\t" + title + "\t" + mean + "\t" + standardDeviation + "\t" + lines_number;
			
			close(whole_image_title);
			
		} else {
		// Update the user
		exit("Input file format not supported: " + fileList[i]);
		}
	}
	
	// Output results
	waitForUser("csv is created.");
	
	print("\\Clear");
	print(csv_text);
	
	if (isOpen("Log")) {
		
		selectWindow("Log");
		saveAs("Text", dirOutRoot_array[0] + "BloodFlowVelocity_Summary.csv"); 
		
		print("\\Clear");
		print(csv_text_lines);
		
		selectWindow("Log");
		saveAs("Text", dirOutRoot_array[0] + "BloodFlowVelocity_Lines.csv");
		
		run("Close");
		
	}
	
	waitForUser("Finished :)");

}