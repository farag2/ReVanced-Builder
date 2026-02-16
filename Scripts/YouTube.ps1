host

New-Item -Path ReVanced_Builder -ItemType Directory -Force

# Get the latest supported YouTube version to patch
# https://api.revanced.app
$Parameters = @{
	Uri             = "https://api.revanced.app/v4/patches/list"
	UseBasicParsing = $true
	Verbose         = $true
}
$Patches = (Invoke-RestMethod @Parameters | Where-Object -FilterScript {$_.name -eq "Video ads"})
$LatestSupportedYT = $Patches.compatiblePackages."com.google.android.youtube" | Sort-Object -Descending -Unique | Select-Object -First 1
$LatestSupported = $LatestSupportedYT.Replace(".", "-")

Get-Process -Name msedgedriver, msedge -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore

# Get Microsoft Edge version
$Parameters = @{
	Uri             = "https://edgeupdates.microsoft.com/api/products"
	UseBasicParsing = $true
	Verbose         = $true
}
$products = Invoke-RestMethod @Parameters
$EdgeVersion = (($products | Where-Object -FilterScript {$_.Product -eq "Stable"}).Releases | Where-Object -FilterScript {($_.Architecture -eq "x64") -and ($_.Platform -eq "Windows")}).ProductVersion

Write-Verbose -Message "Microsoft Edge driver" -Verbose
"https://msedgedriver.microsoft.com/$EdgeVersion/edgedriver_win64.zip"

# Download Microsoft Edge driver
# https://github.com/GoogleChromeLabs/chrome-for-testing/blob/main/data/last-known-good-versions-with-downloads.json
# https://developer.microsoft.com/microsoft-edge/tools/webdriver/
$Parameters = @{
	Uri             = "https://msedgedriver.microsoft.com/$EdgeVersion/edgedriver_win64.zip"
	OutFile         = "ReVanced_Builder\edgedriver_win64.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
$EdgewebdriverURL = ((Invoke-RestMethod @Parameters).channels.Stable.downloads.chromedriver | Where-Object -FilterScript {$_.platform -eq "win64"}).url

Write-Verbose -Message "Selenium web driver" -Verbose

# Download Selenium web driver
# https://www.nuget.org/packages/selenium.webdriver
# https://www.nuget.org/packages/selenium.support
try
{
	$Parameters = @{
		Uri             = "https://www.nuget.org/api/v2/package/Selenium.WebDriver"
		OutFile         = "ReVanced_Builder\selenium.webdriver.nupkg"
		UseBasicParsing = $true
		Verbose         = $true
		ErrorAction     = "Stop"
	}
	Invoke-RestMethod @Parameters
}
catch
{
	Write-Verbose -Message "Cannot download Selenium web driver" -Verbose

	# Exit with a non-zero status to fail the job
	exit 1
}

$Parameters = @{
	Path            = "ReVanced_Builder\edgedriver_win64.zip"
	DestinationPath = "ReVanced_Builder"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

# Extract WebDriver.dll from archive
Add-Type -Assembly System.IO.Compression.FileSystem
$ZIP = [IO.Compression.ZipFile]::OpenRead("ReVanced_Builder\selenium.webdriver.nupkg")
$Entries = $ZIP.Entries | Where-Object -FilterScript {$_.FullName -eq "lib/net8.0/WebDriver.dll"}
$Entries | ForEach-Object -Process {[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "ReVanced_Builder\$($_.Name)", $true)}
$ZIP.Dispose()

$Paths = @(
	"ReVanced_Builder\Driver_Notes",
	"ReVanced_Builder\edgedriver_win64.zip",
	"ReVanced_Builder\selenium.webdriver.nupkg"
)
Remove-Item -Path $Paths -Force -Recurse

Write-Verbose -Message "Adding web driver" -Verbose

# Start parsing pages
Add-Type -Path "ReVanced_Builder\WebDriver.dll"

$Options = New-Object -TypeName OpenQA.Selenium.Edge.EdgeOptions
$Options.AddArgument("--headless=new")
$Options.AddArgument("--window-size=1280,720")
$Options.AddArgument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0")
$Options.AddUserProfilePreference("download.default_directory", "ReVanced_Builder")
$Options.AddUserProfilePreference("download.prompt_for_download", $false)

$driver = New-Object -TypeName OpenQA.Selenium.Edge.EdgeDriver("ReVanced_Builder\msedgedriver.exe", $Options)

# https://www.apkmirror.com/apk/google-inc/youtube/
$APKMirrorURLs = @(
	"https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-android-apk-download/",
	"https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-2-android-apk-download/"
)
foreach ($APKMirrorURL in $APKMirrorURLs)
{
	Write-Verbose -Message "Trying URL $APKMirrorURL" -Verbose

	$driver.Navigate().GoToUrl($APKMirrorURL)
	$ButtonTitle = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("a.downloadButton"))

	# We need a NON-bundle version
	if ($ButtonTitle.Text.Trim() -match "DOWNLOAD APK BUNDLE")
	{
		$ButtonTitle.Text.Trim()
		Write-Verbose -Message "$APKMirrorURL doesn't match criteria. Continue loop" -Verbose

		continue
	}

	$DownloadURL = $ButtonTitle.GetAttribute("href")

	# Download youtube.apk
	$driver.Navigate().GoToUrl($DownloadURL)
	# $driver.FindElement([OpenQA.Selenium.By]::Id("download-link")).GetAttribute("href")

	if (Test-Path -Path ReVanced_Builder\*.apk)
	{
		Write-Verbose -Message "youtube.apk downloaded" -Verbose

		$driver.Quit()
		exit
	}
}

Get-Process -Name msedgedriver, msedge -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore

#echo "LatestSupportedYT=$LatestSupportedYT" >> $env:GITHUB_ENV

