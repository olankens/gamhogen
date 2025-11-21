<div align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".assets/icon-dark.svg">
        <img src=".assets/icon.svg" height="132">
    </picture>
    <h1><samp>PADFORGE</samp></h1>
    <p>Windows automatic setup for gamers.</p>
</div>

---

<h3 align="center">Previews</h3>

<img src=".assets/01.png" width="49.375%"/><img src=".assets/1x1.gif" width="1.25%"/><img src=".assets/02.png" width="49.375%"/>

---

<h3 align="center">Launch Script</h3>

<p align="center">Blindly executing this is strongly discouraged.</p>

```powershell
$Address = "https://raw.githubusercontent.com/olankens/padforge/HEAD/src/Gamhogen.ps1"
$Fetched = New-Item $Env:Temp\Gamhogen.ps1 -F ; Invoke-WebRequest $Address -OutFile $Fetched
Try { Pwsh -Ep Bypass $Fetched } Catch { Powershell -Ep Bypass $Fetched }
```
