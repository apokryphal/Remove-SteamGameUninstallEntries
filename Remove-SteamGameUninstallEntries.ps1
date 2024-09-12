# Remove-SteamGameUninstallEntries
# Run as admin
#Requires -Modules PSFramework

$log_path = $PSScriptRoot + '\steam_games_cleanup.log'

$paramSetPSFLoggingProvider = @{
	Name			= 'logfile'
	InstanceName	= 'steam_games_cleanup'
	FilePath		= $log_path
	Enabled			= $true
	Wait			= $true
}

Set-PSFLoggingProvider @paramSetPSFLoggingProvider

Write-PSFMessage 'Starting Script'

ForEach ($search_key in (
	'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
	'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
)) {
	Get-ChildItem -Path $search_key | ForEach-Object {
		# Name property is pseudo-fully qualified, isolate the key-specific name
		$key_name = $_.Name.split('\')[-1]
		if ( $key_name -match '^Steam App .+$' ) {
			$display_name = $_.GetValue('DisplayName')
			# The path from Name isn't directly usable because it replaces the registry hive reference.
			# 'HKLM:\' becomes 'HKEY_LOCAL_MACHINE\'
			# Generate a usable path
			$usable_path = $search_key + '\' + $key_name
			Write-PSFMessage "Found:`t$display_name"
			Write-PSFMessage "Path:`t$usable_path"
			# Delete the key
			Remove-Item -Path $usable_path -Recurse
			if ((Test-Path $usable_path) -eq $False) {
				Write-PSFMessage "Removed"
			}
		}
	}
}

Write-PSFMessage 'Script Completed'
Wait-PSFMessage
