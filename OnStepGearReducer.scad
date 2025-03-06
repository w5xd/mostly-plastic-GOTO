/**************************************************************************
   OnStep Gear box (c) 2025 by Wayne E Wright,
   https://www.thingiverse.com/wwrr55
   is licensed under Attribution-ShareAlike 4.0 International. To view a
   copy of this license, visit
   http://creativecommons.org/licenses/by-sa/4.0/
*****************************************************************************/

echo("OnStepGearReducer.scad version 1.0");

use <MCAD/involute_gears.scad>
use <libraries/threads.scad>
use <Pulley_Helpers.scad>

/* 
This is a design of a planetary gear box of gear ratio
(about) 26:1 in two 5:1 stages (5.0909 if you must be exact.)
I used a pair of these to add goto capability to my Hadley Telescope.

The input hole pattern is for a NEMA-17 format stepper motor.
The output format is a 6mm diameter D-flatted shaft.
Each planet gear is fitted with a size 623 bearing fastened
with an M3 machine screw x 12mm and a M3 hex nut. There are 4 planets
in the first stage, and 4 more in the second stage.
The output shaft requires a 636 bearing. If this looks a lot like
https://www.thingiverse.com/thing:8460, that is because I studied
that one. This design uses the same MCAD module for involute gear teeth.

The intermediate carrier+sun in the 2 stage version has one more
piece of non-printed hardware: a length of the same 6mm D-shaft
held by friction.

Before building either of the above, the author strongly recommends
printing and assembling the test case that is printed if you set the
very first two Customizer properties this way: 
    Only_Animated_Parts=true; 
    Orientation=1; 

The test gears printed in this way take a couple of hours to print and 
match the gear geometry of the final assembly.
Take the test printed parts, assemble them on a flat surface, e.g.
a table top, and test that they have the appropriate clearances.
If there is any resistance to turning the sun while holding the
ring, either you haven't put it together right yet, or it needs
printing adjustments (most likely the filament extrusion setting.)

The author has assembled and tested only the default settings
as shown below. The OpenScad customizer invites you to change
anything here you want.

FDM printing notes.

The MakeStl-TwoStage.cmd file is a (Windows cmd) script
that generates one each of the needed STL files to print.
You'll need to duplicate the planet 8 times, the retainer
times 2, and the carrier spacer by 4.

The author used Prusament PC Blend filament
.40 mm nozzle
.20 mm layer height
5 mm brim
4 perimeters

Supports
    1. auto-generated supports on the bearing housing
    2. for the ring housing, no auto-generated supports and
    support enforcer volume housing-supports.
    3. Slice with 4 perimeters (gears need to be stiff)

Assembly order:
1. Press fit the sun gear to the NEMA17 stepper shaft.
   There are M3 holes for a set screw and square nut.
2. Fasten the stepper to the motor housing with 4 x M3 screws.
    Mine were 6mm long.
3. Assemble the 623 bearings into the planet gears and
    onto the carriers. M3 socket head x 12mm and M3 hex nut each.
4. Cut a 6mm D shaft that matches (or, of course, slightly
    shorter than) the length of the first carrier with the
    integrated sun gear. Press this shaft into the plastic
    part. Its purpose is to stiffen the part and protect
    the plastic part's stress across its weakest section.
    The D shaft does not connect to any other parts.
5. Insert the intermediate carrier into the housing, planet gears
    down. You wil have to jockey the gears to match up with
    the housing teeth. Press the carrier all the way down
    onto the sun gear installed in (1).
6. Install the split Planet Retainer ring in the slot
    above the planet gears.
7. Install the output 6mm D-shaft into the output carrier.
8. Install the output carrier, planet gears first. The
   carriers each have a locator hole. Align the locator
   holes in the two carriers to get them to mate the
   first time. The carriers are NOT symmetrical across
   the four spokes! Use the locator holes or they won't fit together.
9. Install the second split ring Planet Retainer.
10.Press fit the 636 bearing into the Output Bearing
    housing.
11.Install the Output Bearing Housing onto the Housing
    with 4X M3 socket screws x 8mm and M3 nuts. (Maybe use
    a 10mm M3 to first start the nuts into the housing, then
    go with 8mm.)
*/

/* [View] */
Only_Animated_Parts = false;
Orientation = 0; // [0:In Place, 1: FDM Printing]
ShowFullParts = !Only_Animated_Parts;
Show_All = true;
Show_Sun = false;
Show_Planet = false;
Show_Housing = false;
Show_Planet_Retainer = false;
Show_Intermediate_Carrier = false;
Show_Final_Carrier = false;
Show_Output_Bearing_Housing = false;
Side_Mount_Support = false;
Show_Side_Mount_cleat = false;
Show_Side_Mount_cleat_lock = false;
Motor_Mount = true;
Side_Mount = true;
Cross_Section_View = false;
Cross_Section = 0.5; // [0:.033333:1.0]
Cross_Section_Angle = 0; // [0:180]

/* [Gear settings] */
Gear_thickness_mm = 11;
Sun_teeth = 11;
Sun_teeth_ = max(2, Sun_teeth);
Ring_teeth = 45;
Ring_teeth_ = max(Ring_teeth, Sun_teeth_);
// minimum outer diameter in mm.
Housing_outer_diameter_mm = 60;
Number_of_Stages = 2; // [1:1:5]
Number_of_planets = 4; // [1:1:5]
Planet_teeth = floor((Ring_teeth_ - Sun_teeth_) / 2);

Num_stages_ = min(max(1,Number_of_Stages), 5);
bAll = Show_All;
bSun = Show_All || Show_Sun;
bPlanet = Show_All || Show_Planet;
bRing = Show_All || Show_Housing;
bCarrierFinal = Show_All || Show_Final_Carrier;
bCarrierM = (Num_stages_ > 1) &&  (Show_All || Show_Intermediate_Carrier);
bRetainer = Show_All || Show_Planet_Retainer;
bBearing = Show_All || Show_Output_Bearing_Housing;
bMotor = Motor_Mount;
bSideMount = Side_Mount;
bBraceLock = Show_All || Show_Side_Mount_cleat_lock;
bBrace = Show_All || Show_Side_Mount_cleat;

showTotal = (bSun ? 1 : 0 ) + (bPlanet ? 1 : 0) + (bRetainer ? 1 : 0) +
    (bCarrierFinal ? 1 : 0) + (bCarrierM ? 1 : 0) + (bRing ? 1 : 0) + (bBearing ? 1 : 0);
bSideMountSupport = Side_Mount_Support && ((Side_Mount && showTotal == 0) || (Orientation == 0));

/* [Sun] */
Motor_Collar_z_Thickness_mm = 11.1;
Motor_Collar_Diameter_mm = 20;
Motor_Dshaft_mm = 5.15;
Motor_DshaftNarrow_mm = 4.65;
Motor_Dshaft_round_Z_extent_mm = 11; // Starts at bottom of collar

/* [Carrier] */
// mm
Carrier_thickness_mm = 6;
Carrier_planet_Z_offset_mm = 1.25;
Carrier_output_bearing_Z_offset_mm = 0.6;
Carrier_output_extra_Z_into_bearing_housing_mm = 1.5;
Carrier_output_extra_clearance_radius_mm = 0.5;
Spacers = 2; // [0:None, 1:Only, 2:Integral, 3:Split for FDM]
Dshaft_mm = 6.1;
Dshaft_narrow_mm = 5.5;
Shaft_block_z_thickness_mm = 1;

