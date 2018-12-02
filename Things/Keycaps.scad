/* [Key] */
use <scad-utils/morphology.scad> //for cheaper minwoski 

key_length = 1;  //length in units of key
key_height = 1;  //height in units of key. should remain 1 for most uses

keytop_thickness = 2;  // keytop thickness, aka how many millimeters between the inside and outside of the top surface of the key
wall_thickness = 3;    // wall thickness, aka the thickness of the sides of the keycap. note: 3 = 1.5mm walls

/* [Brim] */
has_brim = 0;//enable brim for connector
brim_radius = 11; //brim radius. 11 ensconces normal keycap stem in normal keycap
brim_depth = .3;  //brim depth

/* [Dish] */
 // invert dishing. mostly for spacebar

/* [Stem] */
stem_profile = 0;  // cherry MX or Alps stem, or totally broken circular cherry stem [0..2]
stem_inset = 0;    // how inset the stem is from the bottom of the k ey. experimental. requires support
stem_offset = 0;   // stem offset in units NOT MM. for stepped caps lock

/* [Hidden] */
$fn = 32;          //change to round things better
unit = 19.05;      //beginning to use unit instead of baked in 19.05
minkowski_radius = 1.75; //minkowski radius. radius of sphere used in minkowski sum for minkowski_key function. 1.75 default for faux G20

//profile specific stuff

/*
 1.  Bottom Key Width: width of the immediate bottom of the key
 2.  Bottom Key Height: height of the immediate bottom of the key
 3.  Top Key Width Difference: mm to subtract from bottom key width to create top key width
 4.  Top Key Height Difference: mm to subtract from bottom key height to create top key height
 5.  Total Depth: how tall the total in the switch is before dishing
 6.  Top Tilt: X rotation of the top. Top and dish obj are rotated
 7.  Top Skew: Y skew of the top of the key relative to the bottom. DCS has some, DSA has none (its centered)
 8.  Dish Type: type of dishing. check out dish function for the options
 9.  Dish Depth: how many mm to cut into the key with
 10. Dish Radius: radius of dish obj, the Sphere or Cylinder that cuts into the keycap
 11. Dish Inversion 
*/

key_profiles = [
// BotWid     BotLen  TopWidD TopLenD totDep  TopTilt TopSkew | DishType DishDep  DishSkewX DishSkewY DishInv
  [18.16,     18.16,  6,      4,      11.5,   -6,     1.75,     0,       1,       0,        0,        false],//DCS ROW 5
	[18.16,     18.16,  6,      4,      8.5,    -1,     1.75,     0,       1,       0,        0,        false],//DCS ROW 1
	[18.16,     18.16,  6.2,    4,      7.5,	  3,      1.75,     0,       1,       0,        0,        false],//DCS ROW 2
	[18.16,     18.16,  6,      4,      6.2,    7,      1.75,     0,       1,       0,        0,        false],//DCS ROW 3
	[18.16,     18.16,  6,      4,      6.2,	  16,     1.75,     0,       1,       0,        0,        false],//DCS ROW 4
	[18.4,      18.4,   5.7,    5.7,    7.4,    0,      0,        1,       1.2,     0,        0,        false],//DSA ROW 3
	[18.4,      18.4,   5.7,    5.7,    13.73,  0,      -14,      1,       1.2,     0,        0,        false],//SA ROW 1
	[18.4,      18.4,   5.7,    5.7,    11.73,  -7,     0,        1,       1.2,     0,        0,        false],//SA ROW 2
	[18.4,      18.4,   5.7,    5.7,    11.73,  0,      0,        1,       1.2,     0,        0,        false],//SA ROW 3
	[18.4,      18.4,   5.7,    5.7,    11.73,  7,      0,        1,       1.2,     0,        0,        false],//SA ROW 4
	[18.16,     18.16,  6,      4,      6.2,    16,     1.75,     2,       1,       0,        0,        false],//SPACEBAR
	[18.16,     18.16,  2, 	    2,      6,	    2.5,    0.75,     3,       0,       0,        0,        false],//G20 AKA DCS Row 2 with no dish
];


function capDim(capIDs, dimIDs) = key_profiles[capIDs][dimIDs];
echo(capDim(5, bottom_key_width));
// Alias for dimID 
bottom_key_width = 0;
bottom_key_height = 1;
width_difference = 2;
height_difference = 3;
total_depth = 4;
top_tilt = 5;  // assume key_height remains 1
top_skew = 6;
dish_type = 7;
dish_depth = 8;
dish_skew_x = 9;
dish_skew_y = 10;
inverted_dish = 11;
// actual mm key width and height
function total_key_width(capIDs) = capDim(capIDs,bottom_key_width) + (unit * (key_length - 1));
function total_key_height(capIDs) = capDim(capIDs,bottom_key_height) + (unit * (key_height - 1));

