# Get latest supported YouTube client version via ReVanced JSON
# It will let us to download always latest YouTube apk supported by ReVanced team
# https://github.com/revanced/revanced-patches/blob/main/patches.json
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/revanced/revanced-patches/main/patches.json"
	UseBasicParsing = $true
}
$JSON = Invoke-RestMethod @Parameters
$versions = ($JSON | Where-Object -FilterScript {$_.compatiblePackages.name -eq "com.google.android.youtube"}).compatiblePackages.versions
$LatestSupported = $versions | Sort-Object -Descending -Unique | Select-Object -First 1

# We need a NON-bundle version
# https://apkpure.net/ru/youtube/com.google.android.youtube/versions
$Parameters = @{
	Uri             = "https://apkpure.net/ru/youtube/com.google.android.youtube/download/$($LatestSupported)"
	UseBasicParsing = $true
	Verbose         = $true
}
$DownloadURL = (Invoke-Webrequest @Parameters).Links.href | Where-Object -FilterScript {$_ -match "APK/com.google.android.youtube"} | Select-Object -Index 1

$Parameters = @{
	Uri             = $DownloadURL
	OutFile         = "Temp\youtube.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

echo "LatestSupportedYT=$($LatestSupported)" >> $env:GITHUB_ENV
