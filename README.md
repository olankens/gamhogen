# <samp>OVERVIEW</samp>

Windows 11 automatic setup for gamers.

<img src="assets/img1.png" width="49.25%"/><img src="assets/img0.png" width="1.5%"/><img src="assets/img2.png" width="49.25%"/>

# <samp>FEATURES</samp>

- Setup and tweak Windows
- Setup and tweak Amd
- Setup and tweak Nvidia
- Setup and tweak Firefox
- Setup and tweak Heroic
- Setup and tweak Hydra
- Setup and tweak Steam
- Setup and tweak Appearance

# <samp>GUIDANCE</samp>

Blindly executing this is strongly discouraged.

```powershell
$Address = "https://raw.githubusercontent.com/olankens/gamhogen/HEAD/Gamhogen.ps1"
$Fetched = New-Item $Env:Temp\Gamhogen.ps1 -F ; Invoke-WebRequest $Address -OutFile $Fetched
Try { Pwsh -Ep Bypass $Fetched } Catch { Powershell -Ep Bypass $Fetched }
```
