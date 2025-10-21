Function Update-Amd {

    If ((Get-WmiObject Win32_VideoController).Name -NotLike "*AMD*") { Return $False }

}

Function Update-Appearance {

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "IconSize" -value 56
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "FFLAGS" -Value 1075839525
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
    Invoke-Gsudo { New-ItemProperty -Path "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -PropertyType Dword -Force }
    Get-Process -Name explorer | ForEach-Object { $_.Kill() } ; Start-Sleep -Seconds 5

    $Targets = @("Copilot", "Microsoft Edge", "Microsoft Store", "Outlook (new)")
    $Factors = ((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | Where-Object { $_.Name -In $Targets }).Verbs()
    $Factors | Where-Object { $_.Name.replace("&", "") -Match "Unpin from taskbar" } | ForEach-Object { $_.DoIt() }
    Clear-RecycleBin -Confirm:$False

    $Deposit = "$Env:UserProfile\Pictures\Backgrounds"
    $Picture = "$Deposit\background.jpg"
    $Address = "https://raw.githubusercontent.com/olankens/gamhogen/HEAD/.assets/background.jpg"
    New-Item -Path "$Deposit" -ItemType Directory -EA SI
    If (-Not (Test-Path -Path "$Picture")) { (New-Object Net.WebClient).DownloadFile("$Address", "$Picture") }
    Set-DesktopBackground -Picture "$Picture"
    Set-LockscreenBackground -Picture "$Picture"

    Set-DisplayScaling -Scaling 2

}

Function Update-Chromium {

    Param (
        [String] $Deposit = "$Env:UserProfile\Downloads\DDL",
        [String] $Startup = "about:blank"
    )

    Add-Type -AssemblyName System.Windows.Forms

    $Starter = "$Env:ProgramFiles\Chromium\Application\chrome.exe"
    $Current = Get-FileVersion "*chromium*"
    $Present = $Current -Ne "0.0"
    $Address = "https://api.github.com/repos/ungoogled-software/ungoogled-chromium-windows/releases/latest"
    $Version = [Regex]::Match((Invoke-WebRequest "$Address" | ConvertFrom-Json).tag_name , "[\d.]+").Value
    $Updated = $Present -And [Version] $Current -Ge [Version] "$Version"
    If (-Not $Updated) {
        $Results = (Invoke-WebRequest "$Address" | ConvertFrom-Json).assets
        $Pattern = If ($Env:PROCESSOR_ARCHITECTURE -Match "^ARM") { "*installer_arm64.exe" } Else { "*installer_x64.exe" }
        $Address = $Results.Where( { $_.browser_download_url -Like "$Pattern" } ).browser_download_url
        $Fetched = Join-Path "$([IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "$Using:Fetched" "--system-level --do-not-launch-chrome" -Wait }
    }

    If (-Not $Present) {
        New-Item "$Deposit" -ItemType Directory -EA SI
        Start-Sleep 2 ; $Process = Start-Process "$Starter" "--lang=en --start-maximized" -PassThru
        While ($Process.MainWindowHandle -Eq 0) { Start-Sleep -Milliseconds 500; $Process.Refresh() }
        Start-Sleep 2 ; [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("^l")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("chrome://settings/")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("before downloading")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}" * 3)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("$Deposit")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")

        Start-Sleep 8 ; [Windows.Forms.SendKeys]::SendWait("^l")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("chrome://flags/")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("custom-ntp")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}" * 4)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("^a")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("$Startup")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}" * 2)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{DOWN}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")

        Start-Sleep 8 ; [Windows.Forms.SendKeys]::SendWait("^l")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("chrome://flags/")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("extension-mime-request-handling")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}" * 5)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{DOWN}" * 2)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")

        Start-Sleep 8 ; [Windows.Forms.SendKeys]::SendWait("^l")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("chrome://flags/")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("show-avatar-button")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}" * 5)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{DOWN}" * 3)
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")

        Start-Sleep 8 ; [Windows.Forms.SendKeys]::SendWait("^l")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("^+b")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("%{F4}") ; Start-Sleep 2

        $Address = "https://api.github.com/repos/NeverDecaf/chromium-web-store/releases/latest"
        $Results = (Invoke-WebRequest "$Address" | ConvertFrom-Json).assets
        $Address = $Results.Where( { $_.browser_download_url -Like "*.crx" } ).browser_download_url
        Update-ChromiumExtension -Payload "$Address"
    }

    Update-ChromiumExtension -Payload "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock-origin
    Use-RemoveDesktop -Pattern "Chromium*.lnk"

}