// actual mm key width and height at the top
function top_total_key_width(capIDs) = capDim(capIDs,bottom_key_width) + (unit * (key_length - 1)) - capDim(capIDs,width_difference);
function top_total_key_height(capIDs) = capDim(capIDs,bottom_key_height) + (unit * (key_height - 1)) - capDim(capIDs,height_difference);


module roundedRect(size = [0,0,0], radius= 1.5) { //simplified to single call using Morphology Util lib
  linear_extrude(size[2])rounding(r=radius)square([size[0], size[1]], center = true);
}

//------  stem related stuff
module inside(){
	difference(){
		translate([0,0,50]) cube([100000,100000,100000],center=true);
		shape(0, 0);
	}
}

module cherry_stem(){
  cross_length = 4.4;                 // cross length
  extra_vertical_cross_length = 1.1;  //extra vertical cross length - the extra length of the up/down bar of the cross
	extra_outer_cross_width = 2.10;   	// outer cross extra length in x
	extra_outer_cross_height = 1.0;     // outer cross extra length in y
	horizontal_cross_width = 1.4;       // horizontal cross bar width
	vertical_cross_width = 1.3;  	      // vertical cross bar width
	cross_depth = 4;   	                // cross depth, stem height is 3.4mm

	difference(){
    union(){
      if (stem_profile != 2){
        translate([-(cross_length+extra_outer_cross_width)/2, -(cross_length+extra_outer_cross_height)/2, stem_inset])
    			cube([cross_length+extra_outer_cross_width, cross_length+extra_outer_cross_height, 15]);
      }
      else {
        cylinder(d = cross_length+extra_outer_cross_height, h = 15);
      }
			if (has_brim == 1){ cylinder(r=brim_radius,h=brim_depth); }
		}
		//the cross part of the steam
		translate([0,0,(cross_depth)/2 + stem_inset]){
	        cube([vertical_cross_width,cross_length+extra_vertical_cross_length,cross_depth], center=true );
	        cube([cross_length,horizontal_cross_width,cross_depth], center=true );
	  }
	}
}

module alps_stem(){
	cross_depth = 40;
	width = 4.45;
	height = 2.25;
	base_width = 12;
	base_height = 15;

	translate([0,0,cross_depth/2 + stem_inset])cube([width,height,cross_depth], center = true);
}

//whole connector, alps or cherry, trimmed to fit
module connector(has_brim){
	difference(){
		translate([-unit * stem_offset, 0, 0])
		union(){
			if(stem_profile == 0 || stem_profile == 2) cherry_stem();
			if(stem_profile == 1) alps_stem();
		}
		inside();
	}
}

//---- shape related stuff
//general shape of key. used for inside and outside
module shape(capID, thickness_difference = 0 , depth_difference= 0){
  if (capDim(capID, inverted_dish) == true){
		difference(){
			union(){
				shape_hull(capID, thickness_difference, depth_difference);
				dish(capID, depth_difference);
			}
			outside(capID, thickness_difference);
		}
	} 
  else{
		difference(){
			shape_hull(capID, thickness_difference, depth_difference);
			dish(capID, depth_difference);
		}
	}
}

// conicalish clipping shape to trim things off the outside of the keycap
// literally just a key with height of 2 to make sure nothing goes awry with dishing etc
module outside(capID, thickness_difference){
	difference(){
		cube([100000,100000,100000],center = true);
		shape_hull(capID, thickness_difference, 0);
	}
}

// super basic hull shape without dish
module shape_hull(capID, thickness_difference, depth_difference){
	hull(){
		roundedRect([total_key_height(capID) - thickness_difference, total_key_height(capID) - thickness_difference, .001],1.5);  //Base Plate 

		translate([0,capDim(capID,top_skew),capDim(capID,total_depth) - depth_difference])
      rotate([-capDim(capID,top_tilt),0,0])
        roundedRect([total_key_height(capID) - thickness_difference - capDim(capID,width_difference), total_key_height(capID) - thickness_difference - capDim(capID,height_difference), .001],1.5); //Top Plate
	}
}


