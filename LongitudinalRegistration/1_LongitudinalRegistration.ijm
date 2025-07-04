/* Julian Schroers 2024/07/24
 *  
 *  This macro expects 2 timepoints with 5 channels each: Channel 1 2P,
 *  channel 2 T2w, channel 3 T1 postcontrast, channel 4 T1n, channel 5 mask.
 *  
 *  Registration consists of 4 steps:
 *  1. Slice shift
 *  2. Rotation based on lines
 *  3. Crop
 *  4. Translation
 *  
 */

waitForUser("Choose Composite of timepoint 1.");
rename("Composite1");
Stack.setXUnit("pixel");
run("Properties...", "channels=5 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");
run("Split Channels");
waitForUser("Choose Composite of timepoint 2.");
verzeichnis = getInfo("image.directory") + "settings.txt";
rename("Composite2");
Stack.setXUnit("pixel");
run("Properties...", "channels=5 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");
run("Split Channels");

// 1. Slice shift
selectWindow("C2-Composite1");
selectWindow("C2-Composite2");

waitForUser("Which slice of Composite 2 is slice 1 of Composite 1?");

Dialog.create("slice_composite2");
Dialog.addNumber("Which slice of Composite 2 is slice 1 of Composite 1:", 1);
Dialog.show();
slice_composite2 = Dialog.getNumber();

verschiebung = slice_composite2 - 1;

selectWindow("C1-Composite2");
if (verschiebung < 0) {
	for (i = 0; i > verschiebung; i--) {
		run("Flip Z");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");
		setSlice(1);
		run("Delete Slice");
		run("Flip Z");
	}
}

if (verschiebung > 0) {
	for (i = 0; i < verschiebung; i++) {
		setSlice(1);
		run("Delete Slice");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");

	}
}

selectWindow("C2-Composite2");
if (verschiebung < 0) {
	for (i = 0; i > verschiebung; i--) {
		run("Flip Z");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");
		setSlice(1);
		run("Delete Slice");
		run("Flip Z");
	}
}

if (verschiebung > 0) {
	for (i = 0; i < verschiebung; i++) {
		setSlice(1);
		run("Delete Slice");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");

	}
}

selectWindow("C3-Composite2");
if (verschiebung < 0) {
	for (i = 0; i > verschiebung; i--) {
		run("Flip Z");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");
		setSlice(1);
		run("Delete Slice");
		run("Flip Z");
	}
}

if (verschiebung > 0) {
	for (i = 0; i < verschiebung; i++) {
		setSlice(1);
		run("Delete Slice");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");

	}
}

selectWindow("C4-Composite2");
if (verschiebung < 0) {
	for (i = 0; i > verschiebung; i--) {
		run("Flip Z");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");
		setSlice(1);
		run("Delete Slice");
		run("Flip Z");
	}
}

if (verschiebung > 0) {
	for (i = 0; i < verschiebung; i++) {
		setSlice(1);
		run("Delete Slice");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");

	}
}

selectWindow("C5-Composite2");
if (verschiebung < 0) {
	for (i = 0; i > verschiebung; i--) {
		run("Flip Z");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");
		setSlice(1);
		run("Delete Slice");
		run("Flip Z");
	}
}

if (verschiebung > 0) {
	for (i = 0; i < verschiebung; i++) {
		setSlice(1);
		run("Delete Slice");
		getDimensions(width, height, channels, slices, frames);
		setSlice(slices);
		run("Add Slice");

	}
}

waitForUser("Z shift done.");

// 2. Rotation based on lines
selectWindow("C2-Composite1");
waitForUser("Draw line.");
run("Clear Results");
run("Set Measurements...", "area centroid stack display redirect=None decimal=8");
run("Measure");
angle_composite1 = getResult("Angle", 0);

selectWindow("C2-Composite2");
waitForUser("Draw line.");
run("Clear Results");
run("Set Measurements...", "area centroid stack display redirect=None decimal=8");
run("Measure");
angle_composite2 = getResult("Angle", 0);

angle_differenz = angle_composite2 - angle_composite1;

selectWindow("C1-Composite2");
run("Rotate... ", "angle=" + angle_differenz + " grid=1 interpolation=Bilinear stack");

