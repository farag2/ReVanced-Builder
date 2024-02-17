[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13

# https://app.swaggerhub.com/apis-docs/azul/zulu-download-community/1.0
$Parameters = @{
	Uri             = "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/?jdk_version=&bundle_type=jdk&javafx=false&ext=zip&os=windows&arch=x86&hw_bitness=64"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).url

$ZuluTag = [string](Invoke-RestMethod @Parameters).jdk_version -replace (" ", ".")
echo "ZuluTag=$ZuluTag" >> $env:GITHUB_ENV

# Save zulu-jdk-win_x64.msi as zulu-jdk-win_x64.zip with purpose
$Parameters = @{
	Uri             = $URL
	Outfile         = "Temp\zulu-jdk-win_x64.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

Write-Verbose -Message "Expanding Zulu JDK" -Verbose

# Expand jdk_windows-x64_bin archive
$Parameters = @{
	Path            = "Temp\zulu-jdk-win_x64.zip"
	DestinationPath = "Temp\zulu-jdk-win_x64"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters
