/**************************************************************************
   Pulley_Helpers (c) 2025 by Wayne E Wright,
   https://www.thingiverse.com/wwrr55
   is licensed under Attribution-ShareAlike 4.0 International. To view a
   copy of this license, visit
   http://creativecommons.org/licenses/by-sa/4.0/
*****************************************************************************/

// G2 belt parameters taken from http://www.thingiverse.com/thing:16627

function DshaftProfileCalc(diameter, short_diameter) = 
let (  rad = diameter / 2,
        sd = max(min(short_diameter, diameter), rad)
) [rad, sd];

function DshaftProfile(diameter, short_diameter) =
let(
    D = DshaftProfileCalc(diameter, short_diameter),
    rad = D[0],
    sd = D[1],
    theta = acos((sd - rad) / rad),
    npoints = floor(0.5 + (360 - 2 * theta) / $fa),
    delta =  (360 - theta * 2) / npoints
)[for (i = [0:1:npoints], a = theta + i * delta)  rad * [cos(a), sin(a)]];

G2_profile = [[0.747183,-0.5],[0.747183,0],[0.647876,0.037218],[0.598311,0.130528],[0.578556,0.238423],
    [0.547158,0.343077],[0.504649,0.443762],[0.451556,0.53975],[0.358229,0.636924],[0.2484,0.707276],[0.127259,0.750044],[0,0.76447],[-0.127259,0.750044],
    [-0.2484,0.707276],[-0.358229,0.636924],[-0.451556,0.53975],[-0.504797,0.443762],[-0.547291,0.343077],[-0.578605,0.238423],[-0.598311,0.130528],
    [-0.648009,0.037218],[-0.747183,0],[-0.747183,-0.5]];

G2_pitch = 2;
G2_line_offset = 0.254;
G2_tooth_depth = 0.764;
G2_tooth_width = 1.494;

additional_tooth_width_mm = 0.1; // clearance

function tooth_scale(tw, toAdd=additional_tooth_width_mm) =	(tw + toAdd ) / tw;

function tooth_distance_from_centre(od, tooth_width, additional_tooth_width = additional_tooth_width_mm) = 
    sqrt( pow(od/2,2) - pow((tooth_width+additional_tooth_width)/2,2));

function pully_OD(teeth, tooth_pitch = G2_pitch, pitch_line_offset = G2_line_offset) 
	= 2*((teeth*tooth_pitch)/(PI*2)-pitch_line_offset) ;

// 2D profile of belt teeth around a pulley
module cut_teeth_from_pulley(teeth, 
    omit=0,
    tooth_radius_pos = 0, 
    tooth_depth=G2_tooth_depth, 
    tooth_width=G2_tooth_width, 
    profile = G2_profile)
{
    tooth_radius_pos = (tooth_radius_pos != 0) ? tooth_radius_pos :
        tooth_distance_from_centre(pully_OD(teeth), tooth_width);
    for(i=[0:1:teeth-1-omit]) 
    {
        a = i * 360 /teeth;
        rotate([0,0,a])
            translate([0,-tooth_radius_pos]) 
            scale ([ tooth_scale(tooth_width) , tooth_scale(tooth_depth) ]) 
                polygon(profile);
    }            
}

// 2D profile of belt teeth along a straight section
module cut_teeth_along_rack(teeth, pitch = G2_pitch,
    tooth_depth=G2_tooth_depth, tooth_width=G2_tooth_width, profile = G2_profile)
{
    for(i=[0:1:teeth-1]) 
    {
            translate([(i+0.5) * pitch, 0]) 
            scale ([ tooth_scale(tooth_width) , tooth_scale(tooth_depth) ]) 
                polygon(profile);
    }         
}