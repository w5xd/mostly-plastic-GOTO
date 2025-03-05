/**************************************************************************
   OnStepElevationPulley (c) 2025 by Wayne E Wright,
   https://www.thingiverse.com/wwrr55
   is licensed under Attribution-ShareAlike 4.0 International. To view a
   copy of this license, visit
   http://creativecommons.org/licenses/by-sa/4.0/
*****************************************************************************/

use <Pulley_Helpers.scad>

partToPrint = 0; // [0:all, 1:hub supports]
teeth = 300;
Hadley_Bearing_Mount_Square_side_mm = 23.6;
Hadley_Bearing_Mount_Hub_Diameter_bottom_mm = 25.4 * 3;
Hadley_Bearing_Mount_Hub_OD_top_mm = Hadley_Bearing_Mount_Square_side_mm * 2.5;
Hadley_Bearing_Mount_Hole_Diameter_mm = 5.5;
Central_Height_z_spacer_mm = 3;
outer_rim_radial_thickness = 5;
number_of_spokes = 10;

pulley_teeth_height_mm = 10.5;
belt_capture_mm = 18;
crossSection = 0; // [0:100]

module __no_customizer() {}

$fa = $preview ? 20 : 1;
$fs = $preview ? 5 : 0.1;

base_height = 25.4 / 16;
alt_idler_height = base_height;
alt_base_diameter = 2 + (teeth * 2 / PI);
alt_base_cut_diameter = (teeth * 2 / PI) - 2 * outer_rim_radial_thickness;

Central_Bearing_wall_thickness_mm = 25.4 / 5;
central_height = Central_Height_z_spacer_mm + base_height + alt_idler_height + pulley_teeth_height_mm;

spoke_width_mm = 10;
spoke_rounding_radius_mm = 3;

stlSolidBodymm = 0.01;

if (partToPrint == 0)
    main();
else
    hubCutout(0.1); // supports for 3D printing

module hubCutout(zOffset = 0)
{
    translate([0, 0, zOffset - stlSolidBodymm])
        linear_extrude(height = central_height - Central_Bearing_wall_thickness_mm,
            scale = [1, 1] * Hadley_Bearing_Mount_Hub_OD_top_mm / Hadley_Bearing_Mount_Hub_Diameter_bottom_mm)
        offset(-Central_Bearing_wall_thickness_mm)
        circle(d = Hadley_Bearing_Mount_Hub_Diameter_bottom_mm);
}

function rot_angle_from_omit(teeth, omit) = omit * 180 / teeth;

module pulleyBase(teeth, rim_mm, height, omit = 0)
{
    difference()
    {
        // pulley main
        rotate([0, 0, 180 + rot_angle_from_omit(teeth, omit)])
            rotate_extrude(angle = (teeth - omit) * 360 / teeth, $fa = 180 / teeth)
            translate([pully_OD(teeth) / 2 - rim_mm, 0])
                square([rim_mm, height]);
        // cut teeth out of pulley     
        rotate([0, 0, 270 + (omit + 1) * 180 / teeth])
            translate([0, 0, -stlSolidBodymm])
            linear_extrude(height = height + 2 * stlSolidBodymm)
                cut_teeth_from_pulley(teeth, omit = omit);
    }
}

// slot into pulley to capture the belt...or half of one such that the other half is mirror of this.
module beltCapture(mainTeeth, mainOmit) {
    teeth = 16;
    omit = 12;
    rim = 4.5;
    straightTeeth = 12;
    rotate([0, 0, -rot_angle_from_omit(mainTeeth, mainOmit)])
    translate([(pully_OD(teeth) - pully_OD(mainTeeth)) / 2, 0])
    {
    rotate([0, 0, 180 + 45])
        pulleyBase(teeth, rim, pulley_teeth_height_mm, omit);
    translate([0, -pully_OD(teeth) / 2])
        {
            // radial rack is angle zero--would meet at the origin of the pulley
            // parallel to X axis rack is angle rot_angle_from_omit(mainTeeth, mainOmit)
            // 0.75 cants the racks towards each other more slowly than radial. 
            a = 0.75 * rot_angle_from_omit(mainTeeth, mainOmit);
            rotate([0, 0, a])
            difference() 
            {
                roundmm = 1;
                translate([0, 0, -base_height])
                    mirror([1, 0, 0])
                    rotate([0, 270, 0])
                    linear_extrude(height = belt_capture_mm)
                    offset(roundmm)
                    offset(-roundmm)
                    square([pulley_teeth_height_mm + base_height, rim]);
                translate([0, 0, -stlSolidBodymm])
                    linear_extrude(height = pulley_teeth_height_mm + 2 * stlSolidBodymm)
                    cut_teeth_along_rack(straightTeeth);
            }
        }
    }
}

