# https://github.com/MorpheApp/MicroG-RE

$Parameters = @{
	Uri             = "https://api.github.com/repos/MorpheApp/MicroG-RE/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$Releases = Invoke-RestMethod @Parameters
$URL = $Releases.assets.browser_download_url
$MicroG_Morphe = $Releases.tag_name

$Parameters = @{
	Uri             = $URL
	Outfile         = "Morphe_Builder\microg_morphe.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "MicroG_Morphe=$MicroG_Morphe" >> $env:GITHUB_ENV