/* [Ring] */
InterStageSpacerZgapmm = 0.25; // at least FDM layer thickness 
PlanetRetainerRadialGapmm = 0.15;
PlanetRetainerRThicknessmm = 3.0;
PlanetRetainerZThicknessmm = 2.0;
PlanetRetainerSplitGapmm = 2.0;
Number_Output_Bearing_Mounts = 4;
Bearing_Mount_Angular_extent = 20;

/* [Motor Mount] */
Motor_Mount_OffsetToSun_mm = 14;
// NEMA-17 hole spacing is 31mm
Motor_Mount_HoleSpacing_mm = 31.01;
Motor_Mount_Sun_HoleDiameter_mm = 24;
Motor_Mount_Thickness_mm = 2.01;

/* [Side Mount Boss] */
Side_Mount_Thickness_mm = 3;
Side_Mount_Horz_Ext_mm = 65;
Side_Mount_Horz_Offset_mm = 15;
Side_Mount_Screw_Slot_Width_mm = 4.45; // M4 Hex bolt body is 4.2. #8 is 4.45
Side_Mount_Screw_Head_Width_Clearance_mm = 8.5; // M4 Hex bolt head clear. #8 is same
Side_Mount_Screw_Head_Height_Clearance_mm = 3.1; // M4 Hex bolt. #8 is same
Side_Mount_Cleat_width_mm = 2;
Side_Mount_Cleat_z_thickness_mm = 10;
Side_Mount_Cleat_bolt_thickness_mm = 7;
Side_Mount_Cleat_Lock_thickness_overlap_mm = 4.5;
Side_Mount_Cleat_extend_into_cleat_lock_mm = 3;
Side_Mount_Cleat_Lock_thickness_mm = 10.01;
Side_Mount_Cleat_Lock_z_thickness_mm = 10;
Side_Mount_Cleat_Lock_z_clearance_mm = 0.25;
Side_Mount_Cleat_Lock_narrower_mm = 12;

/* [Hardware] */
// Most Defaults are M3. The Hardware settings apply to: motor mount, bearing housing mount, Sun lock screw, planet bearings
HW_hex_nut_circle_diam_mm = 7;
HW_socket_head_height_mm = 3;
HW_screw_clearance_mm = 3.3;
HW_nut_thickness_mm = 2.4;
HW_nut_support_thickness_mm = 1.5;
HW_nut_across_flats_mm = 5.5;
HW_square_nut_hole_across_flats_mm = 5.9;
HW_square_nut_hole_thickness_mm = 2.6;
HW_socket_Head_clear_diameter_mm = 5.9;
HW_nut_vertex_radius_mm = 0.5 * HW_nut_across_flats_mm / sin(60);
HW_nut_hole_profile = (HW_nut_vertex_radius_mm + .2) * [for (i = [0:1:5], a = i * 60)[sin(a), cos(a)]];
HW_cleat_screw_body_dia_mm = 4.1656 ; // #8 
HW_cleat_screw_thread_pitch_mm = .79375; //#8-32
HW_cleat_nut_across_flats_mm = .34 * 25.4; //#8
HW_cleat_nut_profile = (0.5 * HW_cleat_nut_across_flats_mm / sin(60)) * [for (i = [0:1:5], a=i*60)[sin(a), cos(a)]];
HW_cleat_nut_thickness_mm = 0.13 * 25.4;

/* [Bearings] */
// planet bearing 623
Planet_bearing_bore_mm = 3;
Planet_bearing_thick_mm = 4;
Planet_bearing_OD_mm = 10.15;

// output bearing 636
Output_bearing_bore_mm = 6;
Output_bearing_thick_mm = 7;
Output_bearing_OD_mm = 22.25;

/* [involute gear parameters] */
// Pitch is in mm
Pitch = 3.63;
// angle in degrees
Pressure_angle = 28;
// units of mm
Backlash = 0.01;
// units of mm
Clearance = 0.25;

module __nothing_in_GUI_beyond_here() {}

$fa = $preview ? 10 : .5;
$fs = $preview ? 2 : .2;
ring_radius = Ring_teeth_ * Pitch / (2 * PI);
housing_radius = max(ring_radius + Pitch, Housing_outer_diameter_mm / 2);
orbit_radius = ((Planet_teeth + Sun_teeth_) * Pitch) / (2 * PI);
stageHeight = Gear_thickness_mm + Carrier_thickness_mm + Carrier_planet_Z_offset_mm + Carrier_output_bearing_Z_offset_mm;
housing_height = (bMotor ? Motor_Mount_OffsetToSun_mm : 0) + Num_stages_ * stageHeight;
side_mount_rotation_angle = (Number_Output_Bearing_Mounts > 0) ? (180 / Number_Output_Bearing_Mounts) - 90 : 0;
sun_handle_height = 20;

stlSolidOverlap = 0.025; //kludge required for OpenScad to know solids sharing a boundary are one and not two.
carrier_ani_angle = $t * 360;

module crossSectionVolume()
{
    crossSectionCubeHeight = Motor_Mount_OffsetToSun_mm + (Num_stages_+1) * 
        stageHeight + output_bearing_housing_z_thickness + Motor_Mount_Thickness_mm;
    xyMax = 2.1 * BearingMountingBossOuter + Side_Mount_Horz_Ext_mm + Side_Mount_Horz_Offset_mm;
    translate([0,0,crossSectionCubeHeight/2-Motor_Mount_OffsetToSun_mm - Motor_Mount_Thickness_mm])
    rotate([0,0,Cross_Section_Angle])
    translate([0,Cross_Section_View ? (xyMax * Cross_Section) : 0, 0])
             cube([xyMax, xyMax,   crossSectionCubeHeight], center=true);
}

