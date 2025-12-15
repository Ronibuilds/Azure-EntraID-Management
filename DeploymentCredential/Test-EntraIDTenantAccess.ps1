function Test-EntraIDTenantAccess {
  <#
  .SYNOPSIS
  Tests for tenant access by checking application registration, service principal existence, owner permissions, Graph API permissions, secret expiry, and hub subscription access.
  .DESCRIPTION
  The Test-EntraIDTenantAccess function checks an Entra ID application's registration status, verifies the existence of its service principal, and assesses specific permissions and configurations. It supports checking by either the display name or the application ID of the Entra ID application. The function also evaluates the application's Graph API permissions, owner permissions on the root management group, and the expiry of its secrets.
  .PARAMETER DisplayName
  Specifies the display name of the Entra ID application to check. This parameter is mandatory when using the ByDisplayNameSet parameter set.
  .PARAMETER ApplicationId
  Specifies the application ID (also known as the client ID) of the Entra ID application to check. This parameter is mandatory when using the ByAppIdSet parameter set.
  .PARAMETER ExpiresIn
  Specifies the threshold in days to check for expiring secrets. Defaults to 30 days.
  .EXAMPLE
  Test-EntraIDTenantAccess -DisplayName "Azure Management Service"
  Checks the application named "Azure Management Service" for proper configuration and permissions.
  .EXAMPLE
  Test-EntraIDTenantAccess -ApplicationId "e2a0824f-4a16-426a-9bb8-45c878fea52c" -ExpiresIn 60
  Checks the application with the specified ID for proper configuration and permissions, including secrets expiring within 60 days.
  #>
  # To do Cloud App Admin Assignment
  # To do look into checking for API permissions granted admin consent
  # To do add elseif statement in the case NO secrets exist and produce a warning (Test-EntraIDApplicationRegistrationSecret would have to be modified accordingly)
  [CmdletBinding(DefaultParameterSetName = 'ByDisplayNameSet')]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'ByDisplayNameSet')]
    [ValidateNotNullOrEmpty()]
    [string]$DisplayName,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByAppIdSet')]
    [ValidateNotNullOrEmpty()]
    [string]$ApplicationId,
    [Parameter(Mandatory = $false)]
    [int]$ExpiresIn = 30
  )
  $Results = @{}
  $PermissionIds = @{
    'User.Read'                     = 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
    'Application.ReadWrite.OwnedBy' = '18a4783c-866b-4cc7-a460-3d5e5662c884'
  }
  if ($PSCmdlet.ParameterSetName -eq 'ByDisplayNameSet') {
    $Application = Get-AzADApplication -DisplayName $DisplayName
  }
  elseif ($PSCmdlet.ParameterSetName -eq 'ByAppIdSet') {
    $Application = Get-AzADApplication -ApplicationId $ApplicationId
  }
  if (-not $Application) {
    $Results['Application Found'] = $false

    Write-Error 'Application registration not found.'

    return $null
  }
  $Results['Application Found'] = $true
  Write-Verbose "Found application registration: AppId = $($Application.AppId), DisplayName = $($Application.DisplayName)"
  $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $Application.AppId
  if ($ServicePrincipal) {
    $Results['Service Principal Found'] = $true
    Write-Verbose "Found service principal for the application, ObjectId = $($ServicePrincipal.Id)"
  }
  else {
    $Results['Service Principal Found'] = $false
    Write-Verbose 'Service principal not found for the application.'
    return $Results
  }
  $OwnerPermissions = Get-AzRoleAssignment -ObjectId $ServicePrincipal.Id -Scope '/' -RoleDefinitionName 'Owner' -ErrorAction SilentlyContinue

  if ($OwnerPermissions) {
    $Results['Root Management Group Owner Permission Found'] = $true
    Write-Verbose "Owner permissions found on the root management group scope."
  }
  else {
    $Results['Root Management Group Owner Permission Found'] = $false
    Write-Verbose "Owner permissions NOT found on the root management group scope."
  }
  $GraphPermissions = Get-AzADAppPermission -ObjectId $Application.Id
  foreach ($Key in $PermissionIds.Keys) {

    $Value = $PermissionIds[$Key]
    $PermissionFound = $GraphPermissions | Where-Object { $_.Id -eq $Value }
    if ($PermissionFound) {
      $Results["Graph API $($Key) Permission Found"] = $true
      Write-Verbose "Graph API permission '$($Key)' found."
    }
    else {
      $Results["Graph API $($Key) Permission Found"] = $false
      Write-Verbose "Graph API permission '$($Key)' not found."
    }
  }
  
  $SecretExpiryCheck = Test-EntraIDApplicationRegistrationSecret -ApplicationId $Application.AppId -ExpiresIn $ExpiresIn
  if ($SecretExpiryCheck) {
    $Results['Secret Expiring'] = $true
    Write-Verbose "At least one secret is expiring within $ExpiresIn days."
  }
  else {
    $Results['Secret Expiring'] = $false
    Write-Verbose "No secrets are expiring within $ExpiresIn days."
    Write-Warning "No secrets existing could also be the case, check manually!"
  }
  $HubSubscriptionCheck = Get-AzSubscription -SubscriptionId (Get-EntraIDEnvironmentOptions).HubSubscriptionId
  if ($HubSubscriptionCheck) {
    $Results['Subscription Hub Found'] = $true
    Write-Verbose "Subscription hub found."
  }
  else {
    $Results['Subscription Hub Found'] = $false
    Write-Verbose "Subscription hub not found."
  }
  return $Results
}
