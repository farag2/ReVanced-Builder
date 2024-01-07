# https://github.com/TeamVanced/VancedMicroG
$Parameters = @{
    Uri             = "https://api.github.com/repos/inotia00/VancedMicroG/releases/latest"
    UseBasicParsing = $true
    Verbose         = $true
}
$MicroGTag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
     Uri             = "https://github.com/inotia00/VancedMicroG/releases/download/$MicroGTag/microg.apk"
     Outfile         = "Temp\microg.apk"
     UseBasicParsing = $true
     Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "MicroGTag=$MicroGTag" >> $env:GITHUB_ENV