if (Only_Animated_Parts)
{   // Animation presentation AND test prints 
    if (Orientation == 0)
    {   // for on screen
        intersection()
        {
            union()
            {
                if (bSun)
                    rotate([0, 0, sun_animation_angle])
                    sun();
                if (bPlanet)
                    rotate([0, 0, carrier_ani_angle])
                    planets(planet_animation_angle);
                if (bRing) ring(chamferTopofTeeth = true);
                if (bRetainer) stageSpacer();
                if (bCarrierFinal)
                    rotate([0, 0, carrier_ani_angle])
                    carrier(carrier_angle_per_planet, spacers = Spacers, sun = false);
            }
            crossSectionVolume();
        }
    } else if (Orientation == 1)
    {   // FDM oriented for test prints
        if (bSun)
            sun(sun_handle_height);
         if (bRing)
            ring();
        if (bPlanet)
            translate([housing_radius, 0])
            for (y = [0:1: Show_All ? Number_of_planets-1 : 0])
                translate([0, y * housing_radius])
                planet();
        if (bRetainer)
            translate([3 * housing_radius, 0])
            stageSpacer(true);
    }
}
else
{   // full design 
    if (Orientation == 0)
    {   // view in place
        intersection()
        {
            union() {
            for (sn = [0:1:Num_stages_-1])
            translate([0,0,sn*stageHeight])
                stage(isInput = (sn==0), isOutput = (sn==(Num_stages_-1)), bCarrier = (sn==Num_stages_ - 1) ? bCarrierFinal : bCarrierM);
            if (bRing && bMotor)
                translate([0, 0, -Motor_Mount_OffsetToSun_mm])
                motor_mount();
            if (bSideMount && bRing)
                side_mount(main=true);
            if (bSideMountSupport)
                side_mount(sideMountSupportStl=true);
            if (bBraceLock)
                brace_lock();
            if (bBrace)
                side_mount(brace=true);
            }
            // support cross section view
            crossSectionVolume();
         }
    } else if (Orientation == 1)
    {   // orient for FDM printing. 
        // lots of translating and rotating to get each part oriented for
        // best FDM with as little support material as possible, and spread
        // out across the bed if multiple parts are printed together.
        planetPrintPitch = Planet_teeth + 2 * Pitch / (2 * PI);
        if (bSun)
            translate([-housing_radius*2,0, Motor_Collar_z_Thickness_mm])
            sun(dshaft = Motor_Dshaft_mm, dshaftnarrow = Motor_DshaftNarrow_mm, 
                collar_thickness = Motor_Collar_z_Thickness_mm, 
                dshaft_round_Z_extent_mm = Motor_Dshaft_round_Z_extent_mm);
        numPlanetsToPrint = Show_All ? Number_of_planets : 1;
        if (bPlanet)
            translate([housing_radius + Pitch * 2, 0])
            {   // prints better upside down
                rotate([180, 0, 0])
                    translate([0, 0, -Gear_thickness_mm])
                    planet();
            }
        if (bRetainer)
            translate([3 * housing_radius, -2 * housing_radius])
            stageSpacer(true);

        {   down = -Gear_thickness_mm - Carrier_planet_Z_offset_mm;
            carrier_top_z = Gear_thickness_mm + Carrier_thickness_mm + Carrier_planet_Z_offset_mm;
            if (bCarrierFinal)
            translate([3 * housing_radius + planetPrintPitch / 2, 0])
            {   // Options on the carrier can switch the preferred FDM
                // printing direction. The integral sun for an intermediate carrier
                // cannot be printed down, nor can the integral spacers into the 
                // planet bearings. The code here splits off the planet spacers into 
                // a separate printable part, as needed.
                if (Spacers == 0)   // print carrier with no spacers
                    translate([0, 0, down])
                        carrier(carrier_angle_per_planet, spacers = 0, dshaft = Dshaft_mm, dshaftnarrow = Dshaft_narrow_mm);
                else if (Spacers == 1) // print only spacers
                    rotate([180, 0, 0])
                    translate([0, 1.5 * housing_radius, down])
                        carrier(spacers = 1);
                else if (Spacers == 2) // integral spacers
                {
                        rotate([180, 0, 0])
                        translate([0, 0, -carrier_top_z-Carrier_output_extra_Z_into_bearing_housing_mm])
                            carrier(carrier_angle_per_planet, spacers = 2, dshaft = Dshaft_mm, dshaftnarrow = Dshaft_narrow_mm);
                }
                else if (Spacers == 3) // print both, separately
                {
                    translate([0, 0, down])
                        carrier(carrier_angle_per_planet, spacers = 0, dshaft = Dshaft_mm, dshaftnarrow = Dshaft_narrow_mm);
                    rotate([180, 0, 0])
                        translate([0, 1.5 * housing_radius, down])
                        carrier(carrier_angle_per_planet, spacers = 1);
                }
            }
            if (bCarrierM && Spacers != 1)
            {
                translate([5 * housing_radius, 0])
                    if (Spacers != 3)
                        translate([0, 0, Spacers == 0 ? down : -Planet_bearing_z]) 
                            carrier(carrier_angle_per_planet, spacers = Spacers, dshaft = Dshaft_mm, dshaftnarrow = Dshaft_narrow_mm, sun = true);
                    else
                    {
                        translate([0, 0, down])
                            carrier(carrier_angle_per_planet, spacers = 0, dshaft = Dshaft_mm, dshaftnarrow = Dshaft_narrow_mm, sun = true);
                        rotate([180, 0, 0])
                            translate([0, 1.5 * housing_radius, down])
                            carrier(carrier_angle_per_planet, spacers = 1);
                    }
            }
        }
        if (bRing || bSideMountSupport)
        rotate([0, 0, -side_mount_rotation_angle])
        {
            translate([0, 0, bMotor ? Motor_Mount_OffsetToSun_mm : 0])
            {
                if (bRing)
                {
                    for (sn = [0:1:Num_stages_-1])
                        translate([0,0,sn*stageHeight])
                        {
                            top = (sn==Num_stages_-1);
                            ring(top ? Number_Output_Bearing_Mounts : 0, top);
                        }
                }
                if (bSideMountSupport && !Show_All)
                    side_mount(sideMountSupportStl=true);
                if (bSideMount && !bSideMountSupport)
                    side_mount(main=true);
            }
            if (bMotor && !bSideMountSupport)
                motor_mount();
        }
        if (bBearing)
            translate([0, -2.2 * housing_radius - BearingMountingBossOuter + BearingMountingBossInner])
                 output_bearing_housing(Number_Output_Bearing_Mounts);

        cleatY = 1.5 * (housing_radius + Side_Mount_Horz_Offset_mm);
        translate([0,cleatY,Side_Mount_Cleat_z_thickness_mm])
        {
            side_mount_cleat_fdm_position()
            {
                 if (bBrace)
                    side_mount(brace=true);
            }
        }
      
        translate([Side_Mount_Horz_Ext_mm,cleatY])
        rotate([180,0,0])
        translate([Side_Mount_Horz_Ext_mm/2+Side_Mount_Cleat_Lock_thickness_mm - Side_Mount_Cleat_Lock_thickness_overlap_mm, 0, -Side_Mount_Cleat_Lock_z_thickness_mm+Side_Mount_Cleat_Lock_z_clearance_mm])
        side_mount_cleat_fdm_position() {
            if (bBraceLock)
                brace_lock();
        }
    }
}

module side_mount_cleat_fdm_position()
{
        rotate([-90,0,0])
        translate([0,-housing_radius - Side_Mount_Horz_Offset_mm,0])
        rotate([0, 0, -side_mount_rotation_angle])
            children();
}

module stage(isInput = true, isOutput = true, bCarrier = true)
{
    if (isInput && bSun) sun(dshaft = Motor_Dshaft_mm, dshaftnarrow = Motor_DshaftNarrow_mm, 
        collar_thickness = isInput ? Motor_Collar_z_Thickness_mm : 0,
        dshaft_round_Z_extent_mm = isInput ? Motor_Dshaft_round_Z_extent_mm : 0);
    if (bPlanet && showTotal > 1) planets();
    else if (bPlanet) planet();
    if (bRing) ring(isOutput ? Number_Output_Bearing_Mounts : 0, isOutput ? true : false);
    if (bMotor && isInput && bRing)
        translate([0, 0, -Motor_Mount_OffsetToSun_mm])
        motor_mount();
    if (bRetainer)
        stageSpacer();
    if (bCarrier) carrier(carrier_angle_per_planet, spacers = Spacers, sun = isOutput ? false : true,
        dshaft = Dshaft_mm, dshaftnarrow = Dshaft_narrow_mm);
    if (bBearing && isOutput)
        translate([0, 0, stageHeight])
        output_bearing_housing(Number_Output_Bearing_Mounts);
}

// Willis equations...
function sun_angle_from_carrier(ca) =
(1 + Ring_teeth_ / Sun_teeth_) * ca;

function carrier_angle_from_sun(sun_angle) =
sun_angle / (1 + Ring_teeth_ / Sun_teeth_);

