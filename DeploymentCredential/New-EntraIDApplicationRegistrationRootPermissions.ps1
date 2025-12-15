<#
.SYNOPSIS
Assigns ownership permissions at the tenant root level to an Entra ID application registration.

.DESCRIPTION
This function assigns the 'Owner' role at the tenant root level to the service principal of the specified Entra ID application registration.

.PARAMETER AppId
The Application ID of the Entra ID application registration for which to assign the 'Owner' role at the tenant root level.

.EXAMPLE
New-EntraIDApplicationRegistrationRootPermissions -AppId "your-application-id"

Assigns the 'Owner' role at the tenant root level to the service principal of the specified application.

.NOTES
Author: Roni Alarashye
#>
function New-EntraIDApplicationRegistrationRootPermissions {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [string]$AppId = $AppRegistration.AppId
  )

  try {
    $RootPermissions = New-AzRoleAssignment -RoleDefinitionName "Owner" -Scope "/" -ApplicationId $AppId -ErrorAction Stop
    Write-Host "Assigned 'Owner' role at tenant root level to application with ID: $AppId"
  }
  catch {
    Write-Error "Failed to assign 'Owner' role at tenant root level: $_"
  }
}