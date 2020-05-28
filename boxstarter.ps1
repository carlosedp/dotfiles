 # Description: Boxstarter Script
# Author: CarlosEDP
#
# Install boxstarter:
# 	. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
#
# You might need to set: Set-ExecutionPolicy RemoteSigned
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?https://github.com/carlosedp/dotfiles/raw/master/boxstarter.ps1
# OR
# 	Install-BoxstarterPackage -PackageName https://github.com/carlosedp/dotfiles/raw/master/boxstarter.ps1 -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher


#---- TEMPORARY ---
Disable-UAC

# Disable Windows Defender
Write-Host "Disabling Windows Defender..."
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
Set-MpPreference -DisableRealtimeMonitoring $true

#---- PERMANENT ---
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

# don't need work folders if u got OneDrive for Business.
Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart
# don't need remote differential compression if you never intend to pull from network shares...
Disable-WindowsOptionalFeature -Online -FeatureName MSRDC-Infrastructure -NoRestart

# you don't need Fax & Scan, XPS formats, XPS printing services, or printing to http printers.
Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName Printing-Foundation-InternetPrinting-Client -NoRestart

# you don't need media playback.
Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName MediaPlayback -NoRestart

# you are not pulling from shares, you should not expose shares...die LAN Man! with my last breath I will curse thee
Set-service -Name LanmanServer -StartupType Disabled
#print spooler: Dead
Set-service -Name Spooler -StartupType Disabled
# Tablet input: pssh nobody use tablet input. its silly.just write right in onenote
Set-service -Name TabletInputService -StartupType Disabled
# Telephony API is tell-a-phony
Set-service -Name TapiSrv -StartupType Disabled
#geolocation service : u can't find me.
# Set-service -Name lfsvc -StartupType Disabled

# ain't no homegroup here.
Set-service -Name HomeGroupProvider -StartupType Disabled
# u do not want ur smartcard cert to propagate to the local cache, do you?
Set-service -Name CertPropsvc -StartupType Disabled
# who needs branchcache?
Set-service -Name PeerDistSvc -StartupType Disabled
# i don't need to keep links from NTFS file shares across the network - i haz office.
Set-service -Name TrkWks -StartupType Disabled
# i don't use iscsi
Set-service -Name MSISCSI -StartupType Disabled
# why is SNMPTRAP still on windows 10? i mean, really, who uses SNMP? is it even a real protocol anymore?
Set-service -Name SNMPTRAP -StartupType Disabled

# Peer to Peer discovery svcs...Begone!
Set-service -Name PNRPAutoReg -StartupType Disabled
Set-service -Name p2pimsvc -StartupType Disabled
Set-service -Name p2psvc -StartupType Disabled
Set-service -Name PNRPsvc -StartupType Disabled
# no netbios over tcp/ip. unnecessary.
Set-service -Name lmhosts -StartupType Disabled

# this is like plug & play only for network devices. no thx. k bye.
Set-service -Name SSDPSRV -StartupType Disabled
# YOU DO NOT NEED TO PUBLISH FROM THIS DEVICE. Discovery Resource Publication service:
Set-service -Name FDResPub -StartupType Disabled
#"Function Discovery host provides a uniform programmatic interface for enumerating system resources" - NO THX.
Set-service -Name fdPHost -StartupType Disabled

#intel Proset wireless registry thing. curse thee:
Set-service -Name RegSrvc -StartupType Disabled

#optimize the startup cache...i think. on SSD i don't think it really matters.
set-service SysMain -StartupType Automatic


#---LIBRARIES---
#come on, you know you like em, you use em all the time. might as well make sure they come back each and every time, right?
# this assumes you set up onedrive.
#Move-LibraryDirectory -libraryName "Personal" -newPath $ENV:OneDrive\Documents
#Move-LibraryDirectory -libraryName "My Pictures" -newPath $ENV:OneDrive\Pictures
#Move-LibraryDirectory -libraryName "My Video" -newPath $ENV:OneDrive\Videos
#Move-LibraryDirectory -libraryName "My Music" -newPath $ENV:OneDrive\Music

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions
Set-TaskbarOptions -Size Large -Dock Bottom -Combine Full -AlwaysShowIconsOn

#--- Windows Subsystems/Features ---

# these are also available for scripting directly on windows and installing natively via Enable-WindowsOptionalFeature.
# if you wanna know what's available, try this:
# Get-WindowsOptionalFeature  -Online | sort @{Expression = "State"; Descending = $True}, @{Expression = "FeatureName"; Descending = $False}| Format-Table -GroupBy State

choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures
choco install Microsoft-Hyper-V-All -source windowsFeatures

# Install Debian WSL
Invoke-WebRequest -Uri https://aka.ms/wsl-debian-gnulinux -OutFile ~/Debian.appx -UseBasicParsing
Add-AppxPackage -Path ~/Debian.appx

# Chocolatey packages to install

