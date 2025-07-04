/* Julian Schroers
 * 
 * 
 */
 
// Holen des aktuellen Verzeichnisses der ersten Datei und Erstellen der CSV-Datei
verzeichnis = getInfo("image.directory") + "einstellungen.txt";

// Setze die gewünschten Parameter für die Reslice-Operation

widtha = getWidth();
heighta = getHeight();

// Zeichne eine gerade Linie im Bild
makeLine(widtha/4, heighta/5, widtha*3/4, heighta/5); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

// Warte auf die Anpassung der Linie durch den Benutzer
waitForUser("Passe die Linie an und drücke dann OK. Setze sie nach oben.");

// Holen der Linienkoordinaten
getLine(x1a, y1a, x2a, y2a, lineWidtha);

// SOLL NOCH AUTOMATISIERT WERDEN:
run("Reslice [/]..."); // Slice count = 200 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!
run("Reslice [/]..."); // "LEFT" und "Avoid interpolation" (?) auswählen - das soll auch noch automatisiert werden!

widthb = getWidth();
heightb = getHeight();

// Zeichne eine gerade Linie im Bild
makeLine(widthb/4, heightb/5, widthb*3/4, heightb/5); // Passe die Koordinaten an, um die Linie an deinen Bedarf anzupassen

// Warte auf die Anpassung der Linie durch den Benutzer
waitForUser("Passe die Linie an und drücke dann OK. Setze sie nach oben.");

// Holen der Linienkoordinaten
getLine(x1b, y1b, x2b, y2b, lineWidthb);

// SOLL NOCH AUTOMATISIERT WERDEN:
run("Reslice [/]..."); // Slice count = 200 einstellen, "Avoid interpolation" (?) auswählen, "Rotate 90 degrees" nicht auswählen - das soll auch noch automatisiert werden!

run("Rotate 90 Degrees Left");

waitForUser("Wähle Rechteck zum Croppen aus.");
getSelectionBounds(x_crop1, y_crop1, width_crop1, height_crop1);
run("Crop");

run("Flip Horizontally");

// z auswählen (mit Duplicate)
waitForUser("Schaue dir an, bei welchem z angefangen werden soll. Orientiere dich dabei an der Mikroskopie.");
Dialog.create("first_z");
Dialog.addNumber("Bei welchem z soll angefangen werden?", 10);
Dialog.show();
first_z = Dialog.getNumber();
Dialog.create("slice_number");
Dialog.addNumber("Wie viele Slices?", 10);
Dialog.show();
slice_number = Dialog.getNumber();
last_z = first_z + slice_number - 1;
// SOLL NOCH AUTOMATISIERT WERDEN:
waitForUser("Gib gleich folgendes ein: " + first_z + "-" + last_z);
run("Duplicate...");
waitForUser("Speichere hier die Datei MR_originalxy.");

waitForUser("Scale gleich auf x=4000.");
run("Scale..."); // no Interpolation

// Erstelle Arrays, um die Infos zu speichern
linesData_a = newArray(x1a, y1a, x2a, y2a, lineWidtha);
linesData_b = newArray(x1b, y1b, x2b, y2b, lineWidthb);
linesData_crop1 = newArray(x_crop1, y_crop1, width_crop1, height_crop1);
linesData_duplicate = newArray(first_z, last_z);

// Öffnen der txt-Datei
file = File.open(verzeichnis);

// Schreiben der Daten in txt-Datei
File.append(String.join(linesData_a, ","), verzeichnis);
File.append(String.join(linesData_b, ","), verzeichnis);
File.append(String.join(linesData_crop1, ","), verzeichnis);
File.append(String.join(linesData_duplicate, ","), verzeichnis);

// Schließen der Datei
File.close(file);

waitForUser("Fertig! Die Einstellungs-Datei befindet sich hier: " + verzeichnis + ". Speichere das fertige Bild noch ab!");