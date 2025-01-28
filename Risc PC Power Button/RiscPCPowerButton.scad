// OpenSCAD definition for an Acorn Risc PC Power Button
//
// by David Thomas, 28-Jan-25
//

epsilon = 0.01; // aka bodge factor

width = 13.9;
height = 21.5;
depth = 2.9;

sidewidth = 1.6;
leftdepth = 3;
rightdepth = 2.9;

stemwidth = 4.9;
stemheight = 5.9;
stemdepth = 26.3;
stemmiddle = 1.7;

cyldia = 5.8; // 5.9 wide, 5.7 high as measured but using an average here
cyldepth = 9.6;
cyldetail = 30;

cylcutout = 3.5;
cylcutoutdepth = 9.0;

mouthwidth = 10;
mouthheight = 1.5;
mouthdepth = 5;

symboldia = 5;
symboldepth = 0.3;
symbol_y = 6.3 / 2; // from bottom
symboldetail = cyldetail;
symbolthickness = 0.25;

pushsize = 45; // sphere diameter
pushdepth = 1;
push_y = 14; // from bottom
pushdetail = 150;

difference() {
	union() {
		// front
		button = [width, depth, height];
		cube(size = button);

		// stem
		translate([width / 2, depth, 17 - stemheight / 2])
			rotate([-90, 0, 0])
				union() {
					// cross part
					linear_extrude(stemdepth)
						union() {
							square([stemmiddle, stemheight], center = true);
							square([stemwidth, stemmiddle], center = true);
						}

					// cylinder part
					translate([0, 0, stemdepth + cyldepth / 2]) {
						difference() {
							cylinder(h = cyldepth, r = cyldia / 2, center = true, $fn = cyldetail);
							translate([0, 0, (cyldepth - cylcutoutdepth) / 2 + epsilon])
								cube([cylcutout, cylcutout, cylcutoutdepth], center = true);

							// this ought to be rounded at the nearside
							translate([0, 0, (cyldepth - mouthdepth) / 2 + epsilon])
								cube([mouthwidth, mouthheight, mouthdepth], center = true);
						}
					}
				}

		lefthand = [sidewidth, leftdepth, height];
		translate([0, depth, 0])
			cube(size = lefthand);

		righthand = [sidewidth, rightdepth, height];
		translate([width - sidewidth, depth, 0])
			difference() {
				cube(size = righthand);

				// using epsilon here to avoid edges colliding
				t = sidewidth;
				translate([0, rightdepth - t, -epsilon])
					linear_extrude(height + epsilon * 2)
						polygon(points=[[t + epsilon, -epsilon],
								[t + epsilon, t + epsilon],
								[-epsilon, t + epsilon]]);
			}

		// power symbol
		translate([width / 2, -symboldepth, symbol_y])
			rotate([-90, 0, 0])
				linear_extrude(1)
					union() {
						difference() {
							circle(d = symboldia, $fn = symboldetail);
							circle(d = symboldia - symbolthickness * 2, $fn = symboldetail);
						}
						square([symbolthickness, 3], center = true);
					}
	}

	// push impression
	translate([width / 2, -pushsize / 2 + pushdepth, push_y])
		sphere(d = pushsize, $fn = pushdetail);
}
