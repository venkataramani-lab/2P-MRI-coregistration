requires("1.43j");

// Holen des aktuellen Verzeichnisses der ersten Datei und Erstellen der CSV-Datei
verzeichnis = getInfo("image.directory") + "einstellungen.txt";

// Setze die gewünschten Parameter für die Reslice-Operation
// SOLL NOCH AUTOMATISIERT WERDEN:
run("Reslice [/]..."); // "Rotate 90 degrees" und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!

widtha = getWidth();
heighta = getHeight();

// Zeichne eine gerade Linie im Bild
makeLine(widtha/4, heighta/5, widtha*3/4, heighta/5); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

// Warte auf die Anpassung der Linie durch den Benutzer
waitForUser("Passe die Linie an und drücke dann OK.");

// Holen der Linienkoordinaten
getLine(x1a, y1a, x2a, y2a, lineWidtha);

// SOLL NOCH AUTOMATISIERT WERDEN:
run("Reslice [/]..."); // Slice count = 75 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!
run("Reslice [/]..."); // "Rotate 90 degrees" und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!
run("Reslice [/]..."); // "Rotate 90 degrees" und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!

widthb = getWidth();
heightb = getHeight();

// Zeichne eine gerade Linie im Bild
makeLine(widthb/4, heightb/5, widthb*3/4, heightb/5); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

// Warte auf die Anpassung der Linie durch den Benutzer
waitForUser("Passe die Linie an und drücke dann OK.");

// Holen der Linienkoordinaten
getLine(x1b, y1b, x2b, y2b, lineWidthb);

// SOLL NOCH AUTOMATISIERT WERDEN:
run("Reslice [/]..."); // Slice count = 50 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!

// xy des 2P-Bilds erfragen
Dialog.create("x_2P");
Dialog.addNumber("x des 2P-Bilds:", 4096);
Dialog.show();
x_2P = Dialog.getNumber();
Dialog.create("y_2P");
Dialog.addNumber("y des 2P-Bilds:", 4096);
Dialog.show();
y_2P = Dialog.getNumber();

// Cropping 1
x_zu_y = x_2P / y_2P;
widthc = getWidth();
heightc = getHeight();
makeRectangle(widthc/5, heightc/5, widthc*3/5, heightc*3/5);
waitForUser("Passe die Form an und drücke dann OK. Hier schon auf das Seitenverhältnis achten - es soll mit dem 2P übereinstimmen! x:y = " + x_zu_y);
getSelectionBounds(x_crop1, y_crop1, width_crop1, height_crop1);
run("Crop");

// z auswählen (mit Duplicate)
waitForUser("Schaue dir an, bei welchem z angefangen werden soll.");
Dialog.create("first_z");
Dialog.addNumber("Bei welchem z soll angefangen werden?", 3);
Dialog.show();
first_z = Dialog.getNumber();
last_z = first_z + 6;
// SOLL NOCH AUTOMATISIERT WERDEN:
waitForUser("Gib gleich folgendes ein: " + first_z + "-" + last_z);
run("Duplicate..."); // 7 Slices auswählen
waitForUser("Speichere hier die Datei 2P_originalxy.");

// Scaling (auf Größe des 2P-Bilds)
widthd = getWidth();
heightd = getHeight();
x_adjust = x_2P / widthd;
y_adjust = y_2P / heightd;

if (x_adjust >= y_adjust) {
	// SOLL NOCH AUTOMATISIERT WERDEN:
	waitForUser("Gib im folgenden Fenster bei x " + x_adjust + " ein.");
	run("Scale..."); // x_adjust eingeben und no Interpolation
	xory = 0; // gibt in txt-Datei an, ob in if oder else gesprungen werden soll
} else {
	// SOLL NOCH AUTOMATISIERT WERDEN:
	waitForUser("Gib im folgenden Fenster bei x " + y_adjust + " ein.");
	run("Scale..."); // y_adjust eingeben und no Interpolation
	xory = 1; // gibt in txt-Datei an, ob in if oder else gesprungen werden soll
};

// Cropping 2
widthe = getWidth();
heighte = getHeight();
makeRectangle(widthe/5, heighte/5, widthe*3/5, heighte*3/5);
waitForUser("Passe die Form an und drücke dann OK. Hier sollen nur noch wenige Pixel angepasst werden, falls es nach dem Upscaling nötig ist.");
getSelectionBounds(x_crop2, y_crop2, width_crop2, height_crop2);
run("Crop");

// Erstelle Arrays, um die Infos zu speichern
linesData_a = newArray(x1a, y1a, x2a, y2a, lineWidtha);
linesData_b = newArray(x1b, y1b, x2b, y2b, lineWidthb);
linesData_crop1 = newArray(x_crop1, y_crop1, width_crop1, height_crop1);
linesData_scale = newArray(x_adjust, y_adjust, xory);
linesData_crop2 = newArray(x_crop2, y_crop2, width_crop2, height_crop2);
linesData_duplicate = newArray(first_z, last_z);

// Öffnen der txt-Datei
file = File.open(verzeichnis);

// Schreiben der Daten in txt-Datei
File.append(String.join(linesData_a, ","), verzeichnis);
File.append(String.join(linesData_b, ","), verzeichnis);
File.append(String.join(linesData_crop1, ","), verzeichnis);
File.append(String.join(linesData_scale, ","), verzeichnis);
File.append(String.join(linesData_crop2, ","), verzeichnis);
File.append(String.join(linesData_duplicate, ","), verzeichnis);

// Schließen der Datei
File.close(file);

waitForUser("Fertig! Die Einstellungs-Datei befindet sich hier: " + verzeichnis + ". Speichere das fertige Bild noch ab!");