// ... also Willis equation
function planet_angle_from_sun_angle(sun_angle, ca) =
-((sun_angle - ca) * Sun_teeth_) / Planet_teeth;

sun_animation_angle = sun_angle_from_carrier(carrier_ani_angle);
planet_animation_angle = planet_angle_from_sun_angle(sun_animation_angle, carrier_ani_angle);
sun_diameter = (Sun_teeth_ + 1) * Pitch / PI;

bearing_house_lip_z_thickness_mm = 1;
output_bearing_housing_z_thickness = Output_bearing_thick_mm + bearing_house_lip_z_thickness_mm + Carrier_output_extra_Z_into_bearing_housing_mm;

echo(Ring_teeth_ = Ring_teeth_, Planet_teeth = Planet_teeth,
    str("reduction ratio = ", 1 + Ring_teeth_ / Sun_teeth_),
    str("sun diameter= ~", sun_diameter),
    str(" overall length=", str(housing_height + output_bearing_housing_z_thickness), " mm"));

sun_pertooth_angle = 360 / Sun_teeth_;

// Multiple planets are not spaced at equal angles around the sun.
// They instead must be at integral multiples of the sun gear tooth pitch.
sun_angle_per_planetI = [for (i = [0:1 : Number_of_planets - 1])
    sun_pertooth_angle*
    floor(0.5 + (sun_angle_from_carrier(360 * i / Number_of_planets) / sun_pertooth_angle))];
carrier_angle_per_planet = [for (s = sun_angle_per_planetI) carrier_angle_from_sun(s)];


carrier_planet_bearing_pedestal_diam_mm = HW_hex_nut_circle_diam_mm - 1;
carrier_radius = orbit_radius + HW_nut_across_flats_mm;
motorMountChamfer = 1.5;

BearingMountingBossInner = max(ring_radius, Housing_outer_diameter_mm / 2) - stlSolidOverlap;
BearingMountingBossOuter = BearingMountingBossInner + HW_nut_across_flats_mm*1.5;
BearingMountBossHole = (BearingMountingBossInner + BearingMountingBossOuter) / 2;

half_gear_thickness_beyond_bearing = (Gear_thickness_mm - Planet_bearing_thick_mm) / 2;
// the planet bearing should be centered in the planet to equalize stress
if (HW_socket_head_height_mm > half_gear_thickness_beyond_bearing)
    echo("Gear_thickness is not enough to center the planet bearing");
Planet_bearing_z = max(half_gear_thickness_beyond_bearing + Planet_bearing_thick_mm,
    HW_socket_head_height_mm + Planet_bearing_thick_mm);

housing_color = [.15, .15, .15];
sun_color = [0.7, .7, 0];
planet_color = [0.0, .2, .9];
spacer_color = [1, 0, 0];
support_color = [1,.1,.1];
carrier_color = [0, 0.8, 0];
output_housing_color = [.9, 0, .35];
cleat_color = [0.1, 0.9, 0.7];
brace_color = [0, 0.7, 1];

if (len(carrier_angle_per_planet) > 1)
echo("DO NOT ASSUME the planes are equally spaced:", carrier_angle_per_planet = carrier_angle_per_planet);

module sun(extend_height = 0, dshaft = 0, dshaftnarrow = 0, collar_thickness = 0, dshaft_round_Z_extent_mm = 0)
{   collar_thickness = max(collar_thickness, 0);
    color(sun_color)
    difference()
    {
        tHeight = Gear_thickness_mm + extend_height;
        union()
        {
            linear_extrude(height = tHeight)
                gear(number_of_teeth = Sun_teeth_, circular_pitch = Pitch, rim_width = 0,
                    clearance = Clearance, pressure_angle = Pressure_angle,
                    bore_diameter = 0,
                    hub_thickness = 0,
                    flat = true);
            if (collar_thickness > 0)
            {
                translate([0,0,-collar_thickness])
                difference()
                {
                    cylinder(d = Motor_Collar_Diameter_mm, h=collar_thickness);
                    if (dshaft > 0)
                    {
                        D = DshaftProfileCalc(dshaft, dshaftnarrow);
                        translate([D[1]-D[0] + HW_square_nut_hole_thickness_mm/2,-HW_square_nut_hole_across_flats_mm/2,-stlSolidOverlap])
                            cube([HW_square_nut_hole_thickness_mm, 
                                HW_square_nut_hole_across_flats_mm, 
                                2.5*HW_square_nut_hole_across_flats_mm + stlSolidOverlap]);

                        translate([0,0,HW_square_nut_hole_across_flats_mm])
                        rotate([0,90,0])
                            translate([0,0,-stlSolidOverlap])
                            cylinder(d=HW_screw_clearance_mm, h=Motor_Collar_Diameter_mm/2 + 2 * stlSolidOverlap);
                    }
                }
            }
        }
        if (dshaft > 0)
        {
            profile = DshaftProfile(dshaft, dshaftnarrow);
            translate([0, 0, -stlSolidOverlap - collar_thickness])
            {
                linear_extrude(Gear_thickness_mm + collar_thickness + 2 * stlSolidOverlap)
                    polygon(profile);
                if (dshaftnarrow < dshaft && dshaft_round_Z_extent_mm > 0)
                    linear_extrude(height=dshaft_round_Z_extent_mm)
                        circle(r = dshaft/2);
            }

        }
        translate([0, 0, tHeight])
            bevel_teeth_cutter(Sun_teeth_, Pitch);
    }
}

module planet(startAngle = 0)
{   color(planet_color)
    translate([orbit_radius, 0, 0])
    {
        rotate([0, 0, startAngle])
            rotate([0, 0, Planet_teeth % 2 == 0 ? 180 / Planet_teeth : 0])
            difference()
            {
            intersection()
            {
                linear_extrude(height = Gear_thickness_mm)
                    gear(number_of_teeth = Planet_teeth,
                        circular_pitch = Pitch, rim_width = 0,
                        clearance = Clearance, pressure_angle = Pressure_angle,
                        bore_diameter = 0,
                        hub_thickness = 0,
                        flat = true);
                
                // bevel the gear on the print bed so that it can be
                // printed with a brim that removes easily
                base_radius =  Planet_teeth * Pitch / (2 * PI);
                inner_radius = cos(Pressure_angle) * base_radius - 2*Pitch/PI;
                outer_radius = stlSolidOverlap + base_radius +  Pitch/PI;
                bevel_height_mm = 0.75;
                translate([0,0,Gear_thickness_mm])
                mirror([0,0,1])
                union()
                {
                    linear_extrude(height = bevel_height_mm, scale = outer_radius/inner_radius)
                        circle(r= inner_radius);
                    translate([0,0,bevel_height_mm])
                        linear_extrude(height = Gear_thickness_mm-bevel_height_mm)
                        circle(r= outer_radius);
                }
            }
            if (ShowFullParts)
            {

                translate([0, 0, -stlSolidOverlap])
                    cylinder(d = Planet_bearing_OD_mm, h = Planet_bearing_z + stlSolidOverlap);
                bearing_catch = 2;
                cylinder(d = Planet_bearing_OD_mm - bearing_catch, h = Gear_thickness_mm + 2 * stlSolidOverlap);
            }
            }
    }
}

module planets(animateR = 0)
{
    for (ca = carrier_angle_per_planet)
    {
        rotate([0, 0, ca])
            planet(planet_angle_from_sun_angle(0, ca) + animateR);
    }
}

