/* Julian Schroers  
 *  
 *  To determine interrater reliability, a coordinate system consisting of 50 columns and 50 rows per slice is applied.
 *  
 */

run("Set Scale...", "distance=1 known=1 pixel=1 unit=pixel");
run("Remove Overlay");

width = getWidth();
height = getHeight();
getDimensions(width, height, channels, slices, frames);

Dialog.create("horizontallines");
Dialog.addNumber("Horizontal Lines:", 50);
Dialog.show();
horizontallines = Dialog.getNumber();

Dialog.create("verticallines");
Dialog.addNumber("Vertical Lines:", 50);
Dialog.show();
verticallines = Dialog.getNumber();

tileWidth = width / verticallines;
tileHeight = height / horizontallines;

z = 1;

while (z <= slices) {
	// change slice
	setSlice(z);
    xoff = 0;
    yoff = 0;
    // draw horizontal lines
    while (yoff <= height) {
    	setColor("black");
    	drawLine(0, yoff, width, yoff);
    	setColor("white");
    	drawLine(0, yoff + tileHeight/10, width, yoff + tileHeight/10);
    	yoff += tileHeight;
    }
    // draw vertical lines
    while (xoff <= width) {
    	setColor("black");
    	drawLine(xoff, 0, xoff, height);
    	setColor("white");
    	drawLine(xoff + tileWidth/10, 0, xoff + tileWidth/10, height);
    	xoff += tileWidth;
    }
	z += 1;
}

z = 1;

while (z <= slices) {
	// change slice
    setSlice(z);
    xoff = 0;
    yoff = 0;
    x = 1;
    y = 1;

    while (yoff <= height) {
    	// number for every square
        while (xoff <= width) {
        	// set font
            setFont("Terminal", tileWidth/5);
            setColor("white");
            drawString(z + "." + y + "." + x, xoff + tileWidth/5, yoff + tileHeight*4/5);
            setFont("Terminal", tileWidth/5);
            setColor("black");
            drawString(z + "." + y + "." + x, xoff + tileWidth/5, yoff + tileHeight*1/2);
            xoff += tileWidth;
            x += 1;
        }
        xoff = 0;
        x = 1;
        yoff += tileHeight;
        y += 1;
    }
    z += 1;
}
