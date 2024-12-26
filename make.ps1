<#
.SYNOPSIS
This script is used to automate the OpenTripPlanner example.

.PARAMETER action
The action to run. 
- Setup: Downloads the OpenTripPlanner 2.6.0 jar file and the Galicia OSM file. Run only once, the first time you use the script.
- Build: Creates the GTFS zip file and builds the OpenTripPlanner graph.
- Serve: Loads the OpenTripPlanner graph and serves it.
- Develop: Creates the GTFS zip file, and builds+serve the OpenTripPlanner graph without saving it.

.NOTES
Author: Ariel Costas Guerrero
#>

param (
	[Parameter(Mandatory)]
	[ValidateSet("setup", "build", "serve", "develop")]
	[string]$Action
)

if ($action -eq $null -or $action -contains "-h" -or $action -contains "--help") {
	Write-Host "Usage: make.ps1 <action>"
	Write-Host "Actions: " $actions
	exit
}

# Switch on the action
if ($action -eq "setup") {
	Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/org/opentripplanner/otp/2.6.0/otp-2.6.0-shaded.jar" -OutFile "opentripplanner.jar"
	Write-Host "OpenTripPlanner 2.6.0 downloaded."

	Invoke-WebRequest -Uri "https://download.geofabrik.de/europe/spain/galicia-latest.osm.pbf" -OutFile "./otp/galicia.osm.pbf"
	Write-Host "Galicia OSM file downloaded."
}
elseif ($action -eq "build") {
	Remove-Item .\otp\gtfs.zip -ErrorAction SilentlyContinue
	Compress-Archive -Path .\gtfs\*.txt .\otp\gtfs.zip
	Write-Host "GTFS zip file created."

	java -Xmx4G -Xms2G -jar opentripplanner.jar --build --save otp/
}
elseif ($action -eq "serve") {
	java -Xmx4G -Xms2G -jar opentripplanner.jar --load --serve otp/
}
elseif ($action -eq "develop") {
	Remove-Item .\otp\gtfs.zip -ErrorAction SilentlyContinue
	Compress-Archive -Path .\gtfs\*.txt .\otp\gtfs.zip
	java -Xmx4G -Xms2G -jar opentripplanner.jar --build --serve otp/
}
else {
	Write-Host "Invalid action. Use -h or --help to see the available actions."
	exit
}
