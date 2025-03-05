

module no_more_customizer() {}

mmPerInch = 25.4;

mount_hole_diameter_mm = 10;
mount_brace_diameter_mm = 2 * mmPerInch;
mount_brace_height = mmPerInch * 3/32;
skid_pad_horz_mm = 25.4;
skid_pad_vert_mm = 25.4;
skid_pad_thickness_mm = mmPerInch * 1/16; // half height of the pad itself
skid_pad_radial_from_center = 3 * mmPerInch;
skid_pad_width_around_pad = mmPerInch * 1/ 8;
spoke_width = 0.5 * mmPerInch;

difference()
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
                translate([skid_pad_radial_from_center, 0])
                    offset(skid_pad_width_around_pad)
                        square([skid_pad_horz_mm, skid_pad_vert_mm], center = true);
            }
            translate([0,0,-.1])
            linear_extrude(height = skid_pad_thickness_mm+.2)
                translate([skid_pad_radial_from_center, 0])
                        square([skid_pad_horz_mm, skid_pad_vert_mm], center = true);
       }
    }
    translate([0,0,-.1])
    cylinder(d = mount_hole_diameter_mm, h = mount_brace_height + .2);
}




