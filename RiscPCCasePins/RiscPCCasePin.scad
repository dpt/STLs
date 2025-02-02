// OpenSCAD definition for Acorn Risc PC Locking Pin(s)
//
// This was measured from real Risc PC locking pins to 0.1mm accuracy.
//
// by David Thomas, 31-Jan-25
//

// Number of slices of case that the pin is for
Slices = 1; // [1:Single slice, 2:Double slice]

// Build front pin? (else back pin)
Front = true;

// Overall detail level
$fn = 25;

// Bodge factor
Epsilon = 0.01;

// Back pin: handle width (X/across)
HandleWidth = 39.2;
// Back pin: handle depth (Y/in)
HandleDepth = 9.9;
// Back pin: handle height (Z/up)
HandleHeight = 5.1;
// Back pin: handle inner width
HandleInnerWidth = 7.1;
// Back pin: width of lip around edge of handle
HandleLipWidth = (HandleDepth - HandleInnerWidth) / 2;
// Back pin: height of lip around edge of handle
HandleLipHeight = 1.9;

// Both pins: hole in stem diameter
StemHoleDiameter = HandleDepth - HandleLipWidth * 2;
// Both pins: hole in stem depth (varies in reality)
StemHoleHeight = 14.3; // from cut surface

// Back pin: where the stem is centred
StemHoleCentre = -(HandleWidth - HandleDepth) / 2;

// Back pin: padlock hole diameter
LockHoleDiameter = HandleInnerWidth - 0.7;
// Back pin: padlock hole height
LockHoleHeight = HandleHeight + Epsilon;

// Back pin: pin locking hemisphere diameter
SphereDiameter = HandleDepth - HandleLipWidth * 2;
// Back pin: pin locking hemisphere height
SphereHeight = 1.4;

// Stem: top diameter
StemTopDiameter = 9.8;
// Stem: top depth (varies in reality)
StemTopHeight = Front ? 12 : 12.5;

// Stem: rubber ring inset diameter
StemRubberInsetDiameter = 6.7;
// Stem: rubber ring inset height
StemRubberInsetHeight = 1.9; // recess for rubber band to sit in

// Stem: fixed size portion of height
StemFixedHeight = 12;
// Stem: per-slice height (depth of a case slice)
StemPerSliceHeight = 65;
// Stem: overall height (note rubber ring inset height not part of this)
StemHeight = StemFixedHeight + StemPerSliceHeight * Slices;
// Stem: diameter at top
StemUpperDiameter = 7.1;
// Stem: diameter at bottom
StemBottomDiameter = 3.7; // bit of a guess

// Stem: cutout width
StemCutoutWidth = 4;
// Stem: cutout depth
StemCutoutDepth = 4;
// Stem: cutout height (doesn't vary with number of slices)
StemCutoutHeight = 18;
// Stem: cutout interval
StemCutoutInterval = 20;
// Stem: increase for shallower cuts
StemCutoutOffset = 2;

// Barb: width
BarbWidth = 8;
// Barb: depth
BarbDepth = 2;
// Barb: height
BarbHeight = 8;

// Front pin: width of handle (extends halfway into lip but note lip width comes from Back pin calc)
FrontHandleWidth = 14.9 - StemTopDiameter + HandleLipWidth / 2 - 2.3;
// Front pin: increase this for a chunkier handle
FrontHandleDepth = 2.3;
// Front pin: increase this for a deeper handle
FrontHandleHeight = 6.1;

module capsule(width, radius) {
	hull() {
		x = width / 2 - radius;
		translate([-x, 0, 0]) circle(r = radius);
		translate([+x, 0, 0]) circle(r = radius);
	}
}

module back_pin_top_flat() {
	difference() {
		linear_extrude(HandleHeight, center = true)
			capsule(HandleWidth, HandleDepth / 2);
			
		translate([0, 0, (HandleHeight - HandleLipHeight) / 2 + Epsilon])
			linear_extrude(HandleLipHeight, center = true)
				capsule(HandleWidth - HandleLipWidth * 2, HandleDepth / 2 - HandleLipWidth);
		
		// cut centre hole
		cylinder(h = LockHoleHeight, d = LockHoleDiameter, center = true);
	}
}

