# https://github.com/ReVanced/GmsCore
$Parameters = @{
	Uri             = "https://api.github.com/repos/ReVanced/GmsCore/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).assets.browser_download_url
$MicroGTag = (Invoke-RestMethod @Parameters).tag_name

$Parameters = @{
	Uri             = $URL
	Outfile         = "ReVancedTemp\microg.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "MicroGTag=$MicroGTag" >> $env:GITHUB_ENV
