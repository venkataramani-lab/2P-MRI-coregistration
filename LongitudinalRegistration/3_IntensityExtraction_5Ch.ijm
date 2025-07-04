/* Julian Schroers 2023/10/08 - Template for macro by Dr. Carlo A. Beretta was used.
 * 
 * This macro expects 5 channel tif: Channel 1 2P timepoint 1, channel 2 MRI timepoint 1, 
 * channel 3 2P timepoint 2, channel 4 MRI timepoint 2, channel 5 mask.
 * Previously, longitudinal registration and mask merging of multiple timepoints
 * should be done.
 * 
 */

// Contact Information
function ContactInformation() {

	print("##############################################################");	
 	print("Julian Schroers"); 
 	print("julian.schroers@dkfz-heidelberg.de");
 	print("##############################################################\n");	
 	
}

// # 1 General setting
function Setting() {
	
	// Set the Measurments parameters
	run("Set Measurements...", "area mean standard min perimeter integrated limit redirect=None decimal=8");

	// Set binary background to 0 
	run("Options...", "iterations=1 count=1 black");

	// General color setting
	run("Colors...", "foreground=white background=black selection=yellow");

}

// # 2
function CloseAllWindows() {
	
	while(nImages > 0) {
		
		selectImage(nImages);
		close();
		
	}
}

// # 3
// Choose the input directories (Raw)
function InputDirectoryRaw() {

	dirIn = getDirectory("Please choose the RAW input root directory");

	// The macro checks that you choose a directory and outputs the input path
	if (lengthOf(dirIn) == 0) {
		print("Exit!");
		exit();
			
	} else {

		// Output the path
		return dirIn;
			
	}
	
}

// # 4
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

	// Use the new string as a path to create the OUTPUT directory.
	dirOutRoot = dirOutRoot + "MacroResults_" + year + "-" + month + "-" + dayOfMonth + "_0" + second + File.separator;
	return dirOutRoot;
	
}


// # 7
// Save and close Log window
function CloseLogWindow(dirOutRoot) {
	
	if (isOpen("Log")) {
		
		selectWindow("Log");
		saveAs("Text", dirOutRoot + "IntensityMeasures_C1-C2.csv"); 
		run("Close");
		
	}
	
}

// # 8
// Close Memory window
function CloseMemoryWindow() {
	
	if (isOpen("Memory")) {
		
		selectWindow("Memory");
		run("Close", "Memory");

	}
	
}

// # 10
function SaveStatisticWindow(dirOutRoot) {

	// Save the SummaryWindow and close it
	selectWindow("Summary Window");
	saveAs("Text",  dirOutRoot + "SummaryIntensityMeasurements"+ ".xls");
	run("Close");
	
}


// # 12
// Loop throught pixel, catch pixel value and set pixel value
function PixelIntensityValue(arraySize) {

	// Update the user 
	showStatus("Reading pixel intensity...");

	// Input size of the image
	wd = getWidth();
	hd = getHeight();

	// Initilize counting variables
	countPixel = -1;
	
	// Move ROI selection in (z)
	for (z=0; z<slices; z++) {
		
		setSlice(z+1);
		
		// Move ROI selection in (x)
		for (i=0; i<wd; i++) {
	
			// Show progress
			wait(1);
			showProgress(1 -(((wd - i)) / wd));
	
			// in (y)
			for (k=0; k<hd; k++) {
	
				// Make a selection around each pixel in xy
				makeRectangle(i, k, 1, 1);
				
				// Get selected pixel statistic
				getStatistics(area, mean, min, max);
				countPixel += 1;
					
				// Get value
				arraySize[countPixel] = mean;
					 	
			}
			
		}
		
	}

	return arraySize;
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%% Macro %%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
macro IntensityExtraction {

	// Start functions
	// 1.
	Setting();
	
	// 2.
	CloseAllWindows();

	// Display memory usage
	doCommand("Monitor Memory...");

	// Get the starting time
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	// 4. Function choose the input root directory
	dirIn = InputDirectoryRaw();
	outputPath = dirIn;

	// Get the list of file in the input directory
	fileList = getFileList(dirIn);

	// 5. Create the output root directory in the input path
	dirOutRoot = OutputDirectory(outputPath, year, month, dayOfMonth, second);

	if (!File.exists(dirOutRoot)) {	
		
		File.makeDirectory(dirOutRoot);
		
	} 

	// Do not display the images
	setBatchMode(true);

	// Open the file located in the input directory
	for (n=0; n<fileList.length; n++) {

		// Check the input file format .tiff
		if (endsWith(fileList[n], '.tiff') || endsWith(fileList[n], '.tif')) {

			// Open the input raw image
			open(dirIn + fileList[n]);
			inputTitle = getTitle();

			// Remove file extension .somthing
            dotIndex = indexOf(inputTitle, ".");
            title = substring(inputTitle, 0, dotIndex);

            // Split the channel and save the raw data ROI
            getDimensions(width, height, channels, slices, frames);

            // Measure pixel intensiy in the 5 channles
            if (channels == 5) {

				// Split channels
				run("Split Channels");
				
            	// Catch channels by name
            	selectImage("C1-" + inputTitle);
            	fluoroTitle1 = getTitle();
            	selectImage("C2-" + inputTitle);
            	mriTitle1 = getTitle();
            	selectImage("C3-" + inputTitle);
            	fluoroTitle2 = getTitle();
            	selectImage("C4-" + inputTitle);
            	mriTitle2 = getTitle();
            	selectImage("C5-" + inputTitle);
            	roiTitle = getTitle();

				width = getWidth();
				height = getHeight();
				
				Dialog.create("slices");
				Dialog.addNumber("Number of slices:", 7);
				Dialog.show();
				slices = Dialog.getNumber();

				arraySize = newArray(width * height * slices);
				info_z = newArray(width * height * slices);
				info_x = newArray(width * height * slices);
				info_y = newArray(width * height * slices);

				// Process ch1
				selectImage(fluoroTitle1);
				
				
				
				// PIXEL INTENSITY VALUE
				
				// Update the user 
				showStatus("Reading pixel intensity...");
			
				// Input size of the image
				wd = getWidth();
				hd = getHeight();
			
				// Initilize counting variables
				countPixel = -1;
				
				// Move ROI selection in (z)
				for (z=0; z<slices; z++) {
					
					setSlice(z+1);
					
					// Move ROI selection in (x)
					for (i=0; i<wd; i++) {
				
						// Show progress
						wait(1);
						showProgress(1 -(((wd - i)) / wd));
				
						// in (y)
						for (k=0; k<hd; k++) {
				
							// Make a selection around each pixel in xy
							makeRectangle(i, k, 1, 1);
							
							// Get selected pixel statistic
							getStatistics(area, mean, min, max);
							countPixel += 1;
								
							// Get value
							arraySize[countPixel] = mean;
							info_z[countPixel] = z+1;
							info_x[countPixel] = i+1;
							info_y[countPixel] = k+1;
								 	
						}
						
					}
					
				}
	
	
	


				arraySizeC1 = arraySize;

				arraySize = newArray(width * height * slices);

				// Process ch2
				selectImage(mriTitle1);
				PixelIntensityValue(arraySize);
				arraySizeC2 = arraySize;

				arraySize = newArray(width * height * slices);

				// Process ch3
				selectImage(fluoroTitle2);
				PixelIntensityValue(arraySize);
				arraySizeC3 = arraySize;

				arraySize = newArray(width * height * slices);

				// Process ch4
				selectImage(mriTitle2);
				PixelIntensityValue(arraySize);
				arraySizeC4 = arraySize;

				arraySize = newArray(width * height * slices);

				// Process ch5
				selectImage(roiTitle);
				PixelIntensityValue(arraySize);
				arraySizeC5 = arraySize;

				// Output the arrays with intensites if mask value is higher than 0
				for (l = 0; l < arraySize.length; l++) {

					if (arraySizeC5[l] > 0) {

					print(arraySizeC1[l] + "\t" + arraySizeC2[l] + "\t" + arraySizeC3[l] + "\t" + arraySizeC4[l]  + "\t" + arraySizeC5[l] + "\t" + title + "\t" + (n+1) + "\t" + l + "\t" + info_z[l] + "\t" + info_x[l] + "\t" + info_y[l]);

					}
					
				}

				// Close all the open images
				selectImage(fluoroTitle1);
				close(fluoroTitle1);
				selectImage(mriTitle1);
				close(mriTitle1);
				selectImage(fluoroTitle2);
				close(fluoroTitle2);
				selectImage(mriTitle2);
				close(mriTitle2);
				selectImage(roiTitle);
				close(roiTitle);
            	
            } else {

				exit("Input image must have 5 channels");
            	
            }

		} else {

			// Update the user
			exit("Input file format not supported: " + fileList[i]);

		}

	}
	
	// End functions
	CloseLogWindow(dirOutRoot);
	CloseMemoryWindow();
	
	// Display the images
	setBatchMode(false);
	showStatus("Completed");
	
}