# https://github.com/ReVanced/GmsCore
$URLParameters = @{
	Uri             = "https://api.github.com/repos/ReVanced/GmsCore/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
# Default apk
$URL = (Invoke-RestMethod @URLParameters).assets.browser_download_url | Where-Object -FilterScript {$_ -notmatch "hw"}
$MicroGTag = (Invoke-RestMethod @URLParameters).tag_name

$Parameters = @{
	Uri             = $URL
	Outfile         = ReVanced_Builder\microg.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# Huawei apk
$URL = (Invoke-RestMethod @URLParameters).assets.browser_download_url | Where-Object -FilterScript {$_ -match "hw"}
$Parameters = @{
	Uri             = $URL
	Outfile         = "ReVanced_Builder\microg-huawei.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "MicroGTag=$MicroGTag" >> $env:GITHUB_ENV
