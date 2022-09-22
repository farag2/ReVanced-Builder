
# https://github.com/revanced/revanced-patches
$Parameters = @{
    Uri             = "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
    UseBasicParsing = $true
    Verbose         = $true
}
$Patchesvtag = (Invoke-RestMethod @Parameters).tag_name
$Patchestag = $Patchesvtag.replace("v", "")
$Parameters = @{
    Uri             = "https://github.com/revanced/revanced-patches/releases/download/$Patchesvtag/revanced-patches-$Patchestag.jar"
    Outfile         = "$PSScriptRoot\revanced-patches.jar"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "Patchesvtag=$Patchesvtag" >> $env:GITHUB_ENV
