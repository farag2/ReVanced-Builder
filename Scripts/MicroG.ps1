# https://github.com/TeamVanced/VancedMicroG
$Parameters = @{
    Uri             = "https://api.github.com/repos/TeamVanced/VancedMicroG/releases/latest"
    UseBasicParsing = $true
    Verbose         = $true
}
$MicroGTag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
     Uri             = "https://github.com/TeamVanced/VancedMicroG/releases/download/$MicroGTag/microg.apk"
     Outfile         = "$PSScriptRoot\microg.apk"
     UseBasicParsing = $true
     Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "MicroGTag=$MicroGTag" >> $env:GITHUB_ENV
