run("Threshold...");
setThreshold(10000, 65535, "raw");
run("Convert to Mask", "method=Otsu background=Light black");
run("32-bit");
