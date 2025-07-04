/* Julian Schroers 2024/07/24
 *  
 *  This macro expects masks of multiple timepoints after longitudinal registration.
 *  It defines the overlap of these masks for creating a multiple-timepoint mask.
 *  
 */

Dialog.create("number_timepoints");
Dialog.addNumber("Number of timepoints:", 2);
Dialog.show();
number_timepoints = Dialog.getNumber();

waitForUser("Choose timepoint 1.");
getDimensions(width, height, channels, slices, frames);
anzahl_data_roi = width * height * slices;
data_roi = newArray(anzahl_data_roi);

for (i = 0; i < number_timepoints; i++) {
	waitForUser("Choose timepoint " + i+1);
	rename("timepoint" + i+1);
	getDimensions(width, height, channels, slices, frames);
	Stack.setXUnit("pixel");
	run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");
	k = 1;
	for (z = 1; z <= slices; z++) {
		setSlice(z);
    	for (y = 0; y < height; y++) {
        	for (x = 0; x < width; x++) {
        		if (i == 0) {
        			data_roi[k] = 1;
        		}

        		print("\\Update: Get Values: " + k + " / " + anzahl_data_roi);
        		if (getPixel(x, y) == 0) {
        			data_roi[k] = 0;
        		} 
        		if (getPixel(x, y) > 0 && data_roi[k] == 1) {
        			data_roi[k] = 1;
        		}
        		k += 1;
        	}
        }
	}
}

newImage("merged-mask", "32-bit black", width, height, slices);
k = 1;
for (z = 1; z <= slices; z++) {
	setSlice(z);
   	for (y = 0; y < height; y++) {
       	for (x = 0; x < width; x++) {
       		print("\\Update: Create new mask: " + k + " / " + anzahl_data_roi);
       		setPixel(x, y, data_roi[k]);
       		k += 1;
       	}
	}
}
