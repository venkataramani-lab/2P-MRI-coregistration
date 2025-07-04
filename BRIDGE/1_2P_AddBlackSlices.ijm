Dialog.create("slices");
Dialog.addNumber("Number of slices:", 100);
Dialog.show();
slices = Dialog.getNumber();

x = slices/33;
residual_slices = slices - floor(x)*33;
new_slices = 33 - residual_slices;
i=0;

for (i = 0; i < new_slices; i++) {
	setSlice(slices);
	run("Add Slice", "add=slice");
}

waitForUser(new_slices + " hinzugefügt.");