$ChocoInstalls = @(
    '7zip',
    '7zip.commandline',
    'cmder',
    'curl',
    'docker-desktop',
    'f.lux',
    'firacode',
    'Firefox',
    'foxitreader',
    'git',
    'git-credential-manager-for-windows',
    'git-credential-winstore',
    'gitextensions',
    'sysinternals'
    'hyper',
    'hub',
    'jre8',
    'microsoft-windows-terminal',
    'procexp',
    'powershell'
    'powershellhere',
    'putty',
    'virtualbox',
    'VirtualBox.ExtensionPack',
    'vlc',
    'visualstudiocode'
    'google-backup-and-sync',
    'joplin'
)

# Don't try to download and install a package if it shows already installed
# $InstalledChocoPackages = (Get-ChocoPackages).Name
# $ChocoInstalls = $ChocoInstalls | Where { $InstalledChocoPackages -notcontains $_ }

if ($ChocoInstalls.Count -gt 0) {
    # Install a ton of other crap I use or like, update $ChocoInsalls to suit your needs of course
    $ChocoInstalls | Foreach-Object {
        try {
            choco upgrade -y $_ --cacheLocation "$($env:userprofile)\AppData\Local\Temp\chocolatey"
        }
        catch {
            Write-Warning "Unable to install software package with Chocolatey: $($_)"
        }
    }
}
else {
    Write-Output 'There were no packages to install!'
}

# Visual Studio Code extensions to install (both code-insiders and code if available)
$VSCodeExtensions = @(
    'shan.code-settings-sync'
)

# Visual Studio Code extension setup
if ($null -ne (get-command 'code' -ErrorAction:SilentlyContinue)) {
    Write-Host "Installing $($VSCodeExtensions.count) extensions to VS Code"
    $VSCodeExtensions | ForEach-Object {
        code --install-extension $_
    }
}

#--- Uninstall unecessary applications that come with Windows out of the box ---
Write-BoxstarterMessage "*** Store Apps Cleanup ***"

$apps = @(
    # default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingWeather"
    #"Microsoft.FreshPaint"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "microsoft.windowscommunicationsapps"
#    "Microsoft.MinecraftUWP"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.NetworkSpeedTest"

    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.WindowsFeedbackHub"

    #Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingTravel"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.WindowsReadingList"

    # non-Microsoft
    "9E2F88E3.Twitter"
    "PandoraMediaInc.29680B314EFC2"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "Drawboard.DrawboardPDF"
    "2FE3CB00.PicsArt-PhotoStudio"
    "D52A8D61.FarmVille2CountryEscape"
    "TuneIn.TuneInRadio"
    "GAMELOFTSA.Asphalt8Airborne"
    #"TheNewYorkTimes.NYTCrossword"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Facebook.Facebook"
    "flaregamesGmbH.RoyalRevolt2"
    "Playtika.CaesarsSlotsFreeCasino"
    "A278AB0D.MarchofEmpires"
    "KeeperSecurityInc.Keeper"
    "ThumbmunkeysLtd.PhototasticCollage"
    "XINGAG.XING"
    "89006A2E.AutodeskSketchBook"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "46928bounde.EclipseManager"
    "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
    "CAF9E577.Plex"

    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.BioEnrollment"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.Cortana"
    #"Microsoft.WindowsFeedback"
    #"Microsoft.XboxGameCallableUI"
     #"Microsoft.XboxIdentityProvider"
    #"Windows.ContactSupport"
)

foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

    Get-AppXProvisionedPackage -Online |
        Where-Object DisplayName -EQ $app |
        Remove-AppxProvisionedPackage -Online -AllUsers
}

#---- Windows Settings ----
# Some from: @NickCraver's gist https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9

# Privacy: Let apps use my advertising ID: Disable
If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
}
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

# WiFi Sense: HotSpot Sharing: Disable
If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
}
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

# WiFi Sense: Shared HotSpot Auto-Connect: Disable
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

# Start Menu: Disable Bing Search Results
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0
# To Restore (Enabled):
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 1

# Disable Telemetry (requires a reboot to take effect)
# Note this may break Insider builds for your organization; and prevent us from stopping bad guys from pwning you. dont do this.
# Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
# Get-Service DiagTrack,Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

#file explorer preferences...
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 1
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 1

# Lock screen (not sleep) on lid close
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 1
# To Restore:
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 0

#--- Restore Temporary Settings ---
Write-BoxstarterMessage "re-Enable UAC"
Enable-UAC

#Write-BoxstarterMessage " Enabling Windows Update"
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

#--- Rename the Computer ---
# Requires restart, or add the -Restart flag

$computername = "CarlosEDP"

if ($env:computername -ne $computername) {
	Write-BoxstarterMessage "Renaming Computer to:  $computername "
	Rename-Computer -NewName $computername
}

# Enable Windows Defender
Write-Host "Enabling Windows Defender..."
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
Set-MpPreference -DisableRealtimeMonitoring $false

# Functions

function Get-ChocoPackages {
    if (get-command clist -ErrorAction:SilentlyContinue) {
        clist -lo -r -all | Foreach {
            $Name,$Version = $_ -split '\|'
            New-Object -TypeName psobject -Property @{
                'Name' = $Name
                'Version' = $Version
            }
        }
    }
}