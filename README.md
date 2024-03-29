[![Telegram](https://img.shields.io/badge/Sophia%20Chat-Telegram-blue?style=flat&logo=Telegram)](https://t.me/sophia_chat) [![Builder](https://img.shields.io/github/actions/workflow/status/farag2/ReVanced_Builder/Build.yml?label=GitHub%20Actions&logo=GitHub)](https://github.com/farag2/ReVanced_Builder/actions)

# ReVanced builder

Build ReVanced package (.apk) easily than ever using latest ReVanced patches and dependencies locally or via cloud

## Usage

### Locally

* To build `revanced.apk` locally you need just to run [`Build.ps1`](https://github.com/farag2/ReVanced_Builder/blob/main/Build.ps1) via PowerShell;
* All [patches](https://github.com/revanced/revanced-patches) except the followings applied to `revanced.apk`:
  * comments
  * premium-heading
  * hide-captions-button
  * disable-fullscreen-panels

* The script downloads latest available YouTube package (having parsed [JSON](https://api.revanced.app/v2/patches/latest)) supported by ReVanced Team from <https://apkpure.net> and all dependencies and build package using [Zulu JDK](https://www.azul.com/downloads/?package=jdk);
* Script installs no apps—everything will be held in your `Downloads folder\ReVanced`;
* After compiling you get `revanced.apk` & `microg.apk` ready to be installed;
* Release notes are generated dynamically using the [Release.md](https://github.com/farag2/ReVanced_Builder/blob/main/ReleaseNotesTemplate.md) template.

### By using CI/CD

```powershell
git clone https://github.com/farag2/ReVanced_Builder
```

Trigger the [`Build`](https://github.com/farag2/ReVanced_Builder/actions/workflows/Build.yml) Action manually to create [release page](https://github.com/farag2/ReVanced_Builder/releases/latest) with configured release notes showing dependencies used for building.

![image](https://user-images.githubusercontent.com/10544660/187949763-82fd7a07-8e4e-4527-b631-11920077141f.png)

`ReVanced.zip` will contain a built `revanced.apk` & latest `microg.apk`.

## Requirements if you compile locally

* Windows 10 x64 or Windows 11
* Windows PowerShell 5.1/PowerShell 7.

## Links

* [ReVanced Patches](https://github.com/revanced/revanced-patches)
* [ReVanced Manager](https://github.com/revanced/revanced-manager)
* [Telegram](https://t.me/sophia_chat)
* [AngleSharp](https://github.com/AngleSharp/AngleSharp)
