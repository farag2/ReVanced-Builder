# https://github.com/ScoopInstaller/Java/blob/master/bucket/zulu-jdk.json
$Parameters = @{
    Uri             = "https://raw.githubusercontent.com/ScoopInstaller/Java/master/bucket/zulu-jdk.json"
    UseBasicParsing = $true
    Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).architecture."64bit".url
$ZuluTag = (Invoke-RestMethod @Parameters).version
$Parameters = @{
    Uri             = $URL
    Outfile         = "$PSScriptRoot\jdk_windows-x64_bin.zip"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "ZuluTag=$ZuluTag" >> $env:GITHUB_ENV
