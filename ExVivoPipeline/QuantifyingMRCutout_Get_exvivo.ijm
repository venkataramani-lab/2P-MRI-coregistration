/* Julian Schroers
 * 
 * 
 */
 
waitForUser("Checke in den DICOM-Metadaten, ob ImageOrientationPatient (0020,0037) in beiden Bildern nur 0 und 1 enthält.");
waitForUser("Öffne die schon registrierte Datei und wähle sie an. Im Ursprungs-Ordner soll einstellungen.txt liegen.");

// Holen des aktuellen Verzeichnisses der ersten Datei und Erstellen der CSV-Datei
verzeichnis_get = getInfo("image.directory") + "einstellungen_Get.txt";

rename("Set");

// Holen des Verzeichnisses der txt-Datei
verzeichnis = getInfo("image.directory") + "einstellungen.txt";

// Öffnen der txt-Datei und den Inhalt als String lesen
fileContent = File.openAsString(verzeichnis);
waitForUser(fileContent);
// Zeilen aus dem String extrahieren
lines = split(fileContent, "\n");

valuesa = split(lines[0], ",");
if (valuesa.length == 5) {
    x1a = parseFloat(valuesa[0]);
    y1a = parseFloat(valuesa[1]);
    x2a = parseFloat(valuesa[2]);
    y2a = parseFloat(valuesa[3]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 1): " + lines[0]);
}

// Lese die Werte aus der zweiten Zeile der Datei (x1b, y1b, x2b, y2b)
valuesb = split(lines[1], ",");
if (valuesb.length == 5) {
    x1b = parseFloat(valuesb[0]);
    y1b = parseFloat(valuesb[1]);
    x2b = parseFloat(valuesb[2]);
    y2b = parseFloat(valuesb[3]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 2): " + lines[1]);
}

// Lese die Werte aus der dritten Zeile der Datei: Crop1
values_crop1 = split(lines[2], ",");
if (values_crop1.length == 4) {
    x_crop1 = parseFloat(values_crop1[0]);
    y_crop1 = parseFloat(values_crop1[1]);
    width_crop1 = parseFloat(values_crop1[2]);
    height_crop1 = parseFloat(values_crop1[3]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 3): " + lines[2]);
}

// Lese die Werte aus der sechsten Zeile der Datei: z-Anpassung/Duplicate
values_duplicate = split(lines[3], ",");
if (values_duplicate.length == 2) {
    first_z = parseFloat(values_duplicate[0]);
    last_z = parseFloat(values_duplicate[1]);
} else {
    waitForUser("Ungültige Zeile in der Datei (Zeile 4): " + lines[3]);
}

// PixelSize_1 erfragen
Dialog.create("PixelSize_1");
Dialog.addNumber("Pixel Size des schon registrierten Bilds (um):", 100);
Dialog.show();
PixelSize_1 = Dialog.getNumber();

// PixelSize_2 erfragen
Dialog.create("PixelSize_2");
Dialog.addNumber("Pixel Size des zu registrierenden Bilds (um):", 100);
Dialog.show();
PixelSize_2 = Dialog.getNumber();

adjust = PixelSize_1 / PixelSize_2;

waitForUser("Lade die ausgerichtete, zu registrierende Datei und wähle sie an.");
rename("Get");

// Setze die gewünschten Parameter für die Reslice-Operation

// Zeichne die erste Linie
makeLine(x1a*adjust, y1a*adjust, x2a*adjust, y2a*adjust); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen
waitForUser("Bewege die Linie nach oben.");
getLine(x1a_neu, y1a_neu, x2a_neu, y2a_neu, lineWidtha_neu);

// SOLL NOCH AUTOMATISIERT WERDEN:
run("Reslice [/]..."); // Slice count = 200 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!
run("Reslice [/]..."); // "LEFT" und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!

// Zeichne die zweite Linie
makeLine(x1b*adjust, y1b*adjust, x2b*adjust, y2b*adjust); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen
waitForUser("Bewege die Linie nach oben.");
getLine(x1b_neu, y1b_neu, x2b_neu, y2b_neu, lineWidthb_neu);

