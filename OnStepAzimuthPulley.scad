/**************************************************************************
   OnStepAzimuthPulley (c) 2025 by Wayne E Wright,
   https://www.thingiverse.com/wwrr55
   is licensed under Attribution-ShareAlike 4.0 International. To view a
   copy of this license, visit
   http://creativecommons.org/licenses/by-sa/4.0/
*****************************************************************************/

use <Pulley_Helpers.scad>
use <./libraries/threads.scad> // https://github.com/rcolyer/threads-scad

part=0; // [0:main, 1:support]

teeth = 200;
Azimuth_Bearing_Hub_Diameter_bottom_mm = 25;
Azimuth_Bearing_Clearance_Z_mm = 8;
Azimuth_Bearing_Clearance_Radius_mm = 40;

Hub_lock_screws = false;

Central_Height_z_spacer_mm = 0;
outer_rim_radial_thickness = 5;
number_of_spokes = 8;
pulley_teeth_height_mm = 10.5;
bearing_hole_diameter_mm = 9.9;
hub_extra_height_mm = 4;
hub_lock_screw_hole_diameter_mm = 3.2;
hub_lock_nut_side_mm = 5.9;
hub_lock_nut_thickness_mm = 2.6;
hub_lock_socket_diameter_mm = 6;
module __no_customizer() {}

$fa = $preview ? 20 : 1;
$fs = $preview ? 5 : 0.1;

mm_per_inch = 25.4;

base_height = mm_per_inch / 16;
alt_idler_height = base_height;
alt_base_diameter = 2 + (teeth * 2 / PI);
alt_base_cut_diameter = (teeth * 2 / PI) - 2 * outer_rim_radial_thickness;

Central_Bearing_wall_thickness_mm = 25.4 / 5;
central_height = Central_Height_z_spacer_mm + base_height + alt_idler_height + pulley_teeth_height_mm + hub_extra_height_mm;

echo(str("Full height = ", central_height / mm_per_inch, " in."));

spoke_width_mm = 10;
spoke_rounding_radius_mm = 3;

stlSolidBodymm = 0.01;

if (part == 0)
    main();
else
{
    translate([0, 0, 1])
        cut_space_for_bearing();
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

module hub_lock_cuts()
{
    if (Hub_lock_screws)
        rotate([0,90,180 + 180/number_of_spokes])
        {
            cylinder(d=hub_lock_screw_hole_diameter_mm, h=Azimuth_Bearing_Clearance_Radius_mm);
            translate([0,0,bearing_hole_diameter_mm*1.5])
                cylinder(d=hub_lock_socket_diameter_mm, h=Azimuth_Bearing_Clearance_Radius_mm);
            extend_beyond_hub_surface = 10;
            translate([-extend_beyond_hub_surface/2,0,bearing_hole_diameter_mm*.85])
                cube(center=true,[hub_lock_nut_side_mm+extend_beyond_hub_surface, hub_lock_nut_side_mm, hub_lock_nut_thickness_mm]);
        }
}

module cut_space_for_bearing()
{
    translate([0,0,-base_height-.01])
        cylinder(h=Azimuth_Bearing_Clearance_Z_mm, r=Azimuth_Bearing_Clearance_Radius_mm);
}

module main() {
    intersection()
    {
        difference()
        {
            ScrewHole(10, central_height + .02)
            {
                difference()
                {
                    union()
                    {
                        // pulley with teeth
                        pulleyBase(teeth, outer_rim_radial_thickness, pulley_teeth_height_mm);
                        // base
                        translate([0, 0, -base_height])
                            cylinder(h = base_height, d = alt_base_diameter);
                        // idler
                        chamfer = 1.5;
                        rot_profile = [[0, 0], [outer_rim_radial_thickness - chamfer, 0], 
                                [outer_rim_radial_thickness, chamfer], [outer_rim_radial_thickness, alt_idler_height], 
                                [0, alt_idler_height]];
                        translate([0, 0, pulley_teeth_height_mm])
                            rotate_extrude(angle = 360)
                            translate([alt_base_diameter / 2 - outer_rim_radial_thickness, 0])
                            polygon(rot_profile);
                    }
                 }
                translate([0, 0, -base_height])
                {
                    // central bearing
                    difference()
                    {
                        union()
                        {
                            spoke_lift = hub_extra_height_mm + pulley_teeth_height_mm / 2;
                            tilt = atan((2 * spoke_lift)/pully_OD(teeth) );
                            linear_extrude(height = central_height)                              
                                circle(d = Azimuth_Bearing_Hub_Diameter_bottom_mm);
                            translate([0,0, spoke_lift])
                            for (spoke = [0:1 : number_of_spokes - 1])
                            {
                                rotate([0, 0, spoke * 360 / number_of_spokes])
                                {
                                    rotate([0, -90 - tilt, 0])
                                        linear_extrude(height = alt_base_cut_diameter / 2)
                                        translate([0, -spoke_width_mm / 2])
                                        offset(spoke_rounding_radius_mm)
                                        offset(-spoke_rounding_radius_mm)
                                        square([pulley_teeth_height_mm + base_height, spoke_width_mm]);

                                }
                            }
                            spoke_match_radius_mm = Azimuth_Bearing_Clearance_Radius_mm + 6;
                            cylinder(h=3*base_height, r=spoke_match_radius_mm);
                        }
                    }
                }
            } 

            cut_space_for_bearing();
            translate([0,0,-base_height-.01])
            {
                //cylinder(h=central_height + .02, d=bearing_hole_diameter_mm);
                translate([0,0,central_height])
                    cylinder(h=100, r=Azimuth_Bearing_Clearance_Radius_mm);
                translate([0,0,central_height- 1.2 * hub_lock_screw_hole_diameter_mm])
                {
                    hub_lock_cuts();
                    rotate([0,0,90])
                        hub_lock_cuts();
                }
            }
        }
    }
}

