# https://github.com/revanced/revanced-integrations
$Parameters = @{
    Uri             = "https://api.github.com/repos/revanced/revanced-integrations/releases/latest"
    UseBasicParsing = $true
    Verbose         = $true
}
$IntegrationsTag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
    Uri             = "https://github.com/revanced/revanced-integrations/releases/download/$IntegrationsTag/revanced-integrations-$($IntegrationsTag.replace(`"v`", `"`")).apk"
    Outfile         = "Temp\revanced-integrations-$($IntegrationsTag.replace(`"v`", `"`")).apk"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "IntegrationsTag=$IntegrationsTag" >> $env:GITHUB_ENV