selectWindow("C2-Composite2");
run("Rotate... ", "angle=" + angle_differenz + " grid=1 interpolation=Bilinear stack");

selectWindow("C3-Composite2");
run("Rotate... ", "angle=" + angle_differenz + " grid=1 interpolation=Bilinear stack");

selectWindow("C4-Composite2");
run("Rotate... ", "angle=" + angle_differenz + " grid=1 interpolation=Bilinear stack");

selectWindow("C5-Composite2");
run("Rotate... ", "angle=" + angle_differenz + " grid=1 interpolation=None stack");

waitForUser("Rotation done.");

// 3. Crop
selectWindow("C2-Composite1");
getDimensions(width, height, channels, slices, frames);

selectWindow("C1-Composite2");
run("Canvas Size...", "width=" + width + " height=" + height + " position=Center zero");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C2-Composite2");
run("Canvas Size...", "width=" + width + " height=" + height + " position=Center zero");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C3-Composite2");
run("Canvas Size...", "width=" + width + " height=" + height + " position=Center zero");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C4-Composite2");
run("Canvas Size...", "width=" + width + " height=" + height + " position=Center zero");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C5-Composite2");
run("Canvas Size...", "width=" + width + " height=" + height + " position=Center zero");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

waitForUser("Crop done.");

selectWindow("C1-Composite1");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C2-Composite1");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C3-Composite1");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C4-Composite1");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

selectWindow("C5-Composite1");
Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=7 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

// 4. Translation
run("ROI Manager...");
waitForUser("Open fixed and moving volume. Choose multiple points in fixed volume first and save them in ROI Manager. Then, choose the same points in the same order in moving volume. Also save them in ROI Manager. Save the ROI set.");
selectWindow("C2-Composite2");

nROIs = roiManager("count");
nROIs_perImage = nROIs/2;

run("Set Measurements...", "centroid redirect=None decimal=2");
x_shift = 0;
y_shift = 0;

for (i = 0; i < nROIs_perImage; i++) {
	run("Clear Results");
	x_shift_point = 0;
	y_shift_point = 0;
	
	roiManager("Select", i);
	run("Measure");
	x_Image1 = getResult("X", 0);
    y_Image1 = getResult("Y", 0);
    run("Clear Results");
	
	roiManager("Select", i + nROIs_perImage);
	run("Measure");
	x_Image2 = getResult("X", 0);
    y_Image2 = getResult("Y", 0);
    run("Clear Results");
	
	x_shift_point = x_Image1 - x_Image2;
	y_shift_point = y_Image1 - y_Image2;
	
	x_shift = x_shift + x_shift_point;
    y_shift = y_shift + y_shift_point;
}

x_shift = x_shift / nROIs_perImage;
y_shift = y_shift / nROIs_perImage;

x_shift = Math.round(x_shift);
y_shift = Math.round(y_shift);

waitForUser("x-Shift: " + x_shift + ", y-Shift: " + y_shift);

selectWindow("C1-Composite2");
run("Translate...", "x=" + x_shift + " y=" + y_shift + " interpolation=None stack");

selectWindow("C2-Composite2");
run("Translate...", "x=" + x_shift + " y=" + y_shift + " interpolation=None stack");

selectWindow("C3-Composite2");
run("Translate...", "x=" + x_shift + " y=" + y_shift + " interpolation=None stack");

selectWindow("C4-Composite2");
run("Translate...", "x=" + x_shift + " y=" + y_shift + " interpolation=None stack");

selectWindow("C5-Composite2");
run("Translate...", "x=" + x_shift + " y=" + y_shift + " interpolation=None stack");

waitForUser("Translation done.");

run("Merge Channels...", "c1=C1-Composite2 c2=C2-Composite2 c3=C3-Composite2 c4=C4-Composite2 c5=C5-Composite2 create");

// Array to save information
SettingsData = newArray(verschiebung, angle_differenz, x_shift, y_shift);

// Open txt-file
file = File.open(verzeichnis);

// Write data in txt-file
File.append(String.join(SettingsData, ","), verzeichnis);

// Close txt-file
File.close(file);

waitForUser("Merge done. Settings-file is here: " + verzeichnis + " Save the merged file.");