/* butchered from the rack() module in MCAD */
module inside_ring(
    number_of_teeth = 15,
    circular_pitch = false, diametral_pitch = false,
    pressure_angle = 28,
    clearance = 0.2,
    rim_thickness = 8,
    rim_width = 5,
    outer_radius = 0,
    flat = false)
{
    if (circular_pitch == false && diametral_pitch == false)
        echo("MCAD ERROR: inside_ring module needs either a diametral_pitch or circular_pitch");

    //Convert diametrial pitch to our native circular pitch
    circular_pitch = (circular_pitch != false ? circular_pitch : PI / diametral_pitch);
    pitch = circular_pitch;

    addendum = circular_pitch / PI;
    dedendum = addendum + clearance;
    pitch_slope = tan(pressure_angle);

    ring_radius = number_of_teeth * circular_pitch / (2 * PI);

    linear_extrude_flat_option(flat = flat, height = rim_thickness)
        union()
    {
        p1 = pitch / 4 + pitch_slope * dedendum;
        p2 = pitch / 4 - pitch_slope * addendum;
        teeth_start_on_X_axis = 90; // degrees
        for (i = [0:1 : number_of_teeth - 1],
            ang = teeth_start_on_X_axis + (i * 360 / number_of_teeth))
            translate(ring_radius * [sin(ang), -cos(ang), 0])
            rotate([0, 0, ang])
            polygon(points = [
                [-p1, -dedendum],
                    [p1, -dedendum],
                    [p2, addendum],
                    [-p2, addendum]
            ] );
        difference()
        {    // fill out solid beyond the teeth
            rr = ring_radius + dedendum;
            ring_outer = max(outer_radius, ring_radius + rim_width);
            circle(r = ring_outer);
            circle(r = rr);
        }
    }
}

module ring(bearing_cover_mounts = 0, chamferTopofTeeth = false)
{   thickness = stageHeight + InterStageSpacerZgapmm;
    oddToothAdjustAngle = Planet_teeth % 2 == 0 ? 0 : 180 / Ring_teeth_;
    color(housing_color)
    difference()
    {
        bh = Gear_thickness_mm + Carrier_thickness_mm;
        union()
        {
            rotate([0, 0, oddToothAdjustAngle])
                translate([0, 0, -InterStageSpacerZgapmm])
                inside_ring(number_of_teeth = Ring_teeth_, circular_pitch = Pitch,
                    clearance = Clearance, pressure_angle = Pressure_angle,
                    rim_thickness = thickness,
                    rim_width = 2,
                    outer_radius = housing_radius);
            mount_profile =
                [[BearingMountingBossInner, 0],
                [BearingMountingBossInner, bh],
                [BearingMountingBossOuter, bh],
                [BearingMountingBossOuter, bh - HW_nut_thickness_mm]];
            for (i = [0:1 : bearing_cover_mounts - 1], a = i * 360 / bearing_cover_mounts)
                rotate([0, 0, a])
                translate([0, 0, stageHeight - bh])
                rotate([0, 0, -Bearing_Mount_Angular_extent / 2])
                rotate_extrude(angle = Bearing_Mount_Angular_extent)
                     polygon(mount_profile);
        }

        if (chamferTopofTeeth)
            translate([0, 0, thickness])
            rotate([0, 0, oddToothAdjustAngle])
            bevel_teeth_cutter(Ring_teeth_, Pitch);

        // slot for planet retainer
        translate([0, 0, Gear_thickness_mm + InterStageSpacerZgapmm - PlanetRetainerRadialGapmm])
            cylinder(h = PlanetRetainerZThicknessmm + 2 * PlanetRetainerRadialGapmm, r = ring_radius);
        for (i = [0:1 : bearing_cover_mounts - 1], a = i * 360 / bearing_cover_mounts)
            rotate([0, 0, a])
            translate([BearingMountBossHole, 0, stlSolidOverlap + thickness - bh])
        {
            cylinder(h = bh, d = HW_screw_clearance_mm);
            translate([0, 0, -HW_nut_thickness_mm])
                linear_extrude(height = bh)
                polygon(HW_nut_hole_profile);
        }
    }
}

module motor_mount()
{   color(housing_color)
    difference()
    {
        rotate_extrude()
            polygon([[0, 0], [housing_radius - motorMountChamfer, 0], [housing_radius, motorMountChamfer], 
            [housing_radius, Motor_Mount_OffsetToSun_mm], [0, Motor_Mount_OffsetToSun_mm]] );
        s = (ring_radius - Pitch / 2) / (housing_radius - 2 * Motor_Mount_Thickness_mm);
        translate([0, 0, Motor_Mount_Thickness_mm])
            linear_extrude(height = Motor_Mount_OffsetToSun_mm, scale = s)
            circle(r = housing_radius - 2 * Motor_Mount_Thickness_mm);
        holePositions = [[Motor_Mount_HoleSpacing_mm / 2, Motor_Mount_HoleSpacing_mm / 2], 
            [Motor_Mount_HoleSpacing_mm / 2, -Motor_Mount_HoleSpacing_mm / 2],
            [-Motor_Mount_HoleSpacing_mm / 2, -Motor_Mount_HoleSpacing_mm / 2], 
            [-Motor_Mount_HoleSpacing_mm / 2, Motor_Mount_HoleSpacing_mm / 2]];
        translate([0, 0, -stlSolidOverlap * 2])
        {
            for (t = holePositions)
                translate(t)
                cylinder(d = HW_screw_clearance_mm, h = Motor_Mount_OffsetToSun_mm);
            cylinder(d = Motor_Mount_Sun_HoleDiameter_mm, h = Motor_Mount_OffsetToSun_mm);
        }
        translate([0, 0, Motor_Mount_OffsetToSun_mm - InterStageSpacerZgapmm])
            cylinder(r = housing_radius - 2, h = InterStageSpacerZgapmm * 2);
    }
}

module bevel_teeth_cutter(teeth, pitch)
{   ring_radius = teeth * pitch / (2 * PI);
    for (i = [0:1 : teeth - 1], a = i * 360 / teeth)
    rotate([0, 0, a])
    {
        cutter_profile = 1.1 * [[-pitch / 2, 0],
            [-pitch / 2, 2 * pitch],
            [pitch / 2, 2 * pitch],
            [pitch / 2, 0],
            [0, pitch]];
        translate([ring_radius - pitch * .35 , 0, -pitch * 1.1])
            rotate([90, 0, 90])
            linear_extrude(height = pitch)
            polygon(cutter_profile);
    }
}

module stageSpacer(atOrigin = false)
{
    translate([0, 0, atOrigin ? 0 : Gear_thickness_mm + InterStageSpacerZgapmm])
    color(spacer_color)
    difference()
    {
        retainer_profile = [[0, 0], [ring_radius - PlanetRetainerRadialGapmm, 0],
                                    [ring_radius - PlanetRetainerRadialGapmm, PlanetRetainerZThicknessmm],
                                    [0, PlanetRetainerZThicknessmm]];
        rotate_extrude(angle = 360 - asin(PlanetRetainerSplitGapmm / (ring_radius - PlanetRetainerRadialGapmm)))
            polygon(retainer_profile);
        translate([0, 0, -stlSolidOverlap])
            cylinder(r = ring_radius - PlanetRetainerRThicknessmm, h = PlanetRetainerZThicknessmm + 2 * stlSolidOverlap);
    }
}

