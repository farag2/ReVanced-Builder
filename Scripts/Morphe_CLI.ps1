# https://github.com/MorpheApp/morphe-cli

$Parameters = @{
	Uri             = "https://api.github.com/repos/MorpheApp/morphe-cli/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$CLIMorphevTag = (Invoke-RestMethod @Parameters).tag_name
$CLIMorpheTag = $CLIMorphevTag.replace("v", "")

$Parameters = @{
	Uri             = "https://github.com/MorpheApp/morphe-cli/releases/download/$CLIMorphevTag/morphe-cli-$CLIMorpheTag-all.jar"
	Outfile         = "Morphe_Builder\morphe-cli.jar"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "CLIMorpheTag=$CLIMorpheTag" >> $env:GITHUB_ENV
