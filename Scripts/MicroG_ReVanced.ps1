# https://github.com/ReVanced/GmsCore

$Parameters = @{
	Uri             = "https://api.github.com/repos/ReVanced/GmsCore/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
# Default apk
$Releases = Invoke-RestMethod @Parameters
$Assets = $Releases.assets.browser_download_url
$URL = $Assets | Where-Object -FilterScript {$_ -notmatch "hw"}
$MicroG_ReVanced = $Releases.tag_name

$Parameters = @{
	Uri             = $URL
	Outfile         = "ReVanced_Builder\microg_revanced.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Huawei apk
$URL = $Assets | Where-Object -FilterScript {$_ -match "hw"}
$Parameters = @{
	Uri             = $URL
	Outfile         = "ReVanced_Builder\microg_revanced_huawei.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "MicroG_ReVanced=$MicroG_ReVanced" >> $env:GITHUB_ENV