module back_pin_top() {
	difference() {
		union() {
			back_pin_top_flat();
			
			// add the top of the stem (must be here so we can cut into it)
			translate([StemHoleCentre, 0, -StemTopHeight / 2 - HandleHeight / 2])
				cylinder(h = StemTopHeight, d = StemTopDiameter, center = true);
		
			// add the spherical protrusion
			translate([-StemHoleCentre, 0, -HandleHeight / 2])
				scale([1, 1, 0.5])
					sphere(d = SphereDiameter);
		}
		
		// cut hole in top of stem
		translate([StemHoleCentre, 0, -StemHoleHeight / 2 + HandleHeight / 2 - HandleLipHeight + Epsilon * 2])
			cylinder(h = StemHoleHeight, d = StemHoleDiameter, center = true);
   }
}

module front_pin_top() {
	difference() {
		union() {
			cylinder(h = StemTopHeight, d = StemTopDiameter, center = true);
			
			translate([StemTopDiameter / 2 + FrontHandleWidth / 2 - HandleLipWidth / 2, 0, StemTopHeight / 2 - FrontHandleHeight / 2]) {
				cube([FrontHandleWidth, FrontHandleDepth, FrontHandleHeight], center = true);
				
				translate([FrontHandleWidth / 2, 0, 0])
					cylinder(h = FrontHandleHeight, d = FrontHandleDepth, center = true);
			 }
	   }
		
		translate([0, 0, 0.7 + Epsilon])
			cylinder(h = 11.2, d = StemHoleDiameter, center = true);
   }
}

module stemcutter(height) {
	dims = [StemCutoutWidth, StemCutoutDepth, height];
	xo = (StemCutoutWidth + StemCutoutOffset) / 2;
	yo = (StemCutoutDepth + StemCutoutOffset) / 2;
	for (x = [-xo, xo])
		for (y = [-yo, yo])
			translate([x, y, - height / 2])
				cube(dims, center = true);
}

module stemcuttergroup() {
	ncuts = 3.5 * Slices + 0.5;
	offset = -2;
	
	for (a = [0 : ncuts - 2])
		translate([0, 0, - StemCutoutInterval * a + offset])
			stemcutter(StemCutoutHeight);
	
	// final cut should be longer (or we get grit in the barb)
	a = floor(ncuts) - 1;
	translate([0, 0, - StemCutoutInterval * a + offset])
		stemcutter(StemCutoutHeight * 2);
}

module barbcutter() {
	// cut away diagonals
	scale(8)
		for (a = [0 : 3])
			rotate([90, 0, 90 * a + 45])
				linear_extrude(height = 2, center = true)
					polygon([[0, 0], [1, 0], [1, 1]]);
}

module stem() {
	difference() {
		union() {
			// inset for rubber band
			translate([0, 0, -StemRubberInsetHeight / 2]) {
				cylinder(h = StemRubberInsetHeight, d = StemRubberInsetDiameter, center = true);

				// main conic
				translate([0, 0, -StemHeight / 2 - StemRubberInsetHeight / 2]) {
					cylinder(h = StemHeight, d1 = StemBottomDiameter, d2 = StemUpperDiameter, center = true);
			
					// barb (square at this point)
					translate([0, 0, -StemHeight / 2 + BarbHeight / 2])
						cube([BarbWidth, BarbDepth, BarbHeight], center = true);
				}
			}
		}

		// cut away the cuboid sections of stem
		translate([0, 0, -StemRubberInsetHeight])
			stemcuttergroup();
		
		// cut the barb
		translate([0, 0, -StemRubberInsetHeight - StemHeight - Epsilon])
			barbcutter();
   }
}

// Total heights as measured from my set of pins for comparison.
// Note that in reality some pins vary by 1/2mm in places.
//
// 1-slice front pin: 90.4mm
// 2-slice front pin: 155.7mm
//
// 1-slice back pin: 96mm
// 2-slice back pin: 160.6mm
//

union() {
	if (Front) {
		total_height = StemTopHeight / 2 + StemRubberInsetHeight + StemHeight;
		translate([0, 0, total_height]) {
			front_pin_top();
			translate([0, 0, -StemTopHeight / 2])
				stem();
		}
	} else {
		total_height = HandleHeight / 2 + StemTopHeight + StemRubberInsetHeight + StemHeight;
		translate([-StemHoleCentre, 0, total_height]) {
			back_pin_top();
			translate([StemHoleCentre, 0, -HandleHeight / 2 - StemTopHeight])
				rotate([0, 0, 90])
					stem();
		}
	}
}
