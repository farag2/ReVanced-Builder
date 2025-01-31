# https://app.swaggerhub.com/apis-docs/azul/zulu-download-community/1.0
$Parameters = @{
	Uri             = "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/?jdk_version=21&bundle_type=jdk&javafx=false&ext=msi&os=windows&arch=x86&hw_bitness=64"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).url

$ZuluTag = (Invoke-RestMethod @Parameters).jdk_version -join "."
echo "ZuluTag=$ZuluTag" >> $env:GITHUB_ENV

$Parameters = @{
	Uri             = $URL
	Outfile         = "ReVanced_Builder\zulu-jdk-win_x64.msi"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

Write-Verbose -Message "Installing Zulu JDK" -Verbose

$Arguments = @(
	"/i `"ReVanced_Builder\zulu-jdk-win_x64.msi`"",
	"/quiet",
	"/qb",
	"/norestart"
)
Start-Process -FilePath "msiexec" -ArgumentList $Arguments -Wait

Remove-Item -Path "ReVanced_Builder\zulu-jdk-win_x64.msi" -Force
