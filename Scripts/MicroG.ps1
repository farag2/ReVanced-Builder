# https://github.com/inotia00/VancedMicroG
# https://github.com/TeamVanced/VancedMicroG/releases/download/v0.2.24.220220-220220001/microg.apk
# "https://github.com/inotia00/VancedMicroG/releases/download/$MicroGTag/microg.apk"
$Parameters = @{
	Uri             = "https://api.github.com/repos/inotia00/VancedMicroG/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$MicroGTag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
	Uri             = "https://github.com/TeamVanced/VancedMicroG/releases/download/v0.2.24.220220-220220001/microg.apk"
	Outfile         = "ReVancedTemp\microg.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "MicroGTag=$MicroGTag" >> $env:GITHUB_ENV
