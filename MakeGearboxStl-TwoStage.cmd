@rem ARRANGE for Openscad's install directory to be on your Windows PATH
@set Outdir=STL\Gearbox
@if not exist %Outdir% (
	mkdir %Outdir%
)
@set Outdir=%Outdir:\=/%

openscad.com -o %Outdir%/test-sun.stl --export-format binstl --backend Manifold -D "Only_Animated_Parts=true" -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Sun=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/test-planet.stl --export-format binstl --backend Manifold -D "Only_Animated_Parts=true" -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Planet=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/test-housing.stl --export-format binstl --backend Manifold -D "Only_Animated_Parts=true" -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Housing=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/test-retainer.stl --export-format binstl --backend Manifold -D "Only_Animated_Parts=true" -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Planet_Retainer=1" OnStepGearReducer.scad

openscad.com -o %Outdir%/2sun.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Sun=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2planet.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Planet=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2housing.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Housing=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2housing-supports.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Side_Mount_Support=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2retainer.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Planet_Retainer=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2carrier.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Final_Carrier=1" -D "Spacers=2" OnStepGearReducer.scad
openscad.com -o %Outdir%/2carrier2.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Intermediate_Carrier=1" -D "Spacers=0" OnStepGearReducer.scad
openscad.com -o %Outdir%/2carrier-spacers.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Final_Carrier=1" -D "Spacers=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2bearing.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Output_Bearing_Housing=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2OnStepGearReducer-cleat.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Side_Mount_cleat=1" OnStepGearReducer.scad
openscad.com -o %Outdir%/2OnStepGearReducer-cleat-lock.stl --export-format binstl --backend Manifold -D "Orientation=1" -D "Show_All=0" -D "Number_of_Stages=2" -D "Show_Side_Mount_cleat_lock=1" OnStepGearReducer.scad