//dish related stuff
//dish selector
module dish(capID, depth_difference){
	if(capDim(capID,dish_type) == 0){cylindrical_dish(capID, depth_difference);}  // cylindrical dish
	else if (capDim(capID,dish_type) == 1){spherical_dish(capID, depth_difference);}// spherical dish
	else if (capDim(capID,dish_type) == 2){sideways_cylindrical_dish(capID, depth_difference);}// SIDEWAYS cylindrical dish
  else if (capDim(capID,dish_type) == 3){}
}

	
module cylindrical_dish(capID, depth_difference){
  chord_length = (pow(top_total_key_width(capID), 2) - 4 * pow(capDim(capID,dish_depth), 2)) / (8 * capDim(capID,dish_depth)); //the distance you have to move the dish up so it digs in capDim(capID,dish_depth) millimeters

	rad = (pow(top_total_key_width(capID), 2) + 4 * pow(capDim(capID,dish_depth), 2)) / (8 * capDim(capID,dish_depth)); 	//the radius of the dish

	if (capDim(capID, inverted_dish) == true){
		translate([capDim(capID,dish_skew_x), capDim(capID,top_skew) + capDim(capID,dish_skew_y), capDim(capID,total_depth) - depth_difference])
		rotate([90-capDim(capID,top_tilt),0,0])
		translate([0,-chord_length,0])
		cylinder(h=100,r=rad, $fn=1024, center=true);
	}
	else{
		translate([capDim(capID,dish_skew_x), capDim(capID, top_skew) + capDim(capID, dish_skew_y), capDim(capID, total_depth) - depth_difference])
		rotate([90-capDim(capID,top_tilt),0,0])
		translate([0,chord_length,0])
		cylinder(h=100,r=rad, $fn=1024, center=true);
	}
}

module hatch() //oh god this is ganna cost...
 {}

 
module spherical_dish(capID, depth_difference){
	//same thing as the cylindrical dish here, but we need the corners to just touch - so we have to find the hypotenuse of the top
	chord = pow((pow(top_total_key_width(capID),2) + pow(top_total_key_height(capID), 2)),0.5); //getting diagonal of the top

	// the distance you have to move the dish up so it digs in capDim(capID,dish_depth) millimeters
	chord_length = (pow(chord, 2) - 4 * pow(capDim(capID,dish_depth), 2)) / (8 * capDim(capID,dish_depth));
	//the radius of the dish
	rad = (pow(chord, 2) + 4 * pow(capDim(capID,dish_depth), 2)) / (8 * capDim(capID,dish_depth));

	if (capDim(capID, inverted_dish) == true){
		translate([capDim(capID,dish_skew_x), capDim(capID,top_skew) + capDim(capID,dish_skew_y), capDim(capID,total_depth) - depth_difference])
		rotate([-capDim(capID,top_tilt),0,0])
		translate([0,0,-chord_length])
		//NOTE: if your dish is long at all you might need to increase this number
		sphere(r=rad, $fn=512);
	}
	else{
		translate([capDim(capID,dish_skew_x), capDim(capID,top_skew) + capDim(capID,dish_skew_y), capDim(capID,total_depth) - depth_difference])
		rotate([-capDim(capID,top_tilt),0,0])
		translate([0,0,chord_length])
		sphere(r=rad, $fn=256);
	}
}

module sideways_cylindrical_dish(capID, depth_difference){
	chord_length = (pow(top_total_key_height(capID), 2) - 4 * pow(capDim(capID,dish_depth), 2)) / (8 * capDim(capID,dish_depth));
	rad = (pow(top_total_key_height(capID), 2) + 4 * pow(capDim(capID,dish_depth), 2)) / (8 * capDim(capID,dish_depth));

	if (capDim(capID, inverted_dish) == true){
		translate([capDim(capID,dish_skew_x), capDim(capID,top_skew) + capDim(capID,dish_skew_y), capDim(capID,total_depth) - depth_difference])
		rotate([90,capDim(capID,top_tilt),90])
		translate([0,-chord_length,0])
		cylinder(h=total_key_height(capID) + 20,r=rad, $fn=1024, center=true); // +20 just cuz
	}
	else{
		translate([capDim(capID,dish_skew_x), capDim(capID,top_skew) + capDim(capID,dish_skew_y), capDim(capID,total_depth) - depth_difference])
		rotate([90,capDim(capID,top_tilt),90])
		translate([0,chord_length,0])
		cylinder(h=total_key_height(capID) + 20,r=rad, $fn=1024, center=true);
	}
}

module keycap(capID = 0, clipOrientation = true){
		difference(){
			shape(capID);
			#shape(capID, wall_thickness, keytop_thickness);
		}
    difference(){
      connector(has_brim);
      if (capDim(capID, inverted_dish) == false)dish(capID,0);
      else {} 
    }
 }

// ACTUAL OUTPUT
//difference(){
 keycap(5);
//	// preview cube, for seeing inside the keycap
//	//cube([100,100,100]);