// SOLL NOCH AUTOMATISIERT WERDEN:
run("Reslice [/]..."); // Slice count = 200 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!

run("Rotate 90 Degrees Left");

width_adjusted = width_crop1 * adjust;
height_adjusted = height_crop1 * adjust;

makeRectangle(10,10,width_adjusted,height_adjusted);
waitForUser("Verschiebe das Rechteck für den Crop, sodass es ungefähr mit dem schon registrierten originalxy-Bild übereinstimmt.");
getSelectionBounds(x_rectangle, y_rectangle, width_rectangle, height_rectangle);
run("Crop");

run("Flip Horizontally");

waitForUser("Gib gleich bei x und z folgendes ein: " + PixelSize_2/PixelSize_1);
run("Scale...");

// z auswählen (mit Duplicate)
waitForUser("Schaue dir an, bei welchem z angefangen werden soll. Orientiere dich dabei an der schon registrierten Sequenz. Wähle dann das zu registrierende Bild an.");
Dialog.create("first_z_2");
Dialog.addNumber("Bei welchem z soll angefangen werden?", 1);
Dialog.show();
first_z_2 = Dialog.getNumber();
Dialog.create("slice_number");
Dialog.addNumber("Wie viele Slices?", 10);
Dialog.show();
slice_number = Dialog.getNumber();
last_z_2 = first_z_2 + slice_number - 1;
// SOLL NOCH AUTOMATISIERT WERDEN:
waitForUser("Gib gleich folgendes ein: " + first_z_2 + "-" + last_z_2);
run("Duplicate..."); // 7 Slices auswählen
waitForUser("Speichere hier die Datei.");


// Translation (Registration)
run("ROI Manager...");
waitForUser("Öffne Fix und Moving Volume. Wähle zunächst mehrere Punkte im Fix Volume aus, dann die gleichen Punkte in der gleichen Reihenfolge im Moving Volume. Speichere das ROI-Set ab und wähle das zu registrierende Bild aus.");

nROIs = roiManager("count");
nROIs_perImage = nROIs/2;

Stack.setXUnit("pixel");
run("Properties...", "channels=1 slices=" + slice_number + " frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");

run("Set Measurements...", "centroid redirect=None decimal=2");
x_shift = 0;
y_shift = 0;

for (i = 0; i < nROIs_perImage; i++) {
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
run("Translate...", "x=" + x_shift + " y=" + y_shift + " interpolation=None stack");

waitForUser("Speichere hier MR_originalxy.");

waitForUser("Scale gleich auf x=4000.");
run("Scale..."); // no Interpolation

// Erstelle Arrays, um die Infos zu speichern
linesData_a = newArray(x1a_neu, y1a_neu, x2a_neu, y2a_neu, lineWidtha_neu);
linesData_b = newArray(x1b_neu, y1b_neu, x2b_neu, y2b_neu, lineWidthb_neu);
PixelSize = newArray(PixelSize_1, PixelSize_2);
Rectangle = newArray(x_rectangle, y_rectangle, width_rectangle, height_rectangle);
linesData_duplicate = newArray(first_z_2, last_z_2);
shift = newArray(x_shift, y_shift);

// Öffnen der txt-Datei
file = File.open(verzeichnis_get);

// Schreiben der Daten in txt-Datei
File.append(String.join(linesData_a, ","), verzeichnis_get);
File.append(String.join(linesData_b, ","), verzeichnis_get);
File.append(String.join(PixelSize, ","), verzeichnis_get);
File.append(String.join(Rectangle, ","), verzeichnis_get);
File.append(String.join(linesData_duplicate, ","), verzeichnis_get);
File.append(String.join(shift, ","), verzeichnis_get);

// Schließen der Datei
File.close(file);

waitForUser("Fertig! Speichere das Bild ab. Die Einstellungs-Datei befindet sich hier: " + verzeichnis_get);