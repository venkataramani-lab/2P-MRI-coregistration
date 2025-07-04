waitForUser("Wähle die Vessels-7slices-Datei aus.");
verzeichnis = getInfo("image.directory") + "einstellungen_2P.txt";

// Öffnen der txt-Datei und den Inhalt als String lesen
fileContent = File.openAsString(verzeichnis);
waitForUser(fileContent);
// Zeilen aus dem String extrahieren
lines = split(fileContent, "\n");

linesData_a = split(lines[0], ",");
if (linesData_a.length == 5) {
    x1a = parseFloat(linesData_a[0]);
    y1a = parseFloat(linesData_a[1]);
    x2a = parseFloat(linesData_a[2]);
    y2a = parseFloat(linesData_a[3]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 1): " + lines[0]);
}

linesData_b = split(lines[1], ",");
if (linesData_b.length == 5) {
    x1b = parseFloat(linesData_b[0]);
    y1b = parseFloat(linesData_b[1]);
    x2b = parseFloat(linesData_b[2]);
    y2b = parseFloat(linesData_b[3]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 2): " + lines[1]);
}

values_duplicate = split(lines[2], ",");
if (values_duplicate.length == 2) {
    first_z = parseFloat(values_duplicate[0]);
    last_z = parseFloat(values_duplicate[1]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 3): " + lines[2]);
}

values_crop = split(lines[3], ",");
if (values_crop.length == 4) {
    x_crop1 = parseFloat(values_crop[0]);
    y_crop1 = parseFloat(values_crop[1]);
    width_crop1 = parseFloat(values_crop[2]);
    height_crop1 = parseFloat(values_crop[3]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 4): " + lines[3]);
}

waitForUser("Erstelle Composite von Gefäß- (Ch1) und Gliom- (Ch2) 7slices-Dateien.");
waitForUser("Voxel Size: 1x1x1?");

Dialog.create("slices");
Dialog.addNumber("Number of slices:", 7);
Dialog.show();
slices = Dialog.getNumber();

for (i = 0; i < 8; i++) {
	setSlice(slices*2);
	run("Add Slice", "add=slice");
}

setSlice(1);
for (i = 0; i < 8; i++) {
	run("Add Slice", "add=slice prepend");
}

run("Reslice [/]..."); // TOP und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!


// Zeichne eine gerade Linie im Bild
makeLine(x1a, y1a, x2a, y2a); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

run("Reslice [/]..."); // Slice count = 20 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!
run("Reslice [/]..."); // LEFT, und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!

makeLine(x1b, y1b, x2b, y2b); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

run("Reslice [/]..."); // Slice count = 20 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!

run("Duplicate...", "duplicate");
makeRectangle(x_crop1, y_crop1, width_crop1, height_crop1);
run("Crop");

run("Split Channels");

for (j = 0; j < 2; j++) {
	if (j == 0) {
		waitForUser("Wähle die Gefäß-tif aus.");
	} else {
		waitForUser("Wähle die Gliom-tif aus.");
	}

	run("Flip Vertically");
	run("Rotate 90 Degrees Right");
	run("Flip Z");
	
	// z auswählen (mit Duplicate)
	if (j == 0) {
		
		waitForUser("Stimmt " + first_z + "-" + last_z + "? Gib im nächsten Dialog ein.");
		
		items = newArray("yes", "no");
		Dialog.create("FirstLast_true");
		Dialog.addRadioButtonGroup("Stimmt " + first_z + "-" + last_z + "?", items, 1, 2, "yes");
		Dialog.show();
		FirstLast_true = Dialog.getRadioButton();
		
		if (FirstLast_true == "no") {
			waitForUser("Schaue dir an, bei welchem z angefangen werden soll. Orientiere dich dabei am MRT-Bild.");
			Dialog.create("first_z");
			Dialog.addNumber("Bei welchem z soll angefangen werden?", 3);
			Dialog.show();
			first_z = Dialog.getNumber();
			last_z = first_z + 6;
		}
		
	}
	
	// waitForUser("Speichere die Datei als 2P_groupedz. Schließe sie dann, öffne sie erneut und drücke dann OK.");
	waitForUser(first_z + " - " + last_z + ": Füge, wenn nötig, leere Slices am Ende hinzu.");
	
	// SOLL NOCH AUTOMATISIERT WERDEN:
	run("Duplicate...", "duplicate range=" + first_z + "-" + last_z); // 7 Slices auswählen
}

waitForUser("Fertig! Speichere die fertigen Bilder als _resliced ab.");