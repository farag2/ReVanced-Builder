<#
	.SYNOPSIS
	Build ReVanced app using latest components:
	  * YouTube (latest supported);
	  * ReVanced CLI;
	  * ReVanced Patches;
	  * ReVanced Integrations;
	  * microG GmsCore;
	  * Azul Zulu.

	.NOTES
	After compiling, microg.apk and compiled revanced.apk will be located in "Downloads folder\ReVanced"

	.LINKS
	https://github.com/revanced
#>

#Requires -Version 5.1
# Doesn't work on PowerShell 7.3 due it doesn't contains IE parser engine. You have to use a 3rd party module to make it work like it's presented in CI/CD config: AngleSharp

# Progress bar can significantly impact cmdlet performance
# https://github.com/PowerShell/PowerShell/issues/2138
$ProgressPreference = "SilentlyContinue"

# Download all files to "Downloads folder\ReVanced"
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
if (-not (Test-Path -Path "$DownloadsFolder\ReVanced"))
{
	New-Item -Path "$DownloadsFolder\ReVanced" -ItemType Directory -Force
}

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

# We need a NON-bundle version
# https://apkpure.net/ru/youtube/com.google.android.youtube/versions
$Parameters = @{
	Uri             = "https://apkpure.net/ru/youtube/com.google.android.youtube/download/$($LatestSupported)"
	UseBasicParsing = $true
	Verbose         = $true
}
$DownloadURL = (Invoke-Webrequest @Parameters).Links.href | Where-Object -FilterScript {$_ -match "APK/com.google.android.youtube"} | Select-Object -Index 1

$Parameters = @{
	Uri             = $DownloadURL
	OutFile         = "$DownloadsFolder\ReVanced\youtube.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

# https://github.com/revanced/revanced-cli
$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$Tag = (Invoke-RestMethod @Parameters).tag_name
$Tag2 = $Tag.replace("v", "")
$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-cli/releases/download/$Tag/revanced-cli-$Tag2-all.jar"
	Outfile         = "$DownloadsFolder\ReVanced\revanced-cli.jar"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# https://github.com/revanced/revanced-patches
$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$Tag = (Invoke-RestMethod @Parameters).tag_name
$Tag2 = $Tag.replace("v", "")
$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-patches/releases/download/$Tag/revanced-patches-$Tag2.jar"
	Outfile         = "$DownloadsFolder\ReVanced\revanced-patches.jar"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# https://github.com/revanced/revanced-integrations
$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-integrations/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$IntegrationsTag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-integrations/releases/download/$IntegrationsTag/revanced-integrations-$($IntegrationsTag.replace(`"v`", `"`")).apk"
	Outfile         = "$DownloadsFolder\ReVanced\revanced-integrations.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# https://github.com/inotia00/VancedMicroG
$Parameters = @{
	Uri             = "https://api.github.com/repos/inotia00/VancedMicroG/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$Tag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
	Uri             = "https://github.com/inotia00/VancedMicroG/releases/download/$Tag/microg.apk"
	Outfile         = "$DownloadsFolder\ReVanced\microg.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

Remove-Item -Path "$DownloadsFolder\ReVanced\zulu-jdk-win_x64" -Recurse -Force -ErrorAction Ignore

# https://app.swaggerhub.com/apis-docs/azul/zulu-download-community/1.0
$Parameters = @{
	Uri             = "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/?jdk_version=&bundle_type=jdk&javafx=false&ext=zip&os=windows&arch=x86&hw_bitness=64"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).url

# Save zulu-jdk-win_x64.msi as zulu-jdk-win_x64.zip with purpose
$Parameters = @{
	Uri             = $URL
	Outfile         = "$DownloadsFolder\ReVanced\zulu-jdk-win_x64.msi"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

$Arguments = @(
	"/a `"$DownloadsFolder\ReVanced\zulu-jdk-win_x64.msi`""
	"TARGETDIR=`"$DownloadsFolder\ReVanced\Zulu`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

# https://revanced.app/patches?pkg=com.google.android.youtube
# https://github.com/ReVanced/revanced-cli/blob/main/docs/1_usage.md
& "$DownloadsFolder\ReVanced\Zulu\Program Files\Zulu\zulu*\bin\java.exe" `
-jar "$DownloadsFolder\ReVanced\revanced-cli.jar" `
patch "$DownloadsFolder\ReVanced\youtube.apk" `
--patch-bundle "$DownloadsFolder\ReVanced\revanced-patches.jar" `
--merge "$DownloadsFolder\ReVanced\revanced-integrations.apk" `
--exclude always-autorepeat --exclude comments --exclude premium-heading --exclude hide-captions-button --exclude disable-fullscreen-panels `
--purge `
--resource-cache "$DownloadsFolder\ReVanced\Temp" `
--out "$DownloadsFolder\ReVanced\revanced.apk"

Invoke-Item -Path "$DownloadsFolder\ReVanced"
