name = getTitle();
path = getDirectory("Ordner wählen ...");

Dialog.create("Slices");
Dialog.addNumber("Slices:", 80);
Dialog.show();
slices = Dialog.getNumber();
firstslice = 1;
lastslice = slices;

Dialog.create("Echos");
Dialog.addNumber("Echos:", 16);
Dialog.show();
echos = Dialog.getNumber();

frames = slices * echos;

Dialog.create("TR");
Dialog.addNumber("TR:", 73.862);
Dialog.show();
tr = Dialog.getNumber();

Dialog.create("First Echo");
Dialog.addNumber("First Echo:", 2.565);
Dialog.show();
firstecho = Dialog.getNumber();
echo = firstecho;

Dialog.create("Echo Spacing");
Dialog.addNumber("Echo Spacing:", 4);
Dialog.show();
echospacing = Dialog.getNumber();

for (i = 1; i <= echos; i++) {
	run("Duplicate...", "duplicate range=" + firstslice + "-" + lastslice + " use");
	newfile = name + "_TR" + tr + "_TE" + echo;
	rename(newfile);
	saveAs("Tiff", path + '\\' + newfile + ".tif");
	close();
	selectWindow(name);
	echo += echospacing;
	firstslice += slices;
	lastslice += slices;
}