module main() {
    intersection()
    {
        difference()
        {
            union()
            {
                omit = 6;
                difference()
                {
                    union()
                    {
                        // pulley with teeth
                        pulleyBase(teeth, outer_rim_radial_thickness, pulley_teeth_height_mm, omit);
                        // base
                        translate([0, 0, -base_height])
                            cylinder(h = base_height, d = alt_base_diameter);
                        // idler
                        chamfer = 1.5;
                        rot_profile = [[0, 0], [outer_rim_radial_thickness - chamfer, 0], [outer_rim_radial_thickness, chamfer], [outer_rim_radial_thickness, alt_idler_height], [0, alt_idler_height]];
                        translate([0, 0, pulley_teeth_height_mm])
                            rotate([0, 0, 180 + rot_angle_from_omit(teeth, omit)])
                            rotate_extrude(angle = (teeth - omit) * 360 / teeth)
                            translate([alt_base_diameter / 2 - outer_rim_radial_thickness, 0])
                            polygon(rot_profile);
                    }
                    // hollow out the base
                    translate([0, 0, -stlSolidBodymm - base_height])
                        cylinder(h = pulley_teeth_height_mm * 2, d = alt_base_cut_diameter);
                }
                translate([0, 0, -base_height])
                {
                    // central bearing
                    difference()
                    {
                        union()
                        {
                            linear_extrude(height = central_height, 
                                scale = [1, 1] * Hadley_Bearing_Mount_Hub_OD_top_mm / Hadley_Bearing_Mount_Hub_Diameter_bottom_mm)
                                circle(d = Hadley_Bearing_Mount_Hub_Diameter_bottom_mm);
                            for (spoke = [0:1 : number_of_spokes - 1])
                            {
                                rotate([0, 0, spoke * 360 / number_of_spokes])
                                {
                                    rotate([0, -90, 0])
                                        linear_extrude(height = alt_base_cut_diameter / 2)
                                        translate([0, -spoke_width_mm / 2])
                                        offset(spoke_rounding_radius_mm)
                                        offset(-spoke_rounding_radius_mm)
                                        square([pulley_teeth_height_mm + base_height, spoke_width_mm]);

                                }
                            }
                        }
                        // remove any part of a spoke that interferes with the "belt Capture" structure
                        yextent = 4;
                        translate([-alt_base_cut_diameter / 2 - stlSolidBodymm, -yextent / 2, base_height - stlSolidBodymm])
                            cube([belt_capture_mm, yextent, pulley_teeth_height_mm + 2 * stlSolidBodymm]);
                        // hollow out the hub
                        hubCutout();
                    }
                }
                // capture the belt ends
                beltCapture(teeth, omit);
                mirror([0, 1, 0])
                    beltCapture(teeth, omit);

            }
            // mounting holes match Hadley telescope
            holes1 = [[1, 1], [1, -1], [-1, -1], [-1, 1]];
            translate([0, 0, -stlSolidBodymm - base_height])
                for (i = [0:1 : len(holes1) - 1])
                {
                    s = Hadley_Bearing_Mount_Square_side_mm * 0.5 * holes1[i];
                    translate(s)
                        cylinder(d = Hadley_Bearing_Mount_Hole_Diameter_mm, h = 2 * (stlSolidBodymm + pulley_teeth_height_mm));
                }
        }
        if (crossSection > 0) //viewing tool
            translate([0, 0, (crossSection / 100) * 2 * pulley_teeth_height_mm])
            cube([alt_base_diameter * 2, alt_base_diameter * 2, 2 * (stlSolidBodymm + pulley_teeth_height_mm)], center = true);
    }
}