module carrier(carrier_angles=[0],
    spacers = 2 /*0:no spacers, 1:spacers only, 2:both, 3:same as 2*/,
    sun = false,  dshaft = 0, dshaftnarrow = 0)
{
    spacers = spacers == 3 ? 2 : spacers;
    color(carrier_color)
    translate([0, 0, Gear_thickness_mm]) // translate to top of planet gear
    difference()
    {
        gearPastBearing = Gear_thickness_mm - Planet_bearing_z;
        union()
        {
            if (spacers == 0 || spacers == 2)
                translate([0, 0, Carrier_planet_Z_offset_mm])
            {   // body of carrier
                extrude_height = Carrier_thickness_mm + (sun ? 0 : Carrier_output_extra_Z_into_bearing_housing_mm);
                difference()
                {
                    union() 
                    {
                        if (Number_of_planets < 2) 
                            cylinder(h = extrude_height, r = carrier_radius);
                        else
                        {
                            rad = carrier_radius - orbit_radius;
                            for (an = carrier_angles)
                                rotate([0, 0, an])
                                translate([orbit_radius, 0])
                                cylinder(h = extrude_height, r = rad);
                            delta = asin(rad / orbit_radius);
                            jiggle = [for (an = carrier_angles) each[an - delta, an + delta]];
                            body_profile = orbit_radius * [for (an = jiggle)[cos(an), sin(an)]];
                            linear_extrude(height = extrude_height)
                                polygon(body_profile);
                        }
                    }
                    n = len(carrier_angles);
                    if (n != 2) //locator hole
                        rotate([0,0,n > 1 ? (carrier_angles[1]/2) : 90])
                            translate([sun_diameter/2 + HW_screw_clearance_mm/2,0,-stlSolidOverlap])
                                cylinder(h=Carrier_thickness_mm + Carrier_output_extra_Z_into_bearing_housing_mm + 2 * stlSolidOverlap, 
                                    d = HW_screw_clearance_mm);
               }
            }

            if (spacers != 0)
                for (an = carrier_angles)
                    rotate([0, 0, an])
                    translate([orbit_radius, 0, -gearPastBearing])
                    cylinder(h = Carrier_planet_Z_offset_mm + gearPastBearing + stlSolidOverlap,
                        d = carrier_planet_bearing_pedestal_diam_mm);

            if (sun && spacers != 1)
                translate([0, 0,  Carrier_planet_Z_offset_mm])
                sun(Carrier_output_bearing_Z_offset_mm+Carrier_thickness_mm);
        }
        for (an = carrier_angles)
            rotate([0, 0, an])
        {
            translate([orbit_radius, 0, -stlSolidOverlap - gearPastBearing])
                cylinder(
                    h = Carrier_thickness_mm + Carrier_planet_Z_offset_mm + gearPastBearing + 2 * stlSolidOverlap,
                    d = HW_screw_clearance_mm);
            translate([orbit_radius, 0, Carrier_planet_Z_offset_mm + HW_nut_support_thickness_mm])
                linear_extrude(height = Carrier_thickness_mm + (sun ? 0 : Carrier_output_extra_Z_into_bearing_housing_mm))
                    polygon(HW_nut_hole_profile);
        }
        if (dshaft > 0)
        {
            profile = DshaftProfile(dshaft, dshaftnarrow);
            hh = Carrier_thickness_mm +  Gear_thickness_mm + Carrier_output_bearing_Z_offset_mm;
            zAngle =  len(carrier_angles) > 1 ? carrier_angles[1] * -.5 : 0;
            translate([0, 0, Carrier_planet_Z_offset_mm + Shaft_block_z_thickness_mm ])
                rotate([0,0, zAngle])
                linear_extrude(hh + 2 * stlSolidOverlap)
                    polygon(profile);
            if (!sun) // make nut slot
            {
                rotate([0,0,zAngle])
                {
                    translate([dshaft + HW_square_nut_hole_thickness_mm/2, 0, 
                        Carrier_thickness_mm+Carrier_planet_Z_offset_mm-HW_square_nut_hole_across_flats_mm+stlSolidOverlap])
                    linear_extrude(height = HW_square_nut_hole_across_flats_mm + Carrier_output_extra_Z_into_bearing_housing_mm)
                        square([HW_square_nut_hole_thickness_mm, HW_square_nut_hole_across_flats_mm], center=true);
                    translate([0,0,Carrier_planet_Z_offset_mm +  Carrier_thickness_mm - 0.5 * HW_square_nut_hole_across_flats_mm])
                    {
                        rotate([0,90,0])
                        {
                            cylinder(d=HW_screw_clearance_mm, h=ring_radius);
                            translate([0,0, orbit_radius-HW_socket_head_height_mm])
                                cylinder(d=HW_socket_Head_clear_diameter_mm, h=ring_radius);
                        }
                        
                    }
                }
            }
        }
    }
}

module output_bearing_housing(bearing_cover_mounts = 0)
{   color(output_housing_color)
    {
        difference()
        {
            union()
            {
                chamfer = 1;
                mount_boss_z_height = HW_socket_head_height_mm + HW_nut_thickness_mm;
                housing_flat_radius = Output_bearing_OD_mm / 2 * 1.1;
                housing_profile = [[0, 0], [housing_radius, 0],
                    [housing_radius, mount_boss_z_height - chamfer],
                    [housing_radius - chamfer, mount_boss_z_height],
                    [housing_flat_radius, output_bearing_housing_z_thickness],
                    [0, output_bearing_housing_z_thickness]];
                rotate_extrude()
                    polygon(housing_profile);
                chamfer_mm = 1.5;
                for (i = [0:1 : bearing_cover_mounts - 1], a = i * 360 / bearing_cover_mounts)
                    rotate([0, 0, a - Bearing_Mount_Angular_extent / 2])
                    rotate_extrude(angle = Bearing_Mount_Angular_extent)
                    polygon([[BearingMountingBossInner - chamfer, 0],
                        [BearingMountingBossInner - chamfer, mount_boss_z_height],
                        [BearingMountingBossOuter - chamfer_mm, mount_boss_z_height],
                        [BearingMountingBossOuter, mount_boss_z_height - chamfer_mm],
                        [BearingMountingBossOuter, 0]] );
            }
            translate([0, 0, -stlSolidOverlap])
            {
                bearing_house_lip_radius_mm = 2;
                cylinder(d = Output_bearing_OD_mm, h = Output_bearing_thick_mm + Carrier_output_extra_Z_into_bearing_housing_mm + stlSolidOverlap);
                cylinder(d = Output_bearing_OD_mm - bearing_house_lip_radius_mm, h = output_bearing_housing_z_thickness + 2 * stlSolidOverlap);
            }
            for (i = [0:1 : bearing_cover_mounts - 1], a = i * 360 / bearing_cover_mounts)
                rotate([0, 0, a])
            {
                translate([BearingMountBossHole, 0, HW_nut_thickness_mm])
                    cylinder(d = HW_socket_Head_clear_diameter_mm, h = output_bearing_housing_z_thickness);
                translate([BearingMountBossHole, 0, -stlSolidOverlap * 2])
                    cylinder(d = HW_screw_clearance_mm, h = output_bearing_housing_z_thickness);
            }
            if (Carrier_output_extra_Z_into_bearing_housing_mm > 0)
                cylinder(r=carrier_radius + Carrier_output_extra_clearance_radius_mm, h = Carrier_output_extra_Z_into_bearing_housing_mm);
        }
    }
}

