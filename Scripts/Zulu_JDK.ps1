[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13

winget install --id=Azul.Zulu.19.JDK --exact --accept-source-agreements
<#
# https://app.swaggerhub.com/apis-docs/azul/zulu-download-community/1.0
$Parameters = @{
	Uri             = "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/?jdk_version=&bundle_type=jdk&javafx=false&ext=zip&os=windows&arch=x86&hw_bitness=64"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).url

$ZuluTag = [string](Invoke-RestMethod @Parameters).jdk_version -replace (" ", ".")
echo "ZuluTag=$ZuluTag" >> $env:GITHUB_ENV

$Parameters = @{
    Uri             = $URL
    Outfile         = "Temp\jdk_windows-x64_bin.zip"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

Write-Verbose -Message "Expanding Zulu JDK" -Verbose

$Parameters = @{
    Path            = "Temp\jdk_windows-x64_bin.zip"
    DestinationPath = "Temp\jdk_windows-x64_bin"
    Force           = $true
    Verbose         = $true
}
Expand-Archive @Parameters

Remove-Item -Path "Temp\jdk_windows-x64_bin.zip" -Force
#>
