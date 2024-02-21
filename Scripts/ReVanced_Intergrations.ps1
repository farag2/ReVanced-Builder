# https://github.com/revanced/revanced-integrations
$Parameters = @{
    Uri             = "https://api.github.com/repos/revanced/revanced-integrations/releases/latest"
    UseBasicParsing = $true
    Verbose         = $true
}
$IntegrationsTag = (Invoke-RestMethod @Parameters).tag_name

# https://github.com/revanced/revanced-integrations/releases/download/$IntegrationsTag/revanced-integrations-$($IntegrationsTag.replace(`"v`", `"`")).apk
$Parameters = @{
    Uri             = "https://github.com/ReVanced/revanced-integrations/releases/download/v1.4.0-dev.4/revanced-integrations-1.4.0-dev.4.apk"
    Outfile         = "ReVanced\revanced-integrations.apk"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "IntegrationsTag=$IntegrationsTag" >> $env:GITHUB_ENV
