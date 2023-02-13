[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13

# https://raw.githubusercontent.com/ScoopInstaller/Java/master/bucket/zulu17-jdk.json
$Parameters = @{
    Uri             = "https://raw.githubusercontent.com/ScoopInstaller/Java/master/bucket/zulu17-jdk.json"
    UseBasicParsing = $true
    Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).architecture."64bit".url
$Parameters = @{
    Uri             = $URL
    Outfile         = "Temp\jdk_windows-x64_bin.zip"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

# https://github.com/ScoopInstaller/Java/blob/master/bucket/zulu17-jdk.json
$Parameters = @{
    Uri             = "https://raw.githubusercontent.com/ScoopInstaller/Java/master/bucket/zulu17-jdk.json"
    UseBasicParsing = $true
    Verbose         = $true
}
$ZuluTag = (Invoke-RestMethod @Parameters).version
echo "ZuluTag=$ZuluTag" >> $env:GITHUB_ENV

Write-Verbose -Message "Expanding Zulu JDK" -Verbose

$Parameters = @{
    Path            = "Temp\jdk_windows-x64_bin.zip"
    DestinationPath = "Temp\jdk_windows-x64_bin"
    Force           = $true
    Verbose         = $true
}
Expand-Archive @Parameters

Remove-Item -Path "Temp\jdk_windows-x64_bin.zip" -Force
