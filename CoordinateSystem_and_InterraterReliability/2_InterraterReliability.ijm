/* Julian Schroers
 *  
 *  This macro is designed for saving a csv-file with point information to define RMSE of two raters. 
 *  Previously, coordinate system should be applied to 2P image and both raters should register it to MRI.
 *  Following, R script is used to calculate RMSE.
 *  
 */

number_points = 6;
start_slice = 1;
end_slice = 7;

x = newArray(number_points);
y = newArray(number_points);
z = newArray(number_points);
rater1_x = newArray(number_points);
rater1_y = newArray(number_points);
rater1_z = newArray(number_points);
rater2_x = newArray(number_points);
rater2_y = newArray(number_points);
rater2_z = newArray(number_points);

run("Set Measurements...", "centroid redirect=None decimal=0");

waitForUser("Choose registered image with coordinate system of rater 1.");
verzeichnis = getInfo("image.directory");
rename("rater1");
waitForUser("Choose registered image with coordinate system of rater 2.");
rename("rater2");

csv_text = "cs_x\tcs_y\tcs_z\trater1_x\trater1_y\trater1_z\trater2_x\trater2_y\trater2_z\tum_per_pixel_x\tum_per_pixel_y\tum_per_pixel_z";

Dialog.create("um_per_pixel_x");
Dialog.addNumber("um_per_pixel_x:", 1.2);
Dialog.show();
um_per_pixel_x = Dialog.getNumber();

Dialog.create("um_per_pixel_y");
Dialog.addNumber("um_per_pixel_y:", 1.2);
Dialog.show();
um_per_pixel_y = Dialog.getNumber();

Dialog.create("um_per_pixel_z");
Dialog.addNumber("um_per_pixel_z:", 100);
Dialog.show();
um_per_pixel_z = Dialog.getNumber();

// Adjust numbers of coordinate system here. It is currently designed for 50 columns, 50 rows and 7 slices.
for (i = 0; i < number_points; i++) {
	coordinate_ok = "no";
	x_start = 0;
	x_end = 100;
	y_start = 0;
	y_end = 100;
		
	if (i == 0) {
		x_start = 1;
		x_end = 17;
		y_start = 1;
		y_end = 25;
	}
	if (i == 1) {
		x_start = 18;
		x_end = 34;
		y_start = 1;
		y_end = 25;
	}
	if (i == 2) {
		x_start = 35;
		x_end = 50;
		y_start = 1;
		y_end = 25;
	}
	if (i == 3) {
		x_start = 1;
		x_end = 17;
		y_start = 26;
		y_end = 50;
	}
	if (i == 4) {
		x_start = 18;
		x_end = 34;
		y_start = 26;
		y_end = 50;
	}
	if (i == 5) {
		x_start = 35;
		x_end = 50;
		y_start = 26;
		y_end = 50;
	}
	
	
	while (coordinate_ok == "no") {
		x[i] = 0;
		y[i] = 0;
		z[i] = 0;
		
		while (x[i]<x_start || x[i]>x_end) {
			x[i] = round(50*random());
		}
		while (y[i]<y_start || y[i]>y_end) {
			y[i] = round(50*random());
		}		
		while (z[i]<start_slice || z[i]>end_slice) {
			z[i] = round(7*random());
		}
		
		waitForUser(z[i] + "." + y[i] + "." + x[i] + "\nIs this coordinate in the parenchyma?");
	
		items = newArray("yes", "no");
		Dialog.create("coordinate_ok");
		Dialog.addRadioButtonGroup(z[i] + "." + y[i] + "." + x[i] + "\nIs this coordinate in the parenchyma?", items, 1, 2, "yes");
		Dialog.show();
		coordinate_ok = Dialog.getRadioButton();
	}
	
	run("Clear Results");
	selectWindow("rater1");
	waitForUser(z[i] + "." + y[i] + "." + x[i] + "\nPlace a point here.");
	run("Measure");
	rater1_x[i] = getResult("X", 0);
	rater1_y[i] = getResult("Y", 0);
	rater1_z[i] = getResult("Slice", 0);
	
	run("Clear Results");
	selectWindow("rater2");
	waitForUser(z[i] + "." + y[i] + "." + x[i] + "\nPlace a point here.");
	run("Measure");
	rater2_x[i] = getResult("X", 0);
	rater2_y[i] = getResult("Y", 0);
	rater2_z[i] = getResult("Slice", 0);
	
	csv_text = csv_text + "\n" + x[i] + "\t" + y[i] + "\t" + z[i] + "\t"  + rater1_x[i] + "\t" + rater1_y[i] + "\t" + rater1_z[i] + "\t" + rater2_x[i] + "\t" + rater2_y[i] + "\t" + rater2_z[i] + "\t" + um_per_pixel_x + "\t" + um_per_pixel_y + "\t" + um_per_pixel_z;
	
}

print("\\Clear");
print(csv_text);

selectWindow("Log");
saveAs("Text", verzeichnis + "coordinates.csv");

waitForUser("Finished :) csv is here: " + verzeichnis);