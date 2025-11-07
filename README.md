<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".assets/icon-dark.png">
    <img src=".assets/icon-light.png" width="144">
  </picture>
</p>

<h1 align="center"><samp>GAMHOGEN</samp></h1>

<p align="center">Windows automatic setup for gamers.</p>

<hr>

<h3 align="center">Previews</h3>

<img src=".assets/img1.png" width="49.375%"/><img src=".assets/1x1.png" width="1.25%"/><img src=".assets/img2.png" width="49.375%"/>

<hr>

<h3 align="center">Launch Script</h3>

<p align="center">Blindly executing this is strongly discouraged.</p>

```powershell
$Address = "https://raw.githubusercontent.com/olankens/gamhogen/HEAD/src/Gamhogen.ps1"
$Fetched = New-Item $Env:Temp\Gamhogen.ps1 -F ; Invoke-WebRequest $Address -OutFile $Fetched
Try { Pwsh -Ep Bypass $Fetched } Catch { Powershell -Ep Bypass $Fetched }
```
