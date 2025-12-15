<#
.SYNOPSIS
Deploys an Entra ID Application Registration in Entra ID.

.DESCRIPTION
This function creates an application registration in Entra ID with specified properties,
assigns necessary permissions, and creates a secret for the application. It deploys
an Entra ID Application Registration with a single tenant type, no platforms, User.Read
permission, and Cloud Application Administrator role.

.PARAMETER DisplayName
The display name for the application registration. Default is "Azure Management Service".

.PARAMETER TenantType
The tenant type for the application registration. Default is "AzureADMyOrg".

.PARAMETER GraphPermission
The Graph permission to assign to the application. Default is User.Read permission ID.

.PARAMETER GraphApiId
The Graph API ID. Default is the Microsoft Graph API ID.

.EXAMPLE
Deploy-EntraIDTenantApplicationRegistration

Creates an application registration with default parameters.

.NOTES
Author: Roni Alarashye
#>
function Deploy-EntraIDTenantApplicationRegistration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DisplayName = "Azure Management Service",
        [ValidateSet("AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount")]
        [Parameter(Mandatory = $false)]
        [string]$TenantType = "AzureADMyOrg",
        [Parameter(Mandatory = $false)]
        [string]$GraphPermission = "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
        [Parameter(Mandatory = $false)]
        [string]$GraphApiId = "00000003-0000-0000-c000-000000000000"
    )

    try {
        $AppRegistration = New-EntraIDApplicationRegistration -DisplayName $DisplayName -TenantType $TenantType

        # Invokes the rest of the functions to apply secrets and permissions
        New-EntraIDApplicationRegistrationSecret -AppId $AppRegistration.AppId
        New-EntraIDApplicationRegistrationPermissions -ObjectId $AppRegistration.Id -GraphApiId $GraphApiId -GraphPermission $GraphPermission
        Get-EntraIDApplicationRegistrationSecrets -DisplayName $DisplayName
        New-EntraIDApplicationRegistrationRootPermissions -AppId $AppRegistration.AppId

        Write-Verbose "Deployment completed successfully."
    }
    catch {
        Write-Error "An error occurred during deployment: $_"
    }
}