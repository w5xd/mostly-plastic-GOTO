@rem ARRANGE for Openscad's install directory to be on your Windows PATH
@rem And for Freecad's install/bin directory to be on your Windows Path
@set ASTL=STL\Azimuth
@if not exist %ASTL% (
	mkdir %ASTL%
)
@set ESTL=STL\Elevation
@if not exist %ESTL% (
	mkdir %ESTL%
)
@set ASTL=%ASTL:\=/%
@set ESTL=%ESTL:\=/%
openscad.com -o %ESTL%/OnStepElevationPulley.stl --export-format binstl --backend Manifold  -D "partToPrint=0" OnStepElevationPulley.scad
openscad.com -o %ESTL%/OnStepElevationPulley-support.stl --export-format binstl --backend Manifold  -D "partToPrint=1" OnStepElevationPulley.scad
openscad.com -o %ASTL%/OnStepAzimuthPulley.stl --export-format binstl --backend Manifold  -D "part=0" OnStepAzimuthPulley.scad
openscad.com -o %ASTL%/OnStepAzimuthPulley-support.stl --export-format binstl --backend Manifold  -D "part=1" OnStepAzimuthPulley.scad
openscad.com -o %ESTL%/OnStepGearboxElevationPulley.stl --export-format binstl --backend Manifold  OnStepGearboxElevationPulley.scad

freecadcmd CradleOpenAndExport.FCMacro
