<#
	.SYNOPSIS
	Build ReVanced app using latest components:
	YouTube (latest supported);
	ReVanced CLI;
	ReVanced Patches;
	ReVanced Integrations;
	ReVanced microG GmsCore;
	Azul Zulu.

	.NOTES
	After compiling, microg.apk and compiled revanced.apk will be located in "Downloads folder\ReVanced"

	.LINKS
	https://github.com/revanced
#>

#Requires -Version 5.1

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($Host.Version.Major -eq 5)
{
	# Progress bar can significantly impact cmdlet performance
	# https://github.com/PowerShell/PowerShell/issues/2138
	$Script:ProgressPreference = "SilentlyContinue"
}

# Download all files to "Downloads folder\ReVanced"
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
if (-not (Test-Path -Path "$DownloadsFolder\ReVanced"))
{
	New-Item -Path "$DownloadsFolder\ReVanced" -ItemType Directory -Force
}

# Get the latest supported YouTube version to patch
# https://api.revanced.app
$Parameters = @{
	Uri             = "https://api.revanced.app/v4/patches/list"
	UseBasicParsing = $true
	Verbose         = $true
}
$JSON = (Invoke-Webrequest @Parameters).Content | ConvertFrom-Json
$versions = ($JSON | Where-Object -FilterScript {$_.name -eq "Video ads"})
$LatestSupported = $versions.compatiblePackages.'com.google.android.youtube' | Sort-Object -Descending -Unique | Select-Object -First 1
$LatestSupported = $LatestSupported.Replace(".", "-")

Write-Verbose -Message "Downloading the latest supported YouTube apk" -Verbose

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

@($Request, $Request2) | ForEach-Object -Process {
	$RequestVariable = $_

	$RequestVariable.ParsedHtml.getElementsByTagName("a") | Where-Object -FilterScript {$_.className -match "downloadButton"} | ForEach-Object -Process {
		if ($_.innerText -notmatch "Download APK Bundle")
		{
			$DownloadKey = $_.href.Replace("about:/", "")
		}
	}
}

$Parameters = @{
	Uri             = "https://www.apkmirror.com/$DownloadKey"
	UseBasicParsing = $true
	Verbose         = $true
}
$Request = Invoke-Webrequest @Parameters
$DownloadURL = $Request.Links.href | Where-Object -FilterScript {$_ -match "download.php"}

$Parameters = @{
	Uri             = "https://www.apkmirror.com/$DownloadURL"
	OutFile         = "$DownloadsFolder\ReVanced\youtube.apk"
	UserAgent       = "Mozilla/5.0 (Linux; Android 13; itel A665L Build/TP1A.220624.014) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.7204.45 Mobile Safari/537.36"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-Webrequest @Parameters

Write-Verbose -Message "Downloading ReVanced cli" -Verbose

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

Write-Verbose -Message "Downloading ReVanced patches" -Verbose

# https://github.com/revanced/revanced-patches
$Parameters = @{
	Uri             = "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}

$Patchesvtag = (Invoke-RestMethod @Parameters).tag_name
$Patchestag = $Patchesvtag.replace("v", "")

$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-patches/releases/download/$Patchesvtag/patches-$Patchestag.rvp"
	Outfile         = "$DownloadsFolder\ReVanced\revanced-patches.rvp"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

Write-Verbose -Message "Downloading ReVanced GmsCore" -Verbose

# https://github.com/ReVanced/GmsCore
# https://github.com/WSTxda/MicroG-RE
$Parameters = @{
	Uri             = "https://api.github.com/repos/ReVanced/GmsCore/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
# Default microg.apk
$URL_Default = (Invoke-RestMethod @Parameters).assets.browser_download_url | Where-Object -FilterScript {$_ -notmatch "hw"}
# microg.apk for Huawei, Xiaomi
$URL_Vendors = (Invoke-RestMethod @Parameters).assets.browser_download_url | Where-Object -FilterScript {$_ -match "hw"}

# Default microg.apk
$Parameters = @{
	Uri             = $URL_Default
	Outfile         = "$DownloadsFolder\ReVanced\microg.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# microg.apk for Huawei, Xiaomi
$Parameters = @{
	Uri             = $URL_Vendors
	Outfile         = "$DownloadsFolder\ReVanced\microg_for_huawei.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

Remove-Item -Path "$DownloadsFolder\ReVanced\zulu-jdk-win_x64" -Recurse -Force -ErrorAction Ignore

Write-Verbose -Message "Downloading Azul Zulu" -Verbose

# https://app.swaggerhub.com/apis-docs/azul/zulu-download-community/1.0
$Parameters = @{
	Uri             = "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/?jdk_version=21&bundle_type=jdk&javafx=false&ext=msi&os=windows&arch=x86&hw_bitness=64"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).url

$Parameters = @{
	Uri             = $URL
	Outfile         = "$DownloadsFolder\ReVanced\zulu-jdk-win_x64.msi"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# Extract zulu-jdk-win_x64.msi to zulu-jdk-win_x64 folder
$Arguments = @(
	"/a `"$DownloadsFolder\ReVanced\zulu-jdk-win_x64.msi`"",
	"TARGETDIR=`"$DownloadsFolder\ReVanced\zulu-jdk-win_x64`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

Remove-Item -Path "$DownloadsFolder\ReVanced\zulu-jdk-win_x64.msi" -Force

# https://revanced.app/patches?pkg=com.google.android.youtube
# https://github.com/ReVanced/revanced-cli/tree/main/docs
& "$DownloadsFolder\ReVanced\zulu-jdk-win_x64\Program Files\Zulu\zulu*\bin\java.exe" `
-jar "$DownloadsFolder\ReVanced\revanced-cli.jar" `
patch "$DownloadsFolder\ReVanced\youtube.apk" `
--patches "$DownloadsFolder\ReVanced\revanced-patches.rvp" `
--purge `
--out "$DownloadsFolder\ReVanced\revanced.apk"

Invoke-Item -Path "$DownloadsFolder\ReVanced"

$Files = @(
	"$DownloadsFolder\ReVanced\revanced-temporary-files",
	"$DownloadsFolder\ReVanced\zulu-jdk-win_x64",
	"$DownloadsFolder\ReVanced\revanced.keystore",
	"$DownloadsFolder\ReVanced\revanced-cli.jar",
	"$DownloadsFolder\ReVanced\revanced-patches.rvp",
	"$DownloadsFolder\ReVanced\youtube.apk"
)
Remove-Item -Path $Files -Recurse -Force
