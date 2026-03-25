# https://github.com/revanced/revanced-patches

$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$ReVancedPatchesvTag = (Invoke-RestMethod @Parameters).tag_name
$ReVancedPatchesTag = $ReVancedPatchesvTag.replace("v", "")

$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-patches/releases/download/$ReVancedPatchesvtag/patches-$ReVancedPatchestag.rvp"
	Outfile         = "ReVanced_Builder\revanced-patches.rvp"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "ReVancedPatchesTag=$ReVancedPatchesTag" >> $env:GITHUB_ENV
