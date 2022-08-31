<#
	.SYNOPSIS
	Build ReVanced app using latest components:
	  * YouTube 17.33.42 (latest supported);
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
# Download all files to "Downloads folder\ReVanced"
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
if (-not (Test-Path -Path "$DownloadsFolder\ReVanced"))
{
	New-Item -Path "$DownloadsFolder\ReVanced" -ItemType Directory -Force
}

# https://apkpure.com/youtube/com.google.android.youtube/versions
# YouTube 17.33.42
$Parameters = @{
	Uri             = "https://apkpure.com/youtube/com.google.android.youtube/download/1531188672-APK-1d33a9dd6b47ec963ea80d2437ef7d3f"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = ((Invoke-Webrequest @Parameters).Links | Where-Object -FilterScript {$_.href -match "https://download.apkpure.com"}).href
$Parameters = @{
	Uri             = $URL
	Outfile         = "$DownloadsFolder\ReVanced\youtube.apk"
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
$Tag = (Invoke-RestMethod @Parameters).tag_name
$Parameters = @{
	Uri             = "https://github.com/revanced/revanced-integrations/releases/download/$Tag/app-release-unsigned.apk"
	Outfile         = "$DownloadsFolder\ReVanced\app-release-unsigned.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# https://github.com/microg/GmsCore
$Parameters = @{
	Uri             = "https://api.github.com/repos/microg/GmsCore/releases/latest"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.browser_download_url -notmatch "asc"}).browser_download_url
$Parameters = @{
	Uri             = $URL
	Outfile         = "$PSScriptRoot\ReVanced\microg.apk"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# https://github.com/ScoopInstaller/Java/blob/master/bucket/zulu-jdk.json
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/ScoopInstaller/Java/master/bucket/zulu-jdk.json"
	UseBasicParsing = $true
	Verbose         = $true
}
$URL = (Invoke-RestMethod @Parameters).architecture."64bit".url
$Parameters = @{
	Uri             = $URL
	Outfile         = "$DownloadsFolder\ReVanced\jdk_windows-x64_bin.zip"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

# Expand jdk_windows-x64_bin archive
$Parameters = @{
	Path            = "$DownloadsFolder\ReVanced\jdk_windows-x64_bin.zip"
	DestinationPath = "$DownloadsFolder\ReVanced\jdk_windows-x64_bin"
	Force           = $true
	Verbose         = $true
}
Expand-Archive @Parameters

Remove-Item -Path "$DownloadsFolder\ReVanced\jdk_windows-x64_bin.zip" -Force

# https://github.com/revanced/revanced-patches
& "$DownloadsFolder\ReVanced\jdk_windows-x64_bin\zulu*win_x64\bin\java.exe" `
-jar "$DownloadsFolder\ReVanced\revanced-cli.jar" `
--apk "$DownloadsFolder\ReVanced\youtube.apk" `
--bundles "$DownloadsFolder\ReVanced\revanced-patches.jar" `
--merge "$DownloadsFolder\ReVanced\app-release-unsigned.apk" `
--exclude timeline-ads `
--exclude premium-icon-reddit `
--exclude general-reddit-ads `
--exclude pflotsh-ecmwf-subscription-unlock `
--exclude minimized-playback-music --exclude tasteBuilder-remover --exclude hide-get-premium --exclude compact-header --exclude upgrade-button-remover --exclude background-play --exclude music-microg-support --exclude music-video-ads --exclude codecs-unlock --exclude exclusive-audio-playback `
--exclude promo-code-unlock `
--exclude tiktok-ads `
--exclude swipe-controls --exclude downloads --exclude amoled --exclude hide-autoplay-button --exclude premium-heading --exclude disable-fullscreen-panels --exclude old-quality-layout --exclude enable-wide-searchbar --exclude tablet-mini-player --exclude always-autorepeat --exclude enable-debugging --exclude custom-playback-speed --exclude hide-infocard-suggestions `
--clean `
--temp-dir "$DownloadsFolder\ReVanced\Temp" `
--out "$DownloadsFolder\ReVanced\revanced.apk"

Invoke-Item -Path "$DownloadsFolder\ReVanced"

Write-Warning -Message "Latest available revanced.apk & microg.apk are ready in `"$DownloadsFolder\ReVanced`""
