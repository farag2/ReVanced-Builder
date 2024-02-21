# https://github.com/revanced/revanced-patches
$Parameters = @{
    Uri             = "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
    UseBasicParsing = $true
    Verbose         = $true
}
$Patchesvtag = (Invoke-RestMethod @Parameters).tag_name
$Patchestag = $Patchesvtag.replace("v", "")

# "https://github.com/revanced/revanced-patches/releases/download/$Patchesvtag/revanced-patches-$Patchestag.jar"
$Parameters = @{
    Uri             = "https://github.com/ReVanced/revanced-patches/releases/download/v4.3.0-dev.3/revanced-patches-4.3.0-dev.3.jar"
    Outfile         = "ReVanced\revanced-patches.jar"
    UseBasicParsing = $true
    Verbose         = $true
}
Invoke-RestMethod @Parameters

echo "Patchesvtag=$Patchesvtag" >> $env:GITHUB_ENV
