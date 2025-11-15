<hr>

<div align="center">
  <img src=".assets/icon.svg" width="132">
  <h1><samp>GAMHOGEN</samp></h1>
  <p>Windows automatic setup for gamers.</p>
</div>

<hr>

### Previews

<img src=".assets/01.png" width="49.375%"/><img src=".assets/00.png" width="1.25%"/><img src=".assets/02.png" width="49.375%"/>

<hr>

### Features

- Update System
- Update Chromium (Ungoogled)
- Update Epic Games Launcher
- Update JDownloader
- Update QBittorrent
- Update Steam
- Update Xmouser
- Update Appearance

<hr>

### Launch Script

Blindly executing this is strongly discouraged.

```powershell
$Address = "https://raw.githubusercontent.com/olankens/gamhogen/HEAD/src/Gamhogen.ps1"
$Fetched = New-Item $Env:Temp\Gamhogen.ps1 -F ; Invoke-WebRequest $Address -OutFile $Fetched
Try { Pwsh -Ep Bypass $Fetched } Catch { Powershell -Ep Bypass $Fetched }
```

<hr>
