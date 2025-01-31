// OpenSCAD definition for Acorn Risc PC Locking Pin(s)
//
// This was measured from a real Risc PC locking pin to 0.1mm accuracy.
//
// by David Thomas, 31-Jan-25
//

$fn = 25; // detail level

Epsilon = 0.01; // aka bodge factor

HandleWidth = 39.2;
HandleDepth = 10;
HandleHeight = 5.1;
HandleLipWidth = 1.35; // width of lip around edge of handle
HandleLipHeight = 2;

LockHoleDiameter = 6.5;

StemHoleDiameter = HandleDepth - HandleLipWidth * 2;
StemHoleDepth = 14.3;

StemUpperDiametermeter = 9.8;
StemTopDepth = 12.6;

SphereDiameter = HandleDepth - HandleLipWidth * 2;
SphereHeight = 1.4;

StemHeight = 76.5; // has rubber inset deducted
StemUpperDiameter = 7.1;
StemBottomDiameter = 3.7; // guess

StemRubberInsetHeight = 1.3; // recess for rubber band to sit in
StemRubberInsetDiameter = 6.7;

StemCutoutWidth = 4;
StemCutoutDepth = 4;
StemCutoutHeight = 17.9;
StemCutoutInterval = 20;

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
		cylinder(h = HandleHeight + Epsilon, d = LockHoleDiameter, center = true);
	}
}

module rear_pin_top() {
	difference() {
		union() {
			rear_pin_top_flat();
			
			translate([-(HandleWidth - HandleDepth) / 2, 0, -(HandleHeight + StemTopDepth) / 2])
				cylinder(h = StemTopDepth, d = StemUpperDiametermeter, center = true);
		
			translate([(HandleWidth - HandleDepth) / 2, 0, -HandleHeight / 2])
				scale([1, 1, 0.5])
					sphere(d = SphereDiameter);
		}
		
		// cut bigger hole towards stem
		t = HandleHeight / 2 - HandleLipHeight + 2 * Epsilon; // needed extra bodge
		translate([StemHoleCentre, 0, -StemHoleDepth / 2 + t])
			cylinder(h = StemHoleDepth, d = StemHoleDiameter, center = true);
   }
}

// TODO
module front_pin_top() {
}

module stemcutter(z) {
	x = (StemCutoutWidth + 2) / 2;
	d = (StemCutoutDepth + 2) / 2;
	translate([0, 0, z - StemCutoutHeight / 2]) {
		translate([x, d, 0])
			cube([StemCutoutWidth, StemCutoutDepth, StemCutoutHeight], center = true);
		translate([-x, d, 0])
			cube([StemCutoutWidth, StemCutoutDepth, StemCutoutHeight], center = true);
		translate([x, -d, 0])
			cube([StemCutoutWidth, StemCutoutDepth, StemCutoutHeight], center = true);
		translate([-x, -d, 0])
			cube([StemCutoutWidth, StemCutoutDepth, StemCutoutHeight], center = true);
	}
}

module barbcutter() {
	scale(4 + Epsilon)
		translate([0, 0, 1])
			union() {
				for (a = [0:3])
					rotate([0, 90, a * 90])
						linear_extrude(height = 1, center = true)
							polygon([[1,0], [1,1], [0,1]]);
			}
}

module stem() {
	difference() {
		union() {
			// rubber inset
			translate([0, 0, StemHeight / 2])
				cylinder(h = StemRubberInsetHeight, d = StemRubberInsetDiameter, center = true);

			// main conical cylinder
			cylinder(h = StemHeight, d1 = StemBottomDiameter, d2 = StemUpperDiameter, center = true);
			
			difference() {
				translate([0, 0, -StemHeight / 2 + BarbHeight / 2])
					cube([BarbWidth, BarbDepth, BarbHeight], center = true);
			}
		}

		// cut away the cuboid sections of stem
		z = (StemHeight / 2) - (21 - 17.4); // fix
		for (a = [0:3])  // will need >3 for longer pins
			stemcutter(z - StemCutoutInterval * a);
		
		// cut the barb
		translate([0, 0, -StemHeight / 2])
			barbcutter();
   }
}

union() {
	rear_pin_top();
	translate([StemHoleCentre, 0, -54]) // fix
		rotate([0, 0, 90])
			stem();
}
