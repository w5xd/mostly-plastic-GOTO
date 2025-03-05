

module no_more_customizer() {}
$fa = $preview ? 15 : 1;
$fs = $preview ? 3 : .1;

mmPerInch = 25.4;

mount_hole_diameter_mm = 10 - .1;
mount_brace_diameter_mm = 1 * mmPerInch;
mount_brace_height = mmPerInch * 3/32;
skid_pad_thickness_mm = mmPerInch * .3; 
skid_pad_radial_from_center = 3 * mmPerInch;
spoke_width = 0.5 * mmPerInch;

dolly_ID = 4.74;
dolly_ID_squeeze = dolly_ID - .01;

hole_extrude = max(mount_brace_height, skid_pad_thickness_mm);

difference()
{
    intersection()
    {
    union()
    {
        cylinder(d=mount_brace_diameter_mm, h = mount_brace_height);
        for (r = [0, 120, 240]) rotate([0,0,r])
        difference()
        {
            linear_extrude(height = skid_pad_thickness_mm)
            {
                translate([skid_pad_radial_from_center/2, 0])
                    square([skid_pad_radial_from_center, spoke_width], center = true);
             }
        }
    }
    linear_extrude(height=hole_extrude, scale= dolly_ID_squeeze/dolly_ID)
        circle(d=dolly_ID * mmPerInch);
    }
    translate([0,0,-.1])
        cylinder(d = mount_hole_diameter_mm, h = hole_extrude + .2);
}




