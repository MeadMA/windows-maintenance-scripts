#Requires -RunAsAdministrator

<#
.SYNOPSIS
Provides options to speed up Windows 10.

.DESCRIPTION
Executes various actions to speed up Windows 10.  The -All switch will execute
all actions, but you should carefully review the full documentation before
using this.

.PARAMETER All
Executes all actions/switches for this script.  Carefully read the other
parameters before using this.

.PARAMETER DisableCortana
Disables Cortana.  Effective machine-wide.

.PARAMETER DisableCortanaWebSearch
Prevents Cortana from searching the web when searching on the Start Menu.
Effective machine-wide.

.PARAMETER DisableBackgroundApps
Prevents Windows Store apps from running in the background.  Effective
machine-wide.

.PARAMETER DisableVisualEffects
Disables all Visual Effects.  Effective only for the current user.  Run
SystemPropertiesPerformance.exe to enable specific, individual effects.

.LINK
https://www.gnu.org/licenses/
#>

# win10-speed: Improves the speed of Windows 10
# Copyright (C) 2020  Michael A. Mead
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Program starts below here.

# Switches
[cmdletbinding()]
param(
	[Switch]$All,
	[Switch]$DisableCortana,
	[Switch]$DisableCortanaWebSearch,
	[Switch]$DisableVisualEffects
)

# Checks if Registry key exists, and creates it if not
Function VerifyRegKey {
	param(
		[String]$KeyPath
	)

	If (!(Test-Path($KeyPath))) {
		Write-Verbose "$KeyPath does not exist.  Creating it."
		New-Item $KeyPath | Out-Null
	}
}

# Sets a Registry value
Function SetRegValue {
	param(
		[String]$KeyPath,
		[String]$ValueName,
		[String]$ValueData,
		[String]$ValueType
	)

	VerifyRegKey($KeyPath)
	Write-Verbose "Adding Registry value: Key $KeyPath, Name $ValueName, Type $ValueType, Data $ValueData"
	New-ItemProperty $KeyPath -Name $ValueName -Value $ValueData -PropertyType $ValueType -Force | Out-Null
}

Function DisableCortana {
	$SearchKey = "HKLM:SOFTWARE\Policies\Microsoft\Windows\Windows Search"
	SetRegValue -KeyPath $SearchKey -ValueName "AllowCortana" -ValueData "0" -ValueType "DWORD"
}

Function DisableCortanaWebSearch {
	$SearchKey = "HKLM:SOFTWARE\Policies\Microsoft\Windows\Windows Search"
	SetRegValue -KeyPath $SearchKey -ValueName "ConnectedSearchUseWeb" -ValueData "0" -ValueType "DWORD"
	SetRegValue -KeyPath $SearchKey -ValueName "DisableWebSearch" -ValueData "1" -ValueType "DWORD"
}

Function DisableBackgroundApps {
	$AppKey = "HKLM:SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
	SetRegValue -KeyPath $AppKey -ValueName "LetAppsRunInBackground" -ValueData "2" -ValueType "DWORD"
}

Function DisableVisualEffects {
	$AppKey = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
	SetRegValue -KeyPath $AppKey -ValueName "VisualFXSetting" -ValueData "2" -ValueType "DWORD"
}

# Main program

If ($DisableCortana -Or $All) {
	Write-Output "Executing DisableCortana action"
	DisableCortana
}

If ($DisableCortanaWebSearch -Or $All) {
	Write-Output "Executing DisableCortanaWebSearch action"
	DisableCortanaWebSearch
}

If ($DisableBackgroundApps -Or $All) {
	Write-Output "Executing DisableBackgroundApps action"
	DisableBackgroundApps
}
