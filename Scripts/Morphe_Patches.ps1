# https://github.com/MorpheApp/morphe-patches

$Parameters = @{
	Uri             = "https://api.github.com/repos/MorpheApp/morphe-patches/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$MorphePatchesvTag = (Invoke-RestMethod @Parameters).tag_name
$MorphePatchesTag = $MorphePatchesvTag.replace("v", "")

$Parameters = @{
	Uri             = "https://github.com/MorpheApp/morphe-patches/releases/download/$MorphePatchesvtag/patches-$MorphePatchestag.mpp"
	Outfile         = "Morphe_Builder\morphe-patches.mpp"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

echo "MorphePatchesTag=$MorphePatchesTag" >> $env:GITHUB_ENV
