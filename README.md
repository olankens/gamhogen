# <samp>OVERVIEW</samp>

Windows automatic setup for gamers.

<img src="assets/img1.png" width="49.25%"/><img src="assets/img0.png" width="1.5%"/><img src="assets/img2.png" width="49.25%"/>

# <samp>FEATURES</samp>

- Update System
- Update Chromium
- Update Epic Games Launcher
- Update Jdownloader
- Update Qbittorrent
- Update Steam
- Update Xmouser
- Update Appearance

# <samp>GUIDANCE</samp>

### Launch the script

Blindly executing this is strongly discouraged.

```powershell
$Address = "https://raw.githubusercontent.com/olankens/gamhogen/HEAD/src/Gamhogen.ps1"
$Fetched = New-Item $Env:Temp\Gamhogen.ps1 -F ; Invoke-WebRequest $Address -OutFile $Fetched
Try { Pwsh -Ep Bypass $Fetched } Catch { Powershell -Ep Bypass $Fetched }
```
