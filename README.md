# ReVanced builder

Build ReVanced package (.apk) easily than ever using latest ReVanced patches and dependencies

## Usage

* To build `revanced.apk` locally you need just to run [`Build.ps1`](https://github.com/farag2/ReVanced_Builder/blob/main/Build.ps1) via PowerShell;
* Configure [patches](https://github.com/revanced/revanced-patches) applied to `revanced.apk`. Dy defaulft, only following patches are applied:
  * disable-create-button
  * hide-cast-button
  * return-youtube-dislike
  * hide-autoplay-button
  * hide-watermark
  * sponsorblock
  * minimized-playback
  * client-spoof
  * microg-support
  * settings
  * hdr-auto-brightness
  * remember-video-quality
  * video-ads
  * general-ads
* The script will download all latest versions dependencies and build package using [Zulu JDK](https://www.azul.com/downloads/?package=jdk);
* Script installs no apps—everything will be held in your `Downloads folder\ReVanced`;
* After compiling you get `revanced.apk` & `microg.apk` ready to be installed.

## By using CI/CD

```powershell
git clone https://github.com/farag2/ReVanced_Builder
```
Trigger the [`Build`](https://github.com/farag2/ReVanced_Builder/actions/workflows/Build.yml) Action manually to create [release page](https://github.com/farag2/ReVanced_Builder/releases/latest) with configured release notes showing dependencies used for building.

![image](https://user-images.githubusercontent.com/10544660/187949763-82fd7a07-8e4e-4527-b631-11920077141f.png)

`ReVanced.zip` will contain a built `revanced.apk` & latest `microg.apk`.

## Links

[ReVanced](https://github.com/revanced)
