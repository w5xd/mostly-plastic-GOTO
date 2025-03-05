use <Pulley_Helpers.scad>
include <Pulley_T-MXL-XL-HTD-GT2_N-tooth-thing16627.scad>     

HW_square_nut_hole_across_flats_mm = 5.9;
HW_square_nut_hole_thickness_mm = 2.6;
HW_screw_clearance_mm = 3.3;
teeth = 20;

module __no_customizer() {}
// Customizer interacts poorly with "include" directive above
$fa = $preview ? 20 : 1;
$fs = $preview ? 5 : 0.1;

D_Shaft_Diameter_mm = 6.1;
D_Shaft_Narrow_mm = 5.6;

profile = -1;
motor_shaft = 0;
retainer = 1;
retainer_ht = 2;
idler_ht = 2;
pulley_b_ht = idler_ht;
idler = 1;
pulley_t_ht =  10.5;

profile = -1;

alt_base_diameter = 2 + (teeth * 1.5 *2 / PI);

stlSolidBodymm = 0.01;

hh = HW_square_nut_hole_across_flats_mm * 1.25;


difference()
{
    union()
    {
        pulley("GT2 2mm" , GT2_2mm_pulley_dia , 0.764 , 1.494, profile=12); 
        translate([0,0,-hh+stlSolidBodymm])
            cylinder(d=alt_base_diameter, h=hh);
    }
    translate([0,0,-hh-stlSolidBodymm])
    {
        linear_extrude(height = hh+ 2 * pulley_t_ht)
            polygon(DshaftProfile(D_Shaft_Diameter_mm, D_Shaft_Narrow_mm));
        translate([(D_Shaft_Diameter_mm) * 1.1 /2, -HW_square_nut_hole_across_flats_mm/2])
        linear_extrude(height = HW_square_nut_hole_across_flats_mm * 1.5)
            square([HW_square_nut_hole_thickness_mm, HW_square_nut_hole_across_flats_mm]);
        translate([0,0,HW_square_nut_hole_across_flats_mm *.55])
            rotate([0,90,0])
            cylinder(d=HW_screw_clearance_mm, h= alt_base_diameter/2);
    }

}

