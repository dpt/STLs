// OpenSCAD definition for Acorn Risc PC Locking Pin(s)
//
// This was measured from a real Risc PC locking pin to 0.1mm accuracy.
//
// by David Thomas, 31-Jan-25
//

// Total heights
//
// 1-slice front pin: 90.4mm
// 1-slice rear pin: 96mm
// 2-slice front pin: 155.7mm
// 2-slice rear pin: <won't fit in my calipers!>

// Remember that the real locking pins for three slices or greater are made of metal.

$fn = 25; // detail level

Epsilon = 0.01; // aka bodge factor

Slices = 2;

HandleWidth = 39.2; // X
HandleDepth = 9.9; // Y
HandleHeight = 5.1; // Z
HandleInnerWidth = 7.1;
HandleLipWidth = (HandleDepth - HandleInnerWidth) / 2; // width of lip around edge of handle
HandleLipHeight = 1.9;

LockHoleDiameter = 6.4;
LockHoleHeight = HandleHeight + Epsilon;

StemHoleDiameter = HandleDepth - HandleLipWidth * 2;
StemHoleDepth = 14.3; // from cut surface

StemTopDiameter = 9.8;
StemTopDepth = 12.6;

SphereDiameter = HandleDepth - HandleLipWidth * 2;
SphereHeight = 1.4;

StemFixedHeight = 12.0;
StemPerSliceHeight = 64.8; // depth of a case slice
StemHeight = StemFixedHeight + StemPerSliceHeight * Slices; // has had rubber inset deducted
StemTotalHeight = StemHeight; // total height of variable stem
StemUpperDiameter = 7.1;
StemBottomDiameter = 3.7; // guess

StemRubberInsetHeight = 1.9; // recess for rubber band to sit in
StemRubberInsetDiameter = 6.7;

StemCutoutWidth = 4;
StemCutoutDepth = 4;
StemCutoutHeight = 18; // doesn't vary with number of slices
StemCutoutInterval = 20;
StemCutoutOffset = 2;

BarbWidth = 8;
BarbDepth = 2;
BarbHeight = 8;

StemHoleCentre = -(HandleWidth - HandleDepth) / 2; // where the stem is centred

module capsule(width, radius) {
	hull() {
		x = width / 2 - radius;
		translate([-x, 0, 0]) circle(r = radius);
		translate([+x, 0, 0]) circle(r = radius);
	}
}

module rear_pin_top_flat() {
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

module rear_pin_top() {
	difference() {
		union() {
			rear_pin_top_flat();
			
			// add the top of the stem (must be here so we can cut into it)
			translate([StemHoleCentre, 0, -StemTopDepth / 2 - HandleHeight / 2])
				cylinder(h = StemTopDepth, d = StemTopDiameter, center = true);
		
			// add the spherical protrusion
			translate([(HandleWidth - HandleDepth) / 2, 0, -HandleHeight / 2])
				scale([1, 1, 0.5])
					sphere(d = SphereDiameter);
		}
		
		// cut bigger hole in top of stem
		translate([StemHoleCentre, 0, -StemHoleDepth / 2 + HandleHeight / 2 - HandleLipHeight + Epsilon * 2])
			cylinder(h = StemHoleDepth, d = StemHoleDiameter, center = true);
   }
}

// TODO
module front_pin_top() {
}

module stemcutter() {
	dims = [StemCutoutWidth, StemCutoutDepth, StemCutoutHeight];
	xo = (StemCutoutWidth + StemCutoutOffset) / 2;
	yo = (StemCutoutDepth + StemCutoutOffset) / 2;
	for (x = [-xo, xo])
		for (y = [-yo, yo])
			translate([x, y, - StemCutoutHeight / 2])
				cube(dims, center = true);
}

module stemcuttergroup() {
	ncuts = 4 * Slices - 1;
	for (a = [0 : ncuts - 1])
		translate([0, 0, - StemCutoutInterval * a - 2])
			stemcutter();
}

// FIXME: 45deg is too high, should be less
module barbcutter() {
	scale(4 + Epsilon)
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
				translate([0, 0, -StemTotalHeight / 2 - StemRubberInsetHeight / 2]) {
					cylinder(h = StemTotalHeight, d1 = StemBottomDiameter, d2 = StemUpperDiameter, center = true);
			
					// barb (square at this point)
					translate([0, 0, -StemTotalHeight / 2 + BarbHeight / 2])
						cube([BarbWidth, BarbDepth, BarbHeight], center = true);
				}
			}
		}

		// cut away the cuboid sections of stem
		translate([0, 0, -StemRubberInsetHeight])
			stemcuttergroup();
		
		// cut the barb
		translate([0, 0, -StemRubberInsetHeight - StemTotalHeight])
			barbcutter();
   }
}

union() {
	rear_pin_top();
	translate([StemHoleCentre, 0, -HandleHeight / 2 - StemTopDepth])
		rotate([0, 0, 90])
			stem();
	// barbcutter();
	// stemcuttergroup();
}