Function Update-ChromiumExtension {

    Param (
        [String] $Payload
    )

    Add-Type -AssemblyName System.Windows.Forms

    $Package = $Null
    $Starter = "$Env:ProgramFiles\Chromium\Application\chrome.exe"
    If (Test-path "$Starter") {
        If ($Payload -Like "http*") {
            $Address = "$Payload"
            $Package = Join-Path "$([IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
            (New-Object Net.WebClient).DownloadFile("$Address", "$Package")
        }
        Else {
            $Version = Try { (Get-Item "$Starter" -EA SI).VersionInfo.FileVersion.ToString() } Catch { "0.0.0.0" }
            $Address = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3"
            $Address = "${Address}&prodversion=${Version}&x=id%3D${Payload}%26installsource%3Dondemand%26uc"
            $Package = "$Env:Temp\$Payload.crx"
            (New-Object Net.WebClient).DownloadFile("$Address", "$Package")
        }
        If ($Null -Ne $Package -And (Test-Path "$Package")) {
            If ($Package -Like "*.zip") {
                $Deposit = "$Env:ProgramFiles\Chromium\Unpacked\$($Payload.Split("/")[4])"
                $Present = Test-Path "$Deposit"
                Invoke-Gsudo { New-Item "$Using:Deposit" -ItemType Directory -EA SI }
                $Extract = Use-ExpandArchive "$Package"
                $Topmost = (Get-ChildItem -Path "$Extract" -Directory | Select-Object -First 1).FullName
                Invoke-Gsudo { Copy-Item -Path "$Using:Topmost\*" -Destination "$Using:Deposit" -Recurse -Force }
                If ($Present) { Return }
                Start-Sleep 2 ; $Process = Start-Process "$Starter" "--lang=en --start-maximized" -PassThru
                While ($Process.MainWindowHandle -Eq 0) { Start-Sleep -Milliseconds 500; $Process.Refresh() }
                Start-Sleep 2 ; [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("^l")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("chrome://extensions/")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("$Deposit")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("%{F4}") ; Start-Sleep 2
                Start-Sleep 8 ; $Process = Start-Process "$Starter" "--lang=en --start-maximized" -PassThru
                While ($Process.MainWindowHandle -Eq 0) { Start-Sleep -Milliseconds 500; $Process.Refresh() }
                Start-Sleep 2 ; [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("^l")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("chrome://extensions/")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{TAB}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("%{F4}") ; Start-Sleep 2
            }
            Else {
                Start-Sleep 2 ; $Process = Start-Process "$Starter" "--lang=en --start-maximized" -PassThru
                While ($Process.MainWindowHandle -Eq 0) { Start-Sleep -Milliseconds 500; $Process.Refresh() }
                Start-Sleep 2 ; [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("^l")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("$Package")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 8 ; [Windows.Forms.SendKeys]::SendWait("{DOWN}")
                Start-Sleep 8 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("%{F4}") ; Start-Sleep 2
            }
        }
    }

}

Function Update-EpicGamesLauncher {

    $Current = Get-FileVersion "${Env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
    $Address = "https://raw.githubusercontent.com/Calinou/scoop-games/refs/heads/master/bucket/epic-games-launcher.json"
    $Version = [Regex]::Match((Invoke-WebRequest "$Address" | ConvertFrom-Json).version , "[\d.]+").Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Address = "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-${Version}.msi#/setup.msi_"
        $Fetched = Join-Path "$([IO.Path]::GetTempPath())" "setup.msi"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "msiexec" "/i `"$Using:Fetched`" /qn" -Wait }
    }
    
    Use-RemoveDesktop -Pattern "Epic Games Launcher*.lnk"

}

Function Update-Jdownloader {

    Param (
        [String] $Deposit = "$Env:UserProfile\Downloads\JD2"
    )

    $Starter = "$Env:ProgramFiles\JDownloader\JDownloader2.exe"
    $Present = Test-Path "$Starter"

    If (-Not $Present) {
        $Address = "http://installer.jdownloader.org/clean/JD2SilentSetup_x64.exe"
        $Fetched = Join-Path "$([IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "$Using:Fetched" "-q" -Wait }
    }

    If (-Not $Present) {
        New-Item "$Deposit" -ItemType Directory -EA SI
        $AppData = "$Env:ProgramFiles\JDownloader\cfg"
        $Config1 = "$AppData\org.jdownloader.settings.GeneralSettings.json"
        $Config2 = "$AppData\org.jdownloader.settings.GraphicalUserInterfaceSettings.json"
        $Config3 = "$AppData\org.jdownloader.extensions.extraction.ExtractionExtension.json"
        Start-Process "$Starter" ; While (-Not (Test-Path "$Config1")) { Start-Sleep 2 }
        Stop-Process -Name "JDownloader2" -EA SI ; Start-Sleep 2
        $Configs = Get-Content "$Config1" | ConvertFrom-Json
        Try { $Configs.defaultdownloadfolder = "$Deposit" } Catch { $Configs | Add-Member -Type NoteProperty -Name "defaultdownloadfolder" -Value "$Deposit" }
        Invoke-Gsudo { $Using:Configs | ConvertTo-Json | Set-Content "$Using:Config1" }
        $Configs = Get-Content "$Config2" | ConvertFrom-Json
        Try { $Configs.bannerenabled = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "bannerenabled" -Value $False }
        Try { $Configs.clipboardmonitored = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "clipboardmonitored" -Value $False }
        Try { $Configs.donatebuttonlatestautochange = 4102444800000 } Catch { $Configs | Add-Member -Type NoteProperty -Name "donatebuttonlatestautochange" -Value 4102444800000 }
        Try { $Configs.donatebuttonstate = "AUTO_HIDDEN" } Catch { $Configs | Add-Member -Type NoteProperty -Name "donatebuttonstate" -Value "AUTO_HIDDEN" }
        Try { $Configs.myjdownloaderviewvisible = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "myjdownloaderviewvisible" -Value $False }
        Try { $Configs.premiumalertetacolumnenabled = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "premiumalertetacolumnenabled" -Value $False }
        Try { $Configs.premiumalertspeedcolumnenabled = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "premiumalertspeedcolumnenabled" -Value $False }
        Try { $Configs.premiumalerttaskcolumnenabled = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "premiumalerttaskcolumnenabled" -Value $False }
        Try { $Configs.specialdealoboomdialogvisibleonstartup = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "specialdealoboomdialogvisibleonstartup" -Value $False }
        Try { $Configs.specialdealsenabled = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "specialdealsenabled" -Value $False }
        Try { $Configs.speedmetervisible = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "speedmetervisible" -Value $False }
        Invoke-Gsudo { $Using:Configs | ConvertTo-Json | Set-Content "$Using:Config2" }
        $Configs = Get-Content "$Config3" | ConvertFrom-Json
        Try { $Configs.enabled = $False } Catch { $Configs | Add-Member -Type NoteProperty -Name "enabled" -Value $False }
        Invoke-Gsudo { $Using:Configs | ConvertTo-Json | Set-Content "$Using:Config3" }
    }

    Use-RemoveDesktop -Pattern "JDownloader*.lnk"

}

Function Update-Nvidia {

    If ((Get-WmiObject Win32_VideoController).Name -NotLike "*NVIDIA*") { Return $False }

    $Current = Get-FileVersion "*nvidia*graphics*driver*"
    $Address = "https://raw.githubusercontent.com/ScoopInstaller/Nonportable/HEAD/bucket/nvidia-display-driver-dch-np.json"
    $Version = [Regex]::Match((Invoke-WebRequest "$Address" | ConvertFrom-Json).version, "[\d.]+").Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Address = "https://us.download.nvidia.com/Windows/$Version/$Version-desktop-win10-win11-64bit-international-dch-whql.exe"
        $Fetched = Join-Path "$([IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        $Extract = Use-ExpandArchive "$Fetched"
        Invoke-Gsudo { Start-Process "$Using:Extract\setup.exe" "Display.Driver HDAudio.Driver -clean -s -noreboot" -Wait }
    }

}

Function Update-Qbittorrent {

    Param (
        [String] $Deposit = "$Env:UserProfile\Downloads\P2P",
        [String] $Loading = "$Env:UserProfile\Downloads\P2P\Incompleted"
    )

    $Starter = "$Env:ProgramFiles\qBittorrent\qbittorrent.exe"
    $Current = Get-FileVersion "$Starter"
    $Address = "https://www.qbittorrent.org/download.php"
    $Version = [Regex]::Matches((Invoke-WebRequest "$Address"), "Latest:\s+v([\d.]+)").Groups[1].Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Address = "https://downloads.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-$Version/qbittorrent_${Version}_x64_setup.exe"
        $Fetched = Join-Path "$([IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "$Using:Fetched" "/S" -Wait }
    }

    $Configs = "$Env:AppData\qBittorrent\qBittorrent.ini"
    New-Item "$Deposit" -ItemType Directory -EA SI
    New-Item "$Loading" -ItemType Directory -EA SI
    New-Item "$(Split-Path "$Configs")" -ItemType Directory -EA SI
    Set-Content -Path "$Configs" -Value "[LegalNotice]"
    Add-Content -Path "$Configs" -Value "Accepted=true"
    Add-Content -Path "$Configs" -Value "[Preferences]"
    Add-Content -Path "$Configs" -Value "Bittorrent\MaxRatio=0"
    Add-Content -Path "$Configs" -Value "Downloads\SavePath=$($Deposit.Replace("\", "/"))"
    Add-Content -Path "$Configs" -Value "Downloads\TempPath=$($Loading.Replace("\", "/"))"
    Add-Content -Path "$Configs" -Value "Downloads\TempPathEnabled=true"

}

Function Update-Steam {

    $Current = Get-FileVersion "Steam*"
    $Address = "https://community.chocolatey.org/packages/steam"
    $Version = [Regex]::Matches((Invoke-WebRequest "$Address"), "Steam ([\d.]+)</title>").Groups[1].Value
    $Updated = [Version] "$Current" -Ge [Version] "$Version"

    If (-Not $Updated) {
        $Address = "http://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
        $Fetched = Join-Path "$([IO.Path]::GetTempPath())" "$(Split-Path "$Address" -Leaf)"
        (New-Object Net.WebClient).DownloadFile("$Address", "$Fetched")
        Invoke-Gsudo { Start-Process "$Using:Fetched" "/S" -Wait }
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Steam" -EA SI
    }

    Use-RemoveDesktop -Pattern "Steam*.lnk"

}

Function Update-System {

    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
    $RegName = "SearchOrderConfig"
    Invoke-Gsudo { Set-ItemProperty -Path "$Using:RegPath" -Name "$Using:RegName" -Value 0 }
    Update-Amd ; Update-Nvidia
    Invoke-Gsudo { Set-ItemProperty -Path "$Using:RegPath" -Name "$Using:RegName" -Value 1 }

    Use-ActiveWindows
    Set-AudioVolume -Payload 40

}

Function Update-Xmouser {

    If (-Not (Get-AppxPackage | Where-Object { $_.Name -Like "*WindowsStore*" })) { Return }

    $Content += 'using System;'
    $Content += 'using System.Runtime.InteropServices;'
    $Content += 'public class Keyboard {'
    $Content += '    [DllImport("user32.dll", SetLastError = true)]'
    $Content += '    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);'
    $Content += '    public const int KEYEVENTF_EXTENDEDKEY = 0x0001;'
    $Content += '    public const int KEYEVENTF_KEYUP = 0x0002;'
    $Content += '    public static void KeyDown(byte keyCode) {'
    $Content += '        keybd_event(keyCode, 0, KEYEVENTF_EXTENDEDKEY, UIntPtr.Zero);'
    $Content += '    }'
    $Content += '    public static void KeyUp(byte keyCode) {'
    $Content += '        keybd_event(keyCode, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, UIntPtr.Zero);'
    $Content += '    }'
    $Content += '}'
    Try { Add-Type -TypeDefinition $Content -EA SI } Catch {}
    Add-Type -AssemblyName System.Windows.Forms

    $Present = $Null -Ne (Get-AppxPackage | Where-Object { $_.Name -Like "*XboxMouse*" })
    $Deposit = "$Env:LocalAppData\Packages\Xmouser"
    If (-Not (Test-Path -Path "$Deposit")) { New-Item -ItemType Directory -Path "$Deposit" }
    Set-DeveloperMode -Enabled $True
    $Address = "https://apps.microsoft.com/detail/9n826ps2qqpf"
    $Archive = Get-FromMicrosoftStore -Payload "$Address"
    $Extract = Use-ExpandArchive -Archive "$Archive" -Deposit "$Deposit"
    Remove-Item -Path (Join-Path "$Extract" "AppxSignature.p7x") -EA SI
    $XmlFile = (Join-Path $Deposit "AppxManifest.xml").Replace("'", "''")
    $Command = "Add-AppxPackage -Register '$XmlFile'"
    Start-Sleep -Seconds 5 ; Start-Process powershell -ArgumentList "-NoProfile -WindowStyle Hidden -Command `$ErrorActionPreference='Stop'; $Command" -WindowStyle Hidden -Wait
    Start-Sleep -Seconds 5 ; Set-DeveloperMode -Enabled $False

    If (-Not $Present) {
        Start-Sleep 5 ; Start-Process "Shell:AppsFolder\$(Get-StartApps "Xmouser" | Select-Object -ExpandProperty AppId)"
        Start-Sleep 8 ; Get-Process -Name msedge | ForEach-Object { $_.Kill() } 
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ESC}")
        Start-Sleep 5 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
    }

    If (-Not $Present) {
        Start-Sleep 2 ; [Keyboard]::KeyDown(0x5B) ; [Keyboard]::KeyDown(0x42) ; [Keyboard]::KeyUp(0x42) ; [Keyboard]::KeyUp(0x5B)
        Start-Sleep 2 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 2 ; [Windows.Forms.SendKeys]::SendWait("{LEFT 3}")
        Start-Sleep 2 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 2 ; [Windows.Forms.SendKeys]::SendWait("{UP 6}")
        Start-Sleep 2 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep 2 ; [Keyboard]::KeyDown(0x5B) ; [Keyboard]::KeyDown(0x42) ; [Keyboard]::KeyUp(0x42) ; [Keyboard]::KeyUp(0x5B)
        Start-Sleep 2 ; [Windows.Forms.SendKeys]::SendWait("{ENTER}")
    }

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

    $Country = "Romance Standard Time"
    $Machine = "GAMHOGEN"
    $Members = @(
        { Update-System },
        { Update-Chromium },
        { Update-EpicGamesLauncher },
        { Update-Jdownloader },
        { Update-Qbittorrent },
        { Update-Steam },
        { Update-Xmouser },
        { Update-Appearance }
    )

    Use-UpdateWrapper `
        -Heading $Heading `
        -Country $Country `
        -Machine $Machine `
        -Members $Members

}