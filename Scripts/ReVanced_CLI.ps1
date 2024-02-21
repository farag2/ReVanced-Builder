# https://github.com/revanced/revanced-cli
$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$CLIvtag = (Invoke-RestMethod @Parameters).tag_name
$CLItag = $CLIvtag.replace("v", "")

# https://github.com/ReVanced/revanced-cli/releases/download/v4.4.1-dev.1/revanced-cli-4.4.1-dev.1-all.jar
"https://github.com/revanced/revanced-cli/releases/download/$CLIvtag/revanced-cli-$CLItag-all.jar"
$Parameters = @{
	Uri             = "https://github.com/ReVanced/revanced-cli/releases/download/v4.4.1-dev.1/revanced-cli-4.4.1-dev.1-all.jar"
	Outfile         = "ReVanced\revanced-cli.jar"
	Headers         = $Headers
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "CLIvtag=$CLIvtag" >> $env:GITHUB_ENV
