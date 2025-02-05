// OpenSCAD definition for an Acorn Risc PC Power Button
//
// This was measured from a real Risc PC power button to 0.1mm accuracy.
//
// by David Thomas, 28-Jan-25
//

// Overall detail level
$fn = 30;

// Bodge factor
Epsilon = 0.01;

// Width of the main button (X/across)
ButtonWidth = 13.9;
// Depth of the main button (Y/in)
ButtonDepth = 2.9;
// Height of the main button (Z/up)
ButtonHeight = 21.5;

// Width of side pieces (X)
SideWidth = 1.6;
// Depth of left side piece (Y)
LeftSideDepth = 3;
// Depth of right side piece (Y)
RightSideDepth = 2.9;

// Enable additional top fill
ExtraTopFill = false;

// Reinforce the stem by making it solid
SolidStem = false;

// Width of the stem (X)
StemWidth = 4.9;
// Depth of the stem (Y)
StemDepth = 26.3;
// Height of the stem (Z)
StemHeight = 5.9;
// Thickness of stem bars
StemMiddle = 1.7;

// Diameter of clip (X & Z)
ClipDiameter = 5.8; // 5.9 wide, 5.7 high as measured but using an average here
// Depth of clip (Y)
ClipDepth = 9.6;

// Size of square clip cut-out (X & Z)
ClipSquareCutoutSize = 3.5;
// Depth of square clip cut-out (Y)
ClipSquareCutoutDepth = 9.0;

// Width of wide clip cut-out (X)
ClipMouthWidth = 6;
// Depth of wide clip cut-out (Y)
ClipMouthDepth = 4;
// Height of wide clip cut-out (Z)
ClipMouthHeight = 1.5;

// Radius of grip bars inside mouth
ClipGripperRadius = 0.5;

// Enable power symbol on button
EnableSymbol = true;
// Diameter of symbol
SymbolDiameter = 5;
// Depth of symbol from button front
SymbolDepth = 0.3;
// Offset of symbol from button bottom
SymbolYPosition = 3.15;
// Stroke thickness of symbol
SymbolThickness = 0.25;

// Enable push impression on button
EnablePushImpression = true;
// Diameter of sphere
PushImpressionSize = 45;
// Depth of impression from button front
PushImpressionDepth = 1;
// Offset of impression from button bottom
PushImpressionYPosition = 14;

module powersymbol() {
	linear_extrude(SymbolDepth)
		union() {
			difference() {
				circle(d = SymbolDiameter);
				circle(d = SymbolDiameter - SymbolThickness * 2);
			}
			square([SymbolThickness, SymbolDiameter * 3 / 4], center = true);
		}
}

module plainfront() {
	union() {
		// front
		button = [ButtonWidth, ButtonDepth, ButtonHeight];
		cube(size = button);

		lefthand = [SideWidth, LeftSideDepth, ButtonHeight];
		translate([0, ButtonDepth, 0])
			cube(size = lefthand);

		righthand = [SideWidth, RightSideDepth, ButtonHeight];
		translate([ButtonWidth - SideWidth, ButtonDepth, 0])
			difference() {
				cube(size = righthand);

				// using Epsilon here to avoid edges colliding
				t = SideWidth;
				translate([0, RightSideDepth - t, -Epsilon])
					linear_extrude(ButtonHeight + Epsilon * 2)
						polygon(points=[[t + Epsilon, -Epsilon],
								[t + Epsilon, t + Epsilon],
								[-Epsilon, t + Epsilon]]);
			}
		
		// top fill (additional)
		if (ExtraTopFill) {
			top = [ButtonWidth - SideWidth * 2, LeftSideDepth, SideWidth];
			translate([SideWidth, ButtonDepth, ButtonHeight - SideWidth])
				cube(size = top);
		}
	}
}

module adornedfront() {
	union() {
		difference() {
			plainfront();
			
			// push impression
			if (EnablePushImpression) {
				translate([ButtonWidth / 2, -PushImpressionSize / 2 + PushImpressionDepth, PushImpressionYPosition])
					sphere(d = PushImpressionSize, $fn = $fn * 5);
			}
		}

		// power symbol
		if (EnableSymbol) {
			translate([ButtonWidth / 2, -SymbolDepth, SymbolYPosition])
				rotate([-90, 0, 0])
					powersymbol();
		}
	}
}

module stem() {
	if (!SolidStem) {
		union() {
			// cross part
			linear_extrude(StemDepth)
				union() {
					square([StemMiddle, StemHeight], center = true);
					square([StemWidth, StemMiddle], center = true);
				}

			// clip part
			translate([0, 0, StemDepth + ClipDepth / 2])
				cylinder(h = ClipDepth, r = ClipDiameter / 2, center = true);
		}
	} else {
		translate([0, 0, (StemDepth + ClipDepth) / 2])
			cylinder(h = StemDepth + ClipDepth, r1 = ClipDiameter / 2, r2 = ClipDiameter / 2, center = true);
	}
}

module clipcutter() {
	difference() {
		union() {
			// cut out the square section
			translate([0, 0, (ClipDepth - ClipSquareCutoutDepth) / 2 + Epsilon])
				cube([ClipSquareCutoutSize, ClipSquareCutoutSize, ClipSquareCutoutDepth], center = true);

			// cut out the mouth section
			translate([0, 0, (ClipDepth - ClipMouthDepth) / 2 + Epsilon]) {
				cube([ClipMouthWidth, ClipMouthHeight, ClipMouthDepth], center = true);
				
				// round off the mouth section
				translate([0, 0, -ClipMouthDepth / 2])
					rotate([0, 90, 0])
						cylinder(h = ClipMouthWidth, r = 0.75, center = true);
			}
		}
		
		// add grip bars inside the mouth
		
		y = ClipSquareCutoutSize / 2 + ClipGripperRadius / 2;
		
		translate([0, y, ClipSquareCutoutDepth / 2 - 1])
			rotate([0, 90, 0])
				cylinder(h = ClipSquareCutoutSize, r = ClipGripperRadius, center = true);
		
		translate([0, -y, ClipSquareCutoutDepth / 2 - 1])
			rotate([0, 90, 0])
				cylinder(h = ClipSquareCutoutSize, r = ClipGripperRadius, center = true);
	}
}

module cutstem() {
	difference() {
		stem();
		
		translate([0, 0, StemDepth + ClipDepth / 2])
			clipcutter();
	}
}

union() {
	adornedfront();
	
	translate([ButtonWidth / 2, ButtonDepth, 17 - StemHeight / 2])
		rotate([-90, 0, 0])
			cutstem();
}
