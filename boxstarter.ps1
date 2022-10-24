 # Description: Boxstarter Script
# Author: CarlosEDP
#
# First set: Set-ExecutionPolicy RemoteSigned
#
# Install boxstarter:
# 	. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?https://github.com/carlosedp/dotfiles/raw/master/boxstarter.ps1
# OR
# 	Install-BoxstarterPackage -PackageName https://github.com/carlosedp/dotfiles/raw/master/boxstarter.ps1 -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

#---- TEMPORARY ---
Disable-UAC

#--- Configuring Windows properties ---
#--- Windows Features ---
# Show hidden files, Show protected OS files, Show file extensions
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

#--- File Explorer Settings ---
# will expand explorer to the actual folder you're in
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
#adds things back in your left pane like recycle bin
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
#opens PC to This PC, not quick access
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
#taskbar where window is open for multi-monitor
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1


$ChocoInstalls = @(
    '7zip',
    'discord',
    'Firefox',
    'googlechrome',
    'whatsapp',
    'powertoys',
    'sysinternals',
    'cpu-z.install',
    'gpu-z',
    '1password',
    'procexp',
    'poshgit',
    'curl',
    'docker-desktop',
    'f.lux',
    'firacode',
    'foxitreader',
    'git',
    'git-credential-manager-for-windows',
    'git-credential-winstore',
    'gitextensions',
    'microsoft-windows-terminal',
    'powershell'
    'powershellhere',
    'putty',
    'virtualbox',
    'VirtualBox.ExtensionPack',
    'vlc',
    'vscode'
    'nerd-fonts-3270'
)


if ($ChocoInstalls.Count -gt 0) {
    # Install a ton of other crap I use or like, update $ChocoInsalls to suit your needs of course
    $ChocoInstalls | Foreach-Object {
        try {
            choco upgrade -y $_
        }
        catch {
            Write-Warning "Unable to install software package with Chocolatey: $($_)"
        }
    }
}
else {
    Write-Output 'There were no packages to install!'
}

# you don't need Fax & Scan, XPS formats, XPS printing services, or printing to http printers.
Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName Printing-Foundation-InternetPrinting-Client -NoRestart

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

#optimize the startup cache...i think. on SSD i don't think it really matters.
set-service SysMain -StartupType Automatic

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

#--- Windows Subsystems/Features ---

# these are also available for scripting directly on windows and installing natively via Enable-WindowsOptionalFeature.
# if you wanna know what's available, try this:
# Get-WindowsOptionalFeature  -Online | sort @{Expression = "State"; Descending = $True}, @{Expression = "FeatureName"; Descending = $False}| Format-Table -GroupBy State

Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
choco install Microsoft-Hyper-V-All -source WindowsFeatures -y
choco install Microsoft-Windows-Subsystem-Linux -source WindowsFeatures -y

RefreshEnv

#--- Ubuntu ---
# TODO: Move this to choco install once --root is included in that package
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-2004 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

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
	"Microsoft.Print3D"
	"*Autodesk*"
	"*BubbleWitch*"
    "king.com*"
    "G5*"
	"*Dell*"
	"*Facebook*"
	"*Keeper*"
	"*Netflix*"
	"*Twitter*"
	"*Plex*"
	"*.Duolingo-LearnLanguagesforFree"
	"*.EclipseManager"
	"ActiproSoftwareLLC.562882FEEB491" # Code Writer
	"*.AdobePhotoshopExpress"
)

foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

    Get-AppXProvisionedPackage -Online |
        Where-Object DisplayName -EQ $app |
        Remove-AppxProvisionedPackage -Online -AllUsers
}

#--- Rename the Computer ---
# Requires restart, or add the -Restart flag

$computername = "CarlosEDP-Win"

if ($env:computername -ne $computername) {
	Write-BoxstarterMessage "Renaming Computer to:  $computername "
	Rename-Computer -NewName $computername
}


# Update Windows and reboot if necessary
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }
