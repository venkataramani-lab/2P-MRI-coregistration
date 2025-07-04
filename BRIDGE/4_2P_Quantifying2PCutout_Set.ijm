waitForUser("Wähle die Vessels-7slices-Datei aus.");
verzeichnis = getInfo("image.directory") + "einstellungen_2P.txt";

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

widtha = getWidth();
heighta = getHeight();

// Zeichne eine gerade Linie im Bild
makeLine(widtha/4, heighta/5, widtha*3/4, heighta/5); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

waitForUser("Passe die Linie an und drücke dann OK. Linie soll breiter als das Bild sein.");

getLine(x1a, y1a, x2a, y2a, lineWidtha);

run("Reslice [/]..."); // Slice count = 20 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!
run("Reslice [/]..."); // LEFT, und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!

widthb = getWidth();
heightb = getHeight();

makeLine(widthb/4, heightb/5, widthb*3/4, heightb/5); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

// Warte auf die Anpassung der Linie durch den Benutzer
waitForUser("Passe die Linie an und drücke dann OK. Linie soll breiter als das Bild sein.");

// Holen der Linienkoordinaten
getLine(x1b, y1b, x2b, y2b, lineWidthb);

run("Reslice [/]..."); // Slice count = 20 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!

widthe = getWidth();
heighte = getHeight();
makeRectangle(widthe/5, heighte/5, widthe*3/5, heighte*3/5);
waitForUser("Croppe das Bild auf die ursprüngliche 2P-Größe.");
getSelectionBounds(x_crop1, y_crop1, width_crop1, height_crop1);
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
		waitForUser("Schaue dir an, bei welchem z angefangen werden soll. Orientiere dich dabei am MRT-Bild.");
		Dialog.create("first_z");
		Dialog.addNumber("Bei welchem z soll angefangen werden?", 3);
		Dialog.show();
		first_z = Dialog.getNumber();
		last_z = first_z + 6;
	}
	
	// waitForUser("Speichere die Datei als 2P_groupedz. Schließe sie dann, öffne sie erneut und drücke dann OK.");
	waitForUser(first_z + " - " + last_z + ": Füge, wenn nötig, leere Slices am Ende hinzu.");
	
	// SOLL NOCH AUTOMATISIERT WERDEN:
	run("Duplicate...", "duplicate range=" + first_z + "-" + last_z); // 7 Slices auswählen
}

// Erstelle Arrays, um die Infos zu speichern
linesData_a = newArray(x1a, y1a, x2a, y2a, lineWidtha);
linesData_b = newArray(x1b, y1b, x2b, y2b, lineWidthb);
linesData_duplicate = newArray(first_z, last_z);
linesData_crop = newArray(x_crop1, y_crop1, width_crop1, height_crop1);

// Öffnen der txt-Datei
file = File.open(verzeichnis);

// Schreiben der Daten in txt-Datei
File.append(String.join(linesData_a, ","), verzeichnis);
File.append(String.join(linesData_b, ","), verzeichnis);
File.append(String.join(linesData_duplicate, ","), verzeichnis);
File.append(String.join(linesData_crop, ","), verzeichnis);

// Schließen der Datei
File.close(file);

waitForUser("Fertig! Die Einstellungs-Datei befindet sich hier: " + verzeichnis + ".\nSpeichere die fertigen Bilder als _resliced ab!");