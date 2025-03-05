/**************************************************************************
   Azimuth bearings (c) 2025 by Wayne E Wright,
   https://www.thingiverse.com/wwrr55
   is licensed under Attribution-ShareAlike 4.0 International. To view a
   copy of this license, visit
   http://creativecommons.org/licenses/by-sa/4.0/
*****************************************************************************/

echo("Azimuth-Bearings.scad version 1.0");

/* Printable parts for the Azimuth bearings on a Hadley telescope.
** They are fasteners and supporting mounts for a two-part plywood mount of the sort shown in this video:
** https://hackaday.com/2022/11/04/3d-printed-newtonian-telescope-has-stunning-looks-hadley-breaks-the-bank/
** The plywood parts are (a) the base that sits on the ground and (b) the upper part that turns 
** as the telescope moves in the azimuth direction. In the video above, the building uses a lazy susan
** bearing. 
**
** The bearing design here is not of the lazy susasn design. It instead offers a mount point for
** a pully to install an OnStep-based mechanism for a stepper motor to rotate in azimuth.
** The plywood parts here, instead of the lazy susan, simply have a drilled center hole in the two
** parts. The center hole in the plywood base is drilled for a tight fit for an M10 bolt, and
** the corresponding center hole in the rotating part of the mount is a larger hole, 0.5", to pass
** that same center bolt allowing the top to rotate w.r.t. the bottom.
**
** The weight of the upper dobson rests on 3 x teflon pads (1" x 1" x 1/8" thick).
** The M10 bolt resists lateral movement and supplies axial force only when the mount is lifted
** to be carried, in which case it transfers the weight of the base as an axial load on the 6200 bearing.
** 
** Three parts to print. Bottom to top:
** 1) a lock insert for the head of the M10 bolt to keep it from turning. Fastens to the bottom of the base.
** 2) Mounting template for the three 1" x 1" x 1/8" teflon pads. This template also has a tight-fitting
** center hole to locate the M10. Fastens to the top of the base.
** 3) Mounting template for the 6200 bearing. Fastens to the top of bottom part of the rotating azimuth
** plywood. 
*/


part = 0; // [0:M10 bolt lock, 1:Teflon Skid Template, 2: Bearing Holder]

lockBoltAcrossFlats_mm = 17;
lockBoltHeadThick_mm = 6.6;
lockBoltr_mm = lockBoltAcrossFlats_mm / (cos(30) * 2);
lockBolt_scale = (lockBoltAcrossFlats_mm - .25) / lockBoltAcrossFlats_mm;
lockScrewDiameter_mm = 3.9;

teflonPadWidthmm = 25.9;
teflonPadHeightmm = 25.9;
teflonSkidToCenter = 0.5 * 5 * 25.4;
teflonPadThick = 25.4 / 8;
teflonSkidThick = teflonPadThick /2;
teflonSkidHorzWidth = 25.4 / 4;
teflonSkidSpokeWidth = 20;
teflonSkidVerticalGap_mm = 0.5;
teflonSkidBoltClearance_mm = 9.9;

bearingOD = 30.3;
bearingThickness = 9;

module __no_more_customizer() {}

$fa = $preview ? 15 : 1;
$fs = $preview ? 3 : .1;

module M10HeadLock ()
{
    difference()
    {
        lockThick1 =  floor(lockBoltHeadThick_mm);
        lockThick2 = 25.4 / 10;
        union()
        {
            cylinder(d = 2 * lockBoltAcrossFlats_mm, h = lockThick1);
            cylinder(d = 5 * lockBoltAcrossFlats_mm, h = lockThick2);
        }
        profile = lockBoltr_mm * [for (i = [0:1 : 5], a = i * 60)[sin(a), cos(a)]];
        translate([0,0,-.1])
            linear_extrude(height = lockThick1+.2, scale = lockBolt_scale)
                polygon(profile);
        // screw holes to mount
        for (a = [0,120,240])
            rotate([0,0,a])
                translate([lockBoltAcrossFlats_mm*2.1, 0, -0.1])
                    cylinder(h=lockThick2 + 0.2, d=lockScrewDiameter_mm);
    }
}

module TeflonSkidTemplate()
{
    difference()
    {
       union()
       {         
        linear_extrude(height = teflonPadThick - teflonSkidVerticalGap_mm)
            circle(teflonSkidSpokeWidth);
        for (a = [0,120,240])
            rotate([0,0,a])
                translate([teflonSkidToCenter, 0 ])
                difference()
                {
                    union()
                    {
                     translate([-teflonSkidToCenter, -teflonSkidSpokeWidth /2])
                        linear_extrude(height = teflonSkidThick)
                            square([teflonSkidToCenter, teflonSkidSpokeWidth]);
                        linear_extrude(height = teflonPadThick - teflonSkidVerticalGap_mm)
                            offset(teflonSkidHorzWidth)
                            square(teflonPadWidthmm, center = true);
                    }
                    translate([0,0,-.1])
                    {
                        linear_extrude(height = teflonPadThick)
                            square(teflonPadWidthmm, center = true);
                        translate([-teflonPadWidthmm,0])
                            cylinder(d=lockScrewDiameter_mm, h=teflonPadThick);
                    }
                }
        }
        translate([0,0,-.1])
            cylinder(d=teflonSkidBoltClearance_mm, h=teflonPadThick);
    }
}

module Bearing6200Holder()
{
    holderThick1 = bearingThickness - 0.5;
    holderThick2 = 25.4 / 16;
    difference()
    {
        union()
        {
            cylinder(d = 1.5 * bearingOD, h = holderThick1);
            cylinder(d = 2.5 * bearingOD, h = holderThick2);
        }
        translate([0,0,-.1])
            cylinder(d = bearingOD, h = holderThick1 + .2);
        for (a = [0,120,240])
            rotate([0,0,a])
                translate([bearingOD, 0, -0.1])
                    cylinder(h=holderThick1 + 0.2, d=lockScrewDiameter_mm);
    }
}


if (part == 0)
    M10HeadLock();
else if (part == 1)
    TeflonSkidTemplate();
else if (part == 2)
    Bearing6200Holder();
