// OpenSCAD definition for Acorn Risc PC Locking Pin(s)
//
// This was measured from a real Risc PC locking pin to 0.1mm accuracy.
//
// by David Thomas, 31-Jan-25
//

epsilon = 0.01; // aka bodge factor

width = 39.2;
depth = 10;
height = 5.1;

edge = 1.35; // width of edge/lip

innerheight = 2;

centreholedia = 6.5;
biggerholedia = depth - edge * 2;
biggerholedepth = 14.3;

topstemdia = 9.8;
topstemdepth = 12.6;

spheredia = depth - edge * 2;
sphereheight = 1.4;

stemheight = 76.5; // with rubber deducted
stemtopdia = 7.1;
stembotdia = 3.7; // guess

stemrubberheight = 1.3;
stemrubberdia = 6.7; // recess for rubber to sit in

stemcutwidth = 4;
stemcutdepth = 4;
stemcutheight = 17.9;

stemcutinterval = 20;

barbwidth = 8;
barbdepth = 2;
barbheight = 8;

$fn = 25;

stemcentre = -(width / 2 - depth / 2); // where the stem is centred

module capsule(width, radius) {
    hull() {
        x = width / 2 - radius;
        translate([-x, 0, 0]) circle(r = radius);
        translate([+x, 0, 0]) circle(r = radius);
    }
}

module rear_pin_top_flat() {
    difference() {
        linear_extrude(height, center = true)
            capsule(width, depth / 2);
            
        translate([0, 0, (height - innerheight) / 2 + epsilon])
            linear_extrude(innerheight, center = true)
                capsule(width - edge * 2, depth / 2 - edge);
        
        // cut centre hole
        cylinder(h = height + epsilon, d = centreholedia, center = true);
    }
}

module rear_pin_top() {
    difference() {
        union() {
            rear_pin_top_flat();
            
            translate([-(width - depth) / 2, 0, -(height + topstemdepth) / 2])
                cylinder(h = topstemdepth, d = topstemdia, center = true);
        
            translate([(width - depth) / 2, 0, -height / 2])
                scale([1, 1, 0.5])
                    sphere(d = spheredia);
        }
        
        // cut bigger hole towards stem
        t = height / 2 - innerheight + 2 * epsilon; // needed extra bodge
        translate([stemcentre, 0, -biggerholedepth / 2 + t])
            cylinder(h = biggerholedepth, d = biggerholedia, center = true);
   }
}

module stemcutter(z) {
    x = (stemcutwidth + 2) / 2;
    d = (stemcutdepth + 2) / 2;
    translate([0, 0, z - stemcutheight / 2]) {
        translate([x, d, 0])
            cube([stemcutwidth, stemcutdepth, stemcutheight], center = true);
        translate([-x, d, 0])
            cube([stemcutwidth, stemcutdepth, stemcutheight], center = true);
        translate([x, -d, 0])
            cube([stemcutwidth, stemcutdepth, stemcutheight], center = true);
        translate([-x, -d, 0])
            cube([stemcutwidth, stemcutdepth, stemcutheight], center = true);
    }
}

// TODO causes unclosed mesh or vanishing somehow
module barb() {
    scale(6)
        rotate_extrude($fn = 4)
            translate([1, 0, 0])
                circle(r = 1);
}

module stem() {
    difference() {
        union() {
            // rubber inset
            translate([0, 0, stemheight / 2])
                cylinder(h = stemrubberheight, d = stemrubberdia, center = true);

            // main conical cylinder
            cylinder(h = stemheight, d1 = stembotdia, d2 = stemtopdia, center = true);
            
            difference() {
                translate([0, 0, -stemheight / 2 + barbheight / 2])
                    cube([barbwidth, barbdepth, barbheight], center = true);
            }
        }
        
        // cut away the sections of stem
        z = (stemheight / 2) - (21 - 17.4);
        for (a = [0:3])  // will need >3 for longer pins
            stemcutter(z - stemcutinterval * a);
        
        // cut the barb
        translate([0, 0, -38.5]) // fix
            barb();
    }
}

union() {
    rear_pin_top();
    translate([stemcentre, 0, -54])
        rotate([0, 0, 90])
            stem();
}
