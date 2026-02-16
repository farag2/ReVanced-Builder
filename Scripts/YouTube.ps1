#Requires -Version 7.4

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

Write-Verbose -Message "Microsoft Edge driver" -Verbose

# Get runner Microsoft Edge Version
# https://edgeupdates.microsoft.com/api/products
# https://github.com/GoogleChromeLabs/chrome-for-testing/blob/main/data/last-known-good-versions-with-downloads.json
$RunnerEdgeVersion = (Get-Item -Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe").VersionInfo.FileVersion

# Download Microsoft Edge driver
# https://developer.microsoft.com/microsoft-edge/tools/webdriver/
$Parameters = @{
	Uri             = "https://msedgedriver.microsoft.com/$RunnerEdgeVersion/edgedriver_win64.zip"
	OutFile         = "ReVanced_Builder\edgedriver_win64.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

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
$Options.AddUserProfilePreference("download.directory_upgrade", $true)
$Options.AddUserProfilePreference("download.prompt_for_download", $false)

$Service = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateDefaultService("ReVanced_Builder", "msedgedriver.exe")
$driver = New-Object -TypeName OpenQA.Selenium.Edge.EdgeDriver($Service, $Options)

# https://www.apkmirror.com/apk/google-inc/youtube/
$APKMirrorURL = "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$($LatestSupported)-release/youtube-$($LatestSupported)-2-android-apk-download/"

Write-Verbose -Message "Trying URL $APKMirrorURL" -Verbose

$driver.Navigate().GoToUrl($APKMirrorURL)
$ButtonTitle = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("a.downloadButton"))

$ButtonTitle.Text.Trim()

if ($ButtonTitle.Text.Trim() -match "DOWNLOAD APK BUNDLE")
{
	Write-Verbose -Message "$ButtonTitle.Text.Trim() matches 'BUNDLE'" -Verbose

	$driver.Quit()
	exit
}

$DownloadURL = $ButtonTitle.GetAttribute("href")
$DownloadURL
# Download youtube.apk
$driver.Navigate().GoToUrl($DownloadURL)
# $driver.FindElement([OpenQA.Selenium.By]::Id("download-link")).GetAttribute("href")
test-path -Path D:\Desktop\ReVanced_Builder\*.crdownload
Start-Sleep -Seconds 10
test-path -Path D:\Desktop\ReVanced_Builder\*.crdownload
Get-ChildItem -Path ReVanced_Builder

$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
if (Test-Path -Path $DownloadsFolder\*.apk)
{
	$Parameters = @{
		Path        = "$DownloadsFolder\*.apk"
		Destination = "ReVanced_Builder"
		Force       = $true
	}
	Copy-Item @Parameters
}
else
{
	Write-Verbose -Message "Cannot download youtube.apk" -Verbose
	Get-ChildItem -Path ReVanced_Builder
	Get-ChildItem -Path $DownloadsFolder

	# Exit with a non-zero status to fail the job
	exit 1
}

$driver.Quit()
Get-Process -Name msedgedriver, msedge -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore

echo "LatestSupportedYT=$LatestSupportedYT" >> $env:GITHUB_ENV
