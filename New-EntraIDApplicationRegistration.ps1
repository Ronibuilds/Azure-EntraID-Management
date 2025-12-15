<#
.SYNOPSIS
Creates a new Entra ID application registration.

.DESCRIPTION
This function creates a new Entra ID application registration with the specified display name and tenant type.
It automatically generates a service principal for the application registration and outputs the application
registration details, including the display name and application (client) ID.

.PARAMETER DisplayName
The display name for the new application registration. Default is "Azure Management Service".

.PARAMETER TenantType
The type of tenant for the application registration. Default is "AzureADMyOrg", indicating a single-tenant application.

.EXAMPLE
New-EntraIDApplicationRegistration -DisplayName "Azure Management Service" -TenantType "AzureADMyOrg"
Creates a new single-tenant application registration in Entra ID with the display name "Azure Management Service".

.EXAMPLE
New-EntraIDApplicationRegistration -DisplayName "My Organization Service" -TenantType "AzureADMultipleOrgs"
Creates a new multi-tenant application registration that can be accessed by users from any Entra ID tenant, with the display name "My Organization Service".

.EXAMPLE
New-EntraIDApplicationRegistration -DisplayName "Custom Application Name" -TenantType "AzureADandPersonalMicrosoftAccount"
Creates a new application registration that supports accounts in any organizational directory and personal Microsoft accounts (e.g., Skype, Xbox), with the display name "Custom Application Name".


.NOTES
Author: Roni Alarashye
#>
function New-EntraIDApplicationRegistration {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [string]$DisplayName = "Azure Management Service",
    [Parameter(Mandatory = $false)]
    [string]$TenantType = "AzureADMyOrg"
  )

  try {
    $appRegistration = New-AzADApplication -DisplayName $DisplayName -SignInAudience $TenantType -ErrorAction Stop
    Write-Host "App Registration & Service Principal Name: $($appRegistration.DisplayName)"
    Write-Host "App Registration ID (Client ID): $($appRegistration.AppId), App Registration Object ID: $($appRegistration.Id)"

    # Create a service principal for the app registration
    Write-Host "Preparing to create service principal for app registration..."
    $servicePrincipal = New-AzADServicePrincipal -ApplicationId $appRegistration.AppId -ErrorAction Stop

    return $appRegistration
  }
  catch {
    Write-Error "An error occurred while creating the Entra ID application registration: $_"
  }
}