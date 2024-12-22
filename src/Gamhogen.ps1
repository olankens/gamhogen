Function Update-Appearance {

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type Dword -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type Dword -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type Dword -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type Dword -Value 0
    New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -PropertyType Dword -Force
    Get-Process -Name explorer | ForEach-Object { $_.Kill() } ; Start-Sleep -Seconds 5

    $Targets = @("Copilot", "Microsoft Edge", "Microsoft Store", "Outlook (new)")
    $Factors = ((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | Where-Object { $_.Name -In $Targets }).Verbs()
    $Factors | Where-Object { $_.Name.replace("&", "") -Match "Unpin from taskbar" } | ForEach-Object { $_.DoIt() }
    Clear-RecycleBin -Confirm:$False

    $Deposit = "$Env:UserProfile\Pictures\Backgrounds"
    $Picture = "$Deposit\background.jpg"
    $Address = "https://raw.githubusercontent.com/olankens/gamhogen/HEAD/assets/background.jpg"
    New-Item -Path "$Deposit" -ItemType Directory -EA SI
    If (-Not (Test-Path -Path "$Picture")) { (New-Object Net.WebClient).DownloadFile("$Address", "$Picture") }
    Set-DesktopBackground -Picture "$Picture"
    Set-LockscreenBackground -Picture "$Picture"

}

Function Update-Windows {

    Use-ActiveWindows
    Set-Hostname -Payload "GAMHOGEN"
    Set-AudioVolume -Payload 40
    Set-TimeZone -Name "Romance Standard Time"
    Use-ReloadClock

}

Function Update-Amd {

    If ((Get-WmiObject Win32_VideoController).Name -NotLike "*AMD*") { Return $False }

}

Function Update-Firefox {

    $Current = Get-FileVersion "$Env:ProgramFiles\Mozilla Firefox\firefox.exe"
    $Address = "https://raw.githubusercontent.com/ScoopInstaller/Extras/HEAD/bucket/firefox.json"
    $Version = [Regex]::Match((Invoke-WebRequest "$Address" | ConvertFrom-Json).version , "[\d.]+").Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Address = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
        $Fetched = Join-Path "$([System.IO.Path]::GetTempPath())" "FirefoxSetup.msi"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "msiexec" "/i `"$Using:Fetched`" /qn DESKTOP_SHORTCUT=false INSTALL_MAINTENANCE_SERVICE=false" -Wait }
    }

    New-Item -ItemType Directory -Path "$Env:ProgramFiles\Mozilla Firefox\distribution" -Force
    $Configs = "$Env:ProgramFiles\Mozilla Firefox\distribution\policies.json"
    $Content = '
    {
        "policies": {
            "DisablePocket": true,
            "DisableFirefoxAccounts": true,
            "DisableFirefoxStudies": true,
            "DisableTelemetry": true,
            "DisplayMenuBar": "never",
            "DefaultDownloadDirectory": "${home}\\Downloads",
            "NoDefaultBookmarks": true,
            "NewTabPage": false,
            "ExtensionSettings": {
                "uBlock0@raymondhill.net": {
                    "installation_mode": "normal_installed",
                    "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
                }
            },
            "FirefoxHome": {
                "Search": false,
                "TopSites": false,
                "Highlights": false,
                "Pocket": false,
                "Snippets": false,
                "Locked": false
            },
            "Homepage": {
                "URL": "about:blank",
                "Locked": false,
                "StartPage": "none"
            }
        }
    }
    '
    $Content | ConvertFrom-Json | ConvertTo-Json -Compress | Set-Content $Configs -Force

}

Function Update-Heroic {

    $Current = Get-FileVersion "$Env:LocalAppData\Programs\heroic\Heroic.exe"
    $Address = "https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest"
    $Version = [Regex]::Match((Invoke-WebRequest "$Address" | ConvertFrom-Json).tag_name , "[\d.]+").Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Results = (Invoke-WebRequest "$Address" | ConvertFrom-Json).assets
        $Address = $Results.Where( { $_.browser_download_url -Like "*Setup-x64.exe" } ).browser_download_url
        $Fetched = Join-Path "$([System.IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "$Using:Fetched" "/S" -Wait }
    }

    Use-RemoveDesktop -Pattern "Heroic*.lnk"

}
Function Update-Hydra {

    $Current = Get-FileVersion "$Env:LocalAppData\Programs\Hydra\Hydra.exe"
    $Address = "https://api.github.com/repos/hydralauncher/hydra/releases/latest"
    $Version = [Regex]::Match((Invoke-WebRequest "$Address" | ConvertFrom-Json).tag_name , "[\d.]+").Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Results = (Invoke-WebRequest "$Address" | ConvertFrom-Json).assets
        $Address = $Results.Where( { $_.browser_download_url -Like "*setup.exe" } ).browser_download_url
        $Fetched = Join-Path "$([System.IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "$Using:Fetched" "/S" -Wait }
    }

    Use-RemoveDesktop -Pattern "Hydra*.lnk"

}

Function Update-Nanazip {

    Use-UpdateNanazip

}

Function Update-Nvidia {

    If ((Get-WmiObject Win32_VideoController).Name -NotLike "*NVIDIA*") { Return $False }

    $Current = Get-FileVersion "*nvidia*graphics*driver*"
    $Address = "https://raw.githubusercontent.com/ScoopInstaller/Nonportable/HEAD/bucket/nvidia-display-driver-dch-np.json"
    $Version = [Regex]::Match((Invoke-WebRequest "$Address" | ConvertFrom-Json).version, "[\d.]+").Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Address = "https://us.download.nvidia.com/Windows/$Version/$Version-desktop-win10-win11-64bit-international-dch-whql.exe"
        $Fetched = Join-Path "$([System.IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        $Extract = Use-ExpandArchive "$Fetched"
        Invoke-Gsudo { Start-Process "$Using:Extract\setup.exe" "Display.Driver HDAudio.Driver -clean -s -noreboot" -Wait }
    }

}

Function Update-Steam {

    $Current = Get-FileVersion "Steam*"
    $Address = "https://community.chocolatey.org/packages/steam"
    $Version = [Regex]::Matches((Invoke-WebRequest "$Address"), "Steam ([\d.]+)</title>").Groups[1].Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Address = "http://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
        $Fetched = Join-Path "$([System.IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "$Using:Fetched" "/S" -Wait }
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Steam" -EA SI
    }

    Use-RemoveDesktop "Steam*.lnk"

}

If ($MyInvocation.InvocationName -Ne "." -Or "$Env:TERM_PROGRAM" -Eq "Vscode") {

    $Address = "https://raw.githubusercontent.com/olankens/whelpers/HEAD/src/Whelpers.psm1"
    $Content = ([Scriptblock]::Create((New-Object System.Net.WebClient).DownloadString($Address)))
    New-Module -Name "$Address" -ScriptBlock $Content -EA SI > $Null

    $Heading = "
    +--------------------------------------------------------------------+
    |                                                                    |
    |  > GAMHOGEN                                                        |
    |                                                                    |
    |  > WINDOWS AUTOMATIC SETUP FOR GAMERS                              |
    |                                                                    |
    +--------------------------------------------------------------------+
    "

    $Members = @(
        { Update-Windows },
        { Update-Nanazip }
        { Update-Amd },
        { Update-Nvidia },
        { Update-Firefox },
        { Update-Heroic },
        { Update-Hydra },
        { Update-Steam },
        { Update-Appearance }
    )

    Use-UpdateWrapper -Heading $Heading -Members $Members

}