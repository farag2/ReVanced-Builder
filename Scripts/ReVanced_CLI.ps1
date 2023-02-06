# https://github.com/revanced/revanced-cli
$Token = "${{ secrets.GITHUB_TOKEN }}"
$Headers = @{
	Accept        = "application/json"
	Authorization = "Bearer $Token"
}
$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
$CLIvtag = (Invoke-RestMethod @Parameters).tag_name
$CLItag = $CLIvtag.replace("v", "")
$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-cli/releases/download/$CLIvtag/revanced-cli-$CLItag-all.jar"
	Outfile         = "Temp\revanced-cli.jar"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "CLIvtag=$CLIvtag" >> $env:GITHUB_ENV
