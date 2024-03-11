<#
.SYNOPSIS
Creates a new secret for an Entra ID application registration.

.DESCRIPTION
This function generates a new secret for a specified Entra ID application registration. 
It assigns a unique identifier to the secret and sets the expiration date to 6 months from the creation date.

.PARAMETER AppId
The Application ID of the Entra ID application for which to create a new secret.

.EXAMPLE
New-ITaaSApplicationRegistrationSecret -AppId "your-application-id"

Creates a new secret for the specified Entra ID application.

.NOTES
Author: Roni Alarashye
#>
function New-ITaaSApplicationRegistrationSecret {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [string]$AppId = $AppRegistration.AppId
  )

  try {
    $StartDate = [System.DateTime]::Now
    $EndDate = $StartDate.AddMonths(6)
    $CustomKeyId = "CMaaS-$($StartDate.Date.ToString("yyyyMMdd"))"
    $CustomKeyIdBytes = [System.Text.Encoding]::Unicode.GetBytes($CustomKeyId)
    $CustomKeyIdBase64 = [Convert]::ToBase64String($CustomKeyIdBytes)

    # Create the secret
    $AppSecret = New-AzADAppCredential -ApplicationId $AppId -StartDate $StartDate -EndDate $EndDate -CustomKeyIdentifier $CustomKeyIdBase64
    Write-Output "Secret ID: $($AppSecret.KeyId), Secret Value: $($AppSecret.SecretText)"
  }
  catch {
    Write-Error "Failed to create a new application secret for AppId: ${AppId}: $_"
  }
}