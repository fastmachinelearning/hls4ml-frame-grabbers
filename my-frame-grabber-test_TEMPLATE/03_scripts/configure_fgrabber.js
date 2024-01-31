// --------------------------------------------------------------------------------
// -- CustomLogic - Configure Frame-Grabber (script example)
// --------------------------------------------------------------------------------
// --        File: customlogic_functions.tcl
// --        Date: 2019-06-27
// --         Rev: 0.3
// --      Author: PP
// --------------------------------------------------------------------------------
// -- 0.1, 2018-11-15, PP, Initial release
// -- 0.2, 2019-04-11, PP, Added Pixel LUT 8-bit and Pixel Threshold examples
// -- 0.3, 2019-06-27, PP, Added Channel/Pipeline field into CustomLogicControlAddress
// --------------------------------------------------------------------------------

// NOTE: This example only covers the Channel/Pipeline 0.
//       For more information on the reference design register map,
//       please refer to the CustomLogic User Guide.

for (var grabber of grabbers) {
	// Write to the Control Register "Scratchpad"
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0000);
	grabber.InterfacePort.set("CustomLogicControlData", "1234567890");
	
	// Read from the Control Register "Scratchpad"
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0000);
	var scratchpad = grabber.InterfacePort.get("CustomLogicControlData");
	console.log("Control Register Scratchpad value is: " + scratchpad);
	
	// Enable Memory Traffic Generator reference design
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0001);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000001);

	// Disable Frame-to-Line bypass (Channel 0)
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x1000);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000002);
	
	// Generate a Memento Event (Channel 0)
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x1001);
	grabber.InterfacePort.set("CustomLogicControlData", 0x7E577E57);
	
	// Program Pixel LUT 8-bit (Channel 0)
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x1002);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000001); 	// Activate programming
	grabber.InterfacePort.set("CustomLogicControlAddress", 0x1003); 	// LUT coefficient address
	var i;
	for (i=255; i>=0; --i) {
		grabber.InterfacePort.set("CustomLogicControlData", i); 		// Write 256 coefficients into the LUT (inverse luminance set)
	}
	grabber.InterfacePort.set("CustomLogicControlAddress", 0x1002);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000200); 	// Disable LUT bypass
	
	// Program Pixel Threshold (Channel 0)
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x1004);
	grabber.InterfacePort.set("CustomLogicControlData", 0x0000007F); 	// Set the threshold level
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000200); 	// Disable Pixel Threshold bypass
}