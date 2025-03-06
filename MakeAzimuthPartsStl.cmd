@rem ARRANGE for Openscad's install directory to be on your Windows PATH
@set STL=STL\Azimuth
@if not exist %STL% (
	mkdir %STL%
)
@set STL=%STL:\=/%
openscad.com -o %STL%/Azimuth-M10-bolt-lock.stl --export-format binstl --backend Manifold -D "part=0"  Azimuth-Bearings.scad
@rem The teflon skid plate is not used in the lazy susan version.
@rem openscad.com -o %STL%/Azimuth-Teflon-skid-plate.stl --export-format binstl --backend Manifold -D "part=1"  Azimuth-Bearings.scad
openscad.com -o %STL%/Azimuth-Bearing-Holder.stl --export-format binstl --backend Manifold -D "part=2"  Azimuth-Bearings.scad
openscad.com -o %STL%/lazy_susan_jig.stl --export-format binstl --backend Manifold lazy_susan_jig.scad
