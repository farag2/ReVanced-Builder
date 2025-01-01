# Get the latest supported YouTube version to patch
# https://api.revanced.app/docs/swagger
$Parameters = @{
	Uri             = "https://api.revanced.app/v4/patches/list"
	UseBasicParsing = $true
	Verbose         = $true
}
$JSON = (Invoke-Webrequest @Parameters).Content | ConvertFrom-Json
$Patches = ($JSON | Where-Object -FilterScript {$_.name -eq "Video ads"})
$LatestSupportedYT = $Patches.compatiblePackages."com.google.android.youtube" | Sort-Object -Descending -Unique | Select-Object -First 1
$LatestSupportedYT = $LatestSupportedYT.Replace(".", "-")

# We need a NON-bundle version
# https://www.apkmirror.com/apk/google-inc/youtube/
$Parameters = @{
	Uri             = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupportedYT)-release/youtube-$($LatestSupportedYT)-android-apk-download/"
	UseBasicParsing = $false # Disabled
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters

$Parameters = @{
	Uri             = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupportedYT)-release/youtube-$($LatestSupportedYT)-2-android-apk-download/"
	UseBasicParsing = $false # Disabled
	Verbose         = $true
}
$Request2 = Invoke-Webrequest @Parameters

# Load AngleSharp
Add-Type -Path "AngleSharp.dll"

@($Request, $Request2) | ForEach-Object -Process {
	$RequestVariable = $_

	(New-Object -TypeName AngleSharp.Html.Parser.HtmlParser).ParseDocument($RequestVariable.Content).All | Where-Object -FilterScript {$_.className -match "downloadButton"} | ForEach-Object -Process {
		if (($_.InnerHtml -notmatch "Download APK Bundle") -and $_.Href)
		{
			$DownloadKey = "$($_.PathName)$($_.Search)"
		}
	}
}

$Parameters = @{
	Uri             = "https://www.apkmirror.com$DownloadKey"
	UseBasicParsing = $true
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters
$DownloadURL = $Request.Links.href | Where-Object -FilterScript {$_ -match "download.php"}

$Parameters = @{
	Uri             = "https://www.apkmirror.com/$DownloadURL"
	OutFile         = "ReVanced_Builder\youtube.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

echo "LatestSupportedYT=$LatestSupportedYT" >> $env:GITHUB_ENV
