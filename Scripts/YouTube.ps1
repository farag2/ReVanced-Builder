# Get latest supported YouTube client version via ReVanced JSON
# It will let us to download always latest YouTube apk supported by ReVanced team
# https://github.com/revanced/revanced-patches/blob/main/patches.json
$Parameters = @{
    Uri             = "https://raw.githubusercontent.com/revanced/revanced-patches/main/patches.json"
    UseBasicParsing = $true
}
$JSON = Invoke-RestMethod @Parameters
$versions = ($JSON | Where-Object -FilterScript {$_.compatiblePackages.name -eq "com.google.android.youtube"}).compatiblePackages.versions
$LatestSupported = $versions | Sort-Object -Descending -Unique | Select-Object -First 1
$LatestSupportedYT = $LatestSupported.replace(".", "-")

$AngleSharpAssemblyPath = (Get-ChildItem -Path (Split-Path -Path (Get-Package -Name AngleSharp).Source) -Filter "*.dll" -Recurse | Where-Object -FilterScript {$_ -match "standard"} | Select-Object -Last 1).FullName
Add-Type -Path $AngleSharpAssemblyPath

# Get unique key to generate direct link
# https://www.apkmirror.com/apk/google-inc/youtube/
# We need a NON-bundle version
# We choose an alive link depending on YouTube version. Sometimes with "-2" in URL, sometimes not. Firstly, we check with "-2" in URL
try
{
	# with "-2"
	$Parameters = @{
		Uri             = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-2-android-apk-download/"
		UseBasicParsing = $false # Disabled
		Verbose         = $true
	}
	$Request = Invoke-Webrequest @Parameters

	$Uri = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-2-android-apk-download/"
}
catch [System.Net.WebException]
{
	# without "-2"
	$Parameters = @{
		Uri             = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-android-apk-download/"
		UseBasicParsing = $false # Disabled
		Verbose         = $true
	}
	$Request = Invoke-Webrequest @Parameters

	$Uri = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-android-apk-download/"
}

$Parsed = (New-Object -TypeName AngleSharp.Html.Parser.HtmlParser).ParseDocument($Request.Content)
$Key = $Parsed.All | Where-Object -FilterScript {$_.ClassName -match "accent_bg btn btn-flat downloadButton"} | ForEach-Object -Process {$_.Search}

$Parameters = @{
	Uri             = "$($Uri)/download/$($Key)"
	UseBasicParsing = $true
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters
$Parsed = (New-Object -TypeName AngleSharp.Html.Parser.HtmlParser).ParseDocument($Request.Content)
$Key = ($Parsed.All | Where-Object -FilterScript {$_.InnerHtml -eq "here"}).Search

# Finally, get the real link
$Parameters = @{
	Uri             = "https://www.apkmirror.com/wp-content/themes/APKMirror/download.php$Key"
	OutFile         = "Temp\youtube.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

echo "LatestSupportedYT=$LatestSupportedYT" >> $env:GITHUB_ENV
