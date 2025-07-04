//close("\\Others");
title = getTitle();

Dialog.create("groupedZ_V0");
Dialog.addMessage("Image: " + title);
Dialog.addNumber("ZSlices to group together: ", 33);
Dialog.show();
groupTogether = 33;
groupTogether = Dialog.getNumber();





getDimensions(width, height, channels, slices, frames);
realFrames = frames;

print(slices);
newSlicCount = round(slices / groupTogether);

print(newSlicCount);
sliceBegin = 1;
sliceEnd = groupTogether;
for (i = 0; i < newSlicCount; i++) {
	showProgress(i, newSlicCount);
	if ((i+1) == newSlicCount) {
		sliceEnd = slices;
	}
	selectWindow(title);

	run("Z Project...", "start="+sliceBegin+" stop="+sliceEnd+" projection=[Average Intensity] all");
	rename(i);
		setBatchMode("hide");
	sliceBegin = sliceBegin + groupTogether;
	sliceEnd   = sliceEnd +   groupTogether;

}

selectWindow("0");
rename("base");
for (i = 1; i < newSlicCount; i++) {
	showProgress(i, newSlicCount);
	selectWindow(i);
	run("Concatenate...", "  title=base open image1=base image2="+i+" image3=[-- None --]");
}

getDimensions(width, height, channels, slices, frames);

slices = frames / realFrames;
run("Stack to Hyperstack...", "order=xyctz channels=1 slices="+slices+" frames="+realFrames+" display=Composite");
rename(title + "_groupedZ");

		setBatchMode("show");
