<#
.SYNOPSIS
Assigns Microsoft Graph permissions to an Entra ID application registration.

.DESCRIPTION
This function assigns the specified Microsoft Graph permission to the given Entra ID application registration.

.PARAMETER AppRegObjectId
The Object ID of the Entra ID application registration to which permissions will be assigned.

.PARAMETER GraphPermission
The Microsoft Graph permission to assign. The default value is the ID for User.Read.

.PARAMETER GraphApiId
The Microsoft Graph API ID. The default value is the fixed API ID for Microsoft Graph.

.EXAMPLE
New-ITaaSApplicationRegistrationPermissions -AppRegObjectId "example-object-id" -GraphPermission "e1fe6dd8-ba31-4d61-89e7-88639da4683d"

Assigns the User.Read permission to the specified application registration.

.NOTES
Author: Roni Alarashye
#>
function New-ITaaSApplicationRegistrationPermissions {
  [CmdletBinding()]
  param (
    [string]$ObjectId,
    [Parameter(Mandatory = $false)]
    [string]$GraphPermission = "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
    [Parameter(Mandatory = $false)]
    [string]$GraphApiId = "00000003-0000-0000-c000-000000000000"
  )

  try {
    $AddGraphPermission = Add-AzADAppPermission -ObjectId $ObjectId -ApiId $GraphApiId -PermissionId $GraphPermission -ErrorAction Stop
    Write-Host "Assigned Graph API permission to application registration with Object ID: $ObjectId"
  }
  catch {
    Write-Error "Failed to assign Graph API permission to application registration: $_"
  }
}

# Get basic overview of azure monthly spent cost in code in EUROS, no function
