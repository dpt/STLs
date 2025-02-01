// OpenSCAD definition for an Acorn Risc PC Power Button
//
// This was measured from a real Risc PC power button to 0.1mm accuracy.
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

reinforced = false; // makes the stem a solid tube

stemwidth = 4.9;
stemheight = 5.9;
stemdepth = 26.3;
stemmiddle = 1.7;

cyldia = 5.8; // 5.9 wide, 5.7 high as measured but using an average here
cyldepth = 9.6;

cylcutout = 3.5;
cylcutoutdepth = 9.0;

mouthwidth = 6;
mouthheight = 1.5;
mouthdepth = 4;

griprad = 0.5; // radius of grip bars inside mouth

symbol = true; // enables symbol on button front
symboldia = 5;
symboldepth = 0.3;
symbol_y = 3.15; // from bottom
symbolthickness = 0.25;

push = true; // enables push impression on button front
pushsize = 45; // sphere diameter
pushdepth = 1;
push_y = 14; // from bottom

top = false; // additional top fill

$fn = 30;

module powersymbol() {
    linear_extrude(symboldepth)
        union() {
            difference() {
                circle(d = symboldia);
                circle(d = symboldia - symbolthickness * 2);
            }
            square([symbolthickness, symboldia * 3 / 4], center = true);
        }
}

module plainfront() {
	union() {
        // front
        button = [width, depth, height];
        cube(size = button);

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
		
		// top fill (additional)
		if (top) {
			top = [width - sidewidth * 2, leftdepth, sidewidth];
			translate([sidewidth, depth, height - sidewidth])
				cube(size = top);
	    }
    }
}

module front() {
    union() {
        difference() {
            plainfront();
            
            // push impression
            if (push) {
                translate([width / 2, -pushsize / 2 + pushdepth, push_y])
                    sphere(d = pushsize, $fn = $fn * 5);
            }
        }

		// power symbol
		if (symbol) {
			translate([width / 2, -symboldepth, symbol_y])
				rotate([-90, 0, 0])
                    powersymbol();
		}
	}
}

module cross() {
    if (!reinforced) {
        union() {
            // cross part
            linear_extrude(stemdepth)
                union() {
                    square([stemmiddle, stemheight], center = true);
                    square([stemwidth, stemmiddle], center = true);
                }

            // cylinder part
            translate([0, 0, stemdepth + cyldepth / 2])
                cylinder(h = cyldepth, r = cyldia / 2, center = true);
        }
    } else {
        translate([0, 0, (stemdepth + cyldepth) / 2])
            cylinder(h = stemdepth + cyldepth, r1 = cyldia / 2, r2 = cyldia / 2, center = true);
    }
}

module clipcutout() {
    difference() {
        union() {
            // cut out the square section
            translate([0, 0, (cyldepth - cylcutoutdepth) / 2 + epsilon])
                cube([cylcutout, cylcutout, cylcutoutdepth], center = true);

            // cut out the mouth section
            translate([0, 0, (cyldepth - mouthdepth) / 2 + epsilon]) {
                cube([mouthwidth, mouthheight, mouthdepth], center = true);
                
                // round off the mouth section
                translate([0, 0, -mouthdepth / 2])
                    rotate([0, 90, 0])
                        cylinder(h = mouthwidth, r = 0.75, center = true);
            }
        }
        
        // add grip bars inside the mouth
        
        y = cylcutout / 2 + griprad / 2;
        
        translate([0, y, cylcutoutdepth / 2 - 1])
            rotate([0, 90, 0])
                cylinder(h = cylcutout, r = griprad, center = true);
        
        translate([0, -y, cylcutoutdepth / 2 - 1])
            rotate([0, 90, 0])
                cylinder(h = cylcutout, r = griprad, center = true);
    }
}

module stem() {
    difference() {
        cross();
        
        translate([0, 0, stemdepth + cyldepth / 2])
            clipcutout();
    }
}

union() {
    front();
    
    translate([width / 2, depth, 17 - stemheight / 2])
        rotate([-90, 0, 0])
            stem();
}
