<hr>

# OVERVIEW

Windows automatic setup for gamers.

<hr>

# PREVIEWS

<img src=".assets/img1.png" width="49.375%"/><img src=".assets/1x1.png" width="1.25%"/><img src=".assets/img2.png" width="49.375%"/>

<hr>

# FEATURES

- Update System
- Update Chromium (Ungoogled)
- Update Epic Games Launcher
- Update JDownloader
- Update QBittorrent
- Update Steam
- Update Xmouser
- Update Appearance

<hr>

# GUIDANCE

### Launch Script

Blindly executing this is strongly discouraged.

```powershell
$Address = "https://raw.githubusercontent.com/olankens/gamhogen/HEAD/src/Gamhogen.ps1"
$Fetched = New-Item $Env:Temp\Gamhogen.ps1 -F ; Invoke-WebRequest $Address -OutFile $Fetched
Try { Pwsh -Ep Bypass $Fetched } Catch { Powershell -Ep Bypass $Fetched }
```

<hr>
