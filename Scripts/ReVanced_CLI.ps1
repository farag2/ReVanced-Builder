# https://github.com/revanced/revanced-cli
$Parameters = @{
    Uri             = "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
    UseBasicParsing = $true
    Verbose         = $true
}
$CLIvtag = (Invoke-RestMethod @Parameters).tag_name
$CLItag = $CLIvtag.replace("v", "")
$Parameters = @{
    Uri   = "https://github.com/revanced/revanced-cli/releases/download/$CLIvtag/revanced-cli-$CLItag-all.jar"
    Outfile         = "$PSScriptRoot\revanced-cli.jar"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "CLIvtag=$CLIvtag" >> $env:GITHUB_ENV
