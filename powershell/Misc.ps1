#requires -Version 2.0 -Modules PowerShellGet
function Remove-OldModules
{
  $Latest = Get-InstalledModule
  foreach ($module in $Latest) {

    Write-Verbose -Message "Uninstalling old versions of $($module.Name) [latest is $( $module.Version)]" -Verbose
    Get-InstalledModule -Name $module.Name -AllVersions | Where-Object {$_.Version -ne $module.Version} | Uninstall-Module -Verbose
  }
}