function side_mount_screw_center_y_offset_mm() = .3 * Side_Mount_Horz_Ext_mm ;
function side_mount_x_offset_mm(halfThickness = Side_Mount_Thickness_mm/2) = halfThickness + Side_Mount_Horz_Ext_mm * .33;

module position_side_mount(halfThickness = Side_Mount_Thickness_mm/2)
{
    translate([side_mount_x_offset_mm(halfThickness),
        housing_radius + Side_Mount_Horz_Offset_mm - halfThickness,
        housing_height / 4])
    rotate([90, 0, 0])
    rotate([0, 0, 90])
        children();
}

module center_of_side_mount_top()
{
    translate([0,housing_radius + Side_Mount_Horz_Offset_mm, housing_height/2])
        children();
}

module side_mount_slot(sideMountSupportStl = false)
{   /* Prusa Slicer support enforcer insists on an overlap
    ** between the solid and the support enforcer.
    ** sideMountSupportStl=true expands the slot when it
    ** is being exported as a volume as compared
    ** to when it is "normal" sized when used to difference()
    ** the side mount to make slots.*/
    position_side_mount()
    {
        round_mm = 0.5;
        linear_extrude(height = Side_Mount_Thickness_mm + 2 * stlSolidOverlap, center = true)
        {
            offset(round_mm)
                offset(sideMountSupportStl ? 0 : -round_mm)
                square([Side_Mount_Screw_Slot_Width_mm, Side_Mount_Horz_Ext_mm/2], center = true);
            translate([0, side_mount_screw_center_y_offset_mm()- Side_Mount_Screw_Slot_Width_mm])
                offset(sideMountSupportStl ? round_mm : 0)
                    circle(d = Side_Mount_Screw_Head_Width_Clearance_mm);
        }
        translate([0, 0, Side_Mount_Thickness_mm/2 - stlSolidOverlap])
            linear_extrude(height = Side_Mount_Screw_Head_Height_Clearance_mm)
            offset(sideMountSupportStl ? round_mm : 0)
            square([Side_Mount_Screw_Head_Width_Clearance_mm, Side_Mount_Horz_Ext_mm / 2], center = true);
    }
}

module side_mount_slots(sideMountSupportStl = false)
{
    side_mount_slot(sideMountSupportStl);
    translate([0, 0, housing_height / 2])
        side_mount_slot(sideMountSupportStl);
}

module mount_cleat_lock()
{
   color(brace_color)
    {
        difference()
        {
            translate([-Side_Mount_Horz_Ext_mm/2,
                housing_radius + Side_Mount_Horz_Offset_mm,
                housing_height / 4 + Side_Mount_Cleat_Lock_narrower_mm/2])
            {
                translate([Side_Mount_Cleat_Lock_thickness_overlap_mm-Side_Mount_Cleat_Lock_thickness_mm, -Side_Mount_Cleat_Lock_z_clearance_mm, -housing_height/4])
                mirror([0,1,0])
                    cube([Side_Mount_Cleat_Lock_thickness_mm , Side_Mount_Cleat_Lock_z_thickness_mm, housing_height - Side_Mount_Cleat_Lock_narrower_mm]);
            }
            translate([-Side_Mount_Horz_Ext_mm/2-Side_Mount_Cleat_Lock_thickness_mm, housing_radius + Side_Mount_Horz_Offset_mm,-Side_Mount_Screw_Slot_Width_mm/2+housing_height/4])  
            {      
                clear_cleat(length = side_mount_screw_center_y_offset_mm()+Side_Mount_Screw_Head_Width_Clearance_mm/2);
                translate([0,0,housing_height/2])
                    clear_cleat( length = side_mount_screw_center_y_offset_mm()+Side_Mount_Screw_Head_Width_Clearance_mm/2);
            }
            cleat_adjust_hole();
        }
    }
}

module half_cleat(screwHead=true, length = Side_Mount_Cleat_width_mm)
{
    clearance = .02 * 25.4;
    mirror([0,1,0])
    {
        translate([0,0,clearance])
        {
            linear_extrude(height=Side_Mount_Screw_Slot_Width_mm-2*clearance)
                square([length, Side_Mount_Thickness_mm + clearance]);
            if (screwHead)
                translate([0,Side_Mount_Thickness_mm+ clearance,-Side_Mount_Screw_Head_Width_Clearance_mm/4])
                linear_extrude(height=Side_Mount_Screw_Head_Width_Clearance_mm-2*clearance)
                    square([length, Side_Mount_Screw_Head_Height_Clearance_mm-2*clearance]);
        }
    }
}

cleat_adjust_wrt_cleat_top = Side_Mount_Screw_Slot_Width_mm/2;

module clear_cleat(length)
{
    clearance = 0.01 * 25.4;
    mirror([0,1,0])
        linear_extrude(height=Side_Mount_Screw_Slot_Width_mm + clearance)
            square([length, Side_Mount_Thickness_mm + clearance]);
}

module cleat_adjust_hole()
{
    center_of_side_mount_top()
    {
        translate([Side_Mount_Cleat_Lock_thickness_overlap_mm-Side_Mount_Horz_Ext_mm/2-Side_Mount_Cleat_bolt_thickness_mm-Side_Mount_Cleat_Lock_thickness_mm,
                -cleat_adjust_wrt_cleat_top])
        rotate([0,90,0])
            translate([0,0,-stlSolidOverlap])
                cylinder(d=Side_Mount_Screw_Slot_Width_mm, h=Side_Mount_Cleat_bolt_thickness_mm +Side_Mount_Cleat_extend_into_cleat_lock_mm + 2*stlSolidOverlap);
    }
}

brace_cleat_half_gap_mm = .002 * 25.4;

module mount_cleat()
{
    color(cleat_color)
    {
        difference()
        {
        union()
        {
            translate([-Side_Mount_Horz_Ext_mm/2 - Side_Mount_Cleat_Lock_thickness_mm + Side_Mount_Cleat_Lock_thickness_overlap_mm - Side_Mount_Cleat_bolt_thickness_mm ,
                housing_radius + Side_Mount_Horz_Offset_mm,
                housing_height / 4 ])
            {
                roundRadius_mm = 12.5;
                translate([0, 0, -housing_height/4])
                {
                    brace_width_mm = Side_Mount_Horz_Ext_mm + Side_Mount_Cleat_Lock_thickness_mm+
                                Side_Mount_Cleat_bolt_thickness_mm-Side_Mount_Cleat_Lock_thickness_overlap_mm + Side_Mount_Cleat_width_mm + Side_Mount_Screw_Head_Width_Clearance_mm;
                    mirror([0,1,0])
                    rotate([90,0,0])
                        linear_extrude(height = Side_Mount_Cleat_z_thickness_mm)
                            offset(roundRadius_mm)
                            offset(-roundRadius_mm)
                            polygon([[0,0],[brace_width_mm,0],
                                        [brace_width_mm,   housing_height], 
                                            [0, housing_height]]);
                    roundEdgeRadius_mm = min(4, -.5 + Side_Mount_Cleat_bolt_thickness_mm/2 );
                    mirror([0,1,0])
                        translate([0,0,Side_Mount_Cleat_Lock_narrower_mm/2])
                        mirror([0,1,0])
                        rotate([90,0,0])
                        linear_extrude(height=Side_Mount_Cleat_Lock_z_thickness_mm)
                        {
                            offset(roundEdgeRadius_mm)
                            offset(-roundEdgeRadius_mm)
                            square([Side_Mount_Cleat_bolt_thickness_mm, 
                                    housing_height-Side_Mount_Cleat_Lock_narrower_mm
                                    ]);
                            translate([Side_Mount_Cleat_bolt_thickness_mm/2,0])
                            square([Side_Mount_Cleat_bolt_thickness_mm/2, 
                                    housing_height-Side_Mount_Cleat_Lock_narrower_mm
                                    ]);                    }
                }
            }
            translate([-Side_Mount_Horz_Ext_mm/2, 
                    housing_radius + Side_Mount_Horz_Offset_mm,
                    -Side_Mount_Screw_Slot_Width_mm/2+housing_height/4])  
            {      
                half_cleat(screwHead=false, length = side_mount_screw_center_y_offset_mm()+Side_Mount_Screw_Head_Width_Clearance_mm/2);
                translate([0,0,housing_height/2])
                    half_cleat(screwHead=false, length = side_mount_screw_center_y_offset_mm()+Side_Mount_Screw_Head_Width_Clearance_mm/2);
            }
        }
        // Negative side of difference()
        xOff = side_mount_screw_center_y_offset_mm() + Side_Mount_Screw_Head_Width_Clearance_mm + Side_Mount_Cleat_width_mm;
        catchScrewPositions = [[-Side_Mount_Horz_Offset_mm,0,0], 
                        [xOff,0,0],
                        [-Side_Mount_Horz_Offset_mm,0,housing_height/2],
                        [xOff,0,housing_height/2]
                        ];
        for (p = catchScrewPositions)
            translate(p)
            position_side_mount()
            {
                translate([0, side_mount_screw_center_y_offset_mm()- Side_Mount_Screw_Slot_Width_mm,-Side_Mount_Thickness_mm/2 - Side_Mount_Cleat_z_thickness_mm - stlSolidOverlap ])  
                {               
                    tolerance=0.4;
                    ScrewThread(outer_diam = 1.01*HW_cleat_screw_body_dia_mm + 1.25*tolerance, 
                        pitch=HW_cleat_screw_thread_pitch_mm,
                        height= Side_Mount_Thickness_mm + Side_Mount_Cleat_z_thickness_mm + Side_Mount_Screw_Head_Height_Clearance_mm + 2 * stlSolidOverlap);           
                }       
            }
        cleat_adjust_hole();
        center_of_side_mount_top()
            {
                cleat_lock_nut_insert_clearance_factor = 2;
                // hex nut for cleat adjust
                translate([Side_Mount_Cleat_Lock_thickness_overlap_mm-Side_Mount_Horz_Ext_mm/2-Side_Mount_Cleat_Lock_thickness_mm-HW_cleat_nut_thickness_mm,
                        -cleat_adjust_wrt_cleat_top])
                    rotate([0,90,0])
                         linear_extrude(height=HW_cleat_nut_thickness_mm*(1 + cleat_lock_nut_insert_clearance_factor)+stlSolidOverlap)
                            polygon(HW_cleat_nut_profile);


                mount_hole_positions = [for (x = [-Side_Mount_Horz_Ext_mm/2,0,Side_Mount_Horz_Ext_mm/2])
                                            for (iy = [-1,1]) [x, 0, iy * 3*housing_height/8]];
                for (p = mount_hole_positions)
                translate(p)
                {
                    rotate([-90,0,0])
                    {
                        translate([0,0,-stlSolidOverlap])
                        {
                            cylinder(h=2 * stlSolidOverlap + Side_Mount_Cleat_z_thickness_mm, d=Side_Mount_Screw_Slot_Width_mm);
                            cylinder(h = stlSolidOverlap + Side_Mount_Screw_Head_Height_Clearance_mm, d=Side_Mount_Screw_Head_Width_Clearance_mm * 1.25);
                        }
                    }
                    rotate([90,0,0])
                        cylinder(h = stlSolidOverlap + Side_Mount_Cleat_Lock_z_thickness_mm, d=Side_Mount_Screw_Head_Width_Clearance_mm * 1.25); 
                }
             }        
        }
    }
}

module brace_lock()
{
    difference()
    {
        side_mount(brace_lock=true);
        side_mount(main=true, side_mount_slots=false);
     }
}

module side_mount(sideMountSupportStl = false, main = false, brace_lock=false, brace=false, bMotor=bMotor, side_mount_slots=true)
{   round = 1;
    half_profile = [[-Side_Mount_Thickness_mm, housing_radius + Side_Mount_Horz_Offset_mm],
        [Side_Mount_Horz_Ext_mm / 2, housing_radius + Side_Mount_Horz_Offset_mm],
        [Side_Mount_Horz_Ext_mm / 2, housing_radius + Side_Mount_Horz_Offset_mm - Side_Mount_Thickness_mm],
        [Side_Mount_Horz_Ext_mm / 2 - Side_Mount_Thickness_mm / 2,
        housing_radius + Side_Mount_Horz_Offset_mm - Side_Mount_Thickness_mm],
        [Side_Mount_Thickness_mm / 2, 0],
        [-Side_Mount_Thickness_mm / 2, 0],
        [Side_Mount_Horz_Ext_mm / 2 - 3 * Side_Mount_Thickness_mm / 2,
        housing_radius + Side_Mount_Horz_Offset_mm - Side_Mount_Thickness_mm],
        [-Side_Mount_Thickness_mm, housing_radius + Side_Mount_Horz_Offset_mm - Side_Mount_Thickness_mm]];

    center_pillar = [[-Side_Mount_Thickness_mm / 2, 0], [Side_Mount_Thickness_mm / 2, 0],
                            [Side_Mount_Thickness_mm / 2, housing_radius + Side_Mount_Horz_Offset_mm],
                            [-Side_Mount_Thickness_mm / 2, housing_radius + Side_Mount_Horz_Offset_mm]];

    a = side_mount_rotation_angle;
    translate([0, 0, bMotor ? -Motor_Mount_OffsetToSun_mm : 0])
        rotate([0, 0, a])
        {
            if (main)
            {
                difference()
                {
                    color(housing_color)
                        union()
                    {
                        hh = housing_height;
                        linear_extrude(hh)
                            offset(round)
                            offset(-round)
                            polygon(half_profile);
                        mirror([1, 0, 0])
                            linear_extrude(hh)
                            offset(round)
                            offset(-round)
                            polygon(half_profile);
                        linear_extrude(hh)
                            polygon(center_pillar );
                    }
                    translate([0, 0, motorMountChamfer])
                        cylinder(h = housing_height + stlSolidOverlap * 2, r = housing_radius);
                    translate([0, 0, -stlSolidOverlap])
                        cylinder(h = motorMountChamfer + 2 * stlSolidOverlap, r = housing_radius - 2 * Motor_Mount_Thickness_mm);

                    if (side_mount_slots)
                    {
                        side_mount_slots();
                        mirror([1, 0, 0]) side_mount_slots();
                    }
                }
            }
            if (sideMountSupportStl)
            {
                color(support_color)
                {
                    side_mount_slots(sideMountSupportStl);
                    mirror([1, 0, 0]) side_mount_slots(sideMountSupportStl);
                }
            }
            if (brace_lock)
                mount_cleat_lock();
            if (brace)
                mount_cleat();
        }
}
