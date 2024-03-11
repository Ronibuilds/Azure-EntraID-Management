<#
.SYNOPSIS
Checks and renews application registration secrets that are expiring soon.

.DESCRIPTION
This function iterates through all application registrations matching a specified display name,
checks if any of their secrets are expiring within the next 30 days, and renews the secret if necessary.
It creates a new secret for applications with expiring secrets and skips those without.

.PARAMETER DisplayName
The display name of the application registration to check secrets for. This parameter is mandatory.

.EXAMPLE
Get-ITaaSApplicationRegistrationSecrets -DisplayName "Telindus CMaaS Service"

Checks and renews secrets for the "Telindus CMaaS Service" application registration.

.NOTES
Author: Roni Alarashye
#>
function Get-ITaaSApplicationRegistrationSecrets {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$DisplayName
  )

  try {
    $appRegistrations = Get-AzADApplication -DisplayName $DisplayName
    foreach ($app in $appRegistrations) {
      $appCredentials = Get-AzADAppCredential -ObjectId $app.Id
      $expiringCredentials = $appCredentials | Where-Object { $_.EndDateTime -lt (Get-Date).AddDays(30) }

      if ($expiringCredentials.Count -gt 0) {
        Write-Host "App Registration ID: $($app.AppId), Name: $($app.DisplayName), has secret(s) expiring within 30 days. A new secret will be created."
        New-ITaaSApplicationRegistrationSecret
      }
    }
  }
  catch {
    Write-Error "An error occurred: $_"
  }
}