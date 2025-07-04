// Julian Schroers

function PixelIntensityValue(arraySize) {

	if (a == 0) {
		image = "MRI";
		print("Get MRI-values");
	} else {
		image = "mask";
		print("Get mask-values");
	}

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
				
				print("\\Update:Get " + image + "-values: " + countPixel+1 + "/" + arraySize.length);
				
				// Get value
				arraySize[countPixel] = mean;
					 	
			}
			
		}
		
	}

	return arraySize;
}

macro Template {
	
	waitForUser("Wähle das zu normalisierende Bild aus.");
	rename("normalized");
	normalizedTitle = getTitle();
	
	waitForUser("Wähle das MRT-Bild aus.");
	rename("whole");
	wholeTitle = getTitle();
	
	waitForUser("Wähle die Maske aus.");
	rename("mask");
	maskTitle = getTitle();

	// Do not display the images
	setBatchMode(true);

    // DELETED: Measure intensity per pixel above zero
	width = getWidth();
	height = getHeight();
	
	Dialog.create("slices");
	Dialog.addNumber("Number of slices:", 7);
	Dialog.show();
	slices = Dialog.getNumber();
	
	arraySize = newArray(width * height * slices);

	a = 0;
	// Process ch1
	selectImage(wholeTitle);
	PixelIntensityValue(arraySize);
	arraySizeC1 = arraySize;

	arraySize = newArray(width * height * slices);

	a = 1;
	// Process ch2
	selectImage(maskTitle);
	PixelIntensityValue(arraySize);
	arraySizeC2 = arraySize;
	
	sum = 0;
	count_mask = 0;
	
	for (l = 0; l < arraySize.length; l++) {
		
		if (arraySizeC2[l] == 3) {
			count_mask += 1;
			sum = sum + arraySizeC1[l];
			print(arraySizeC1[l]);
		}
	
	}
	
	mean_whole = sum / count_mask;
		
	variance = 0;
	
	for (l = 0; l < arraySize.length; l++) {
    	if (arraySizeC2[l] == 3) {
     	   variance += Math.pow(arraySizeC1[l] - mean_whole, 2);
 	   }
	}
	
	variance /= count_mask;
	standardDeviation = Math.sqrt(variance);
	
	print("Mean: " + mean_whole + ", SD: " + standardDeviation);
	
	selectImage(normalizedTitle);
	
	run("Subtract...", "value=" + mean_whole + " stack");
	run("Divide...", "value=" + standardDeviation + " stack");
	
	setBatchMode(false);
	showStatus("Completed");
	print("Completed");
}