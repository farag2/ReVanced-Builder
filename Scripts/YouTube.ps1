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
$LatestSupported = $LatestSupportedYT.Replace(".", "-")

# We need a NON-bundle version
# https://www.apkmirror.com/apk/google-inc/youtube/
$Parameters = @{
	Uri             = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-android-apk-download/"
	UseBasicParsing = $false # Disabled
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters

$Parameters = @{
	Uri             = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-2-android-apk-download/"
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
	UserAgent       = "Mozilla/5.0 (Linux; Android 13; itel A665L Build/TP1A.220624.014) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.7204.45 Mobile Safari/537.36"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

echo "LatestSupportedYT=$LatestSupportedYT" >> $env:GITHUB_ENV
