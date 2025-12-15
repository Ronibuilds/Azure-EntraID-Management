# Azure Tenant Management - Entra ID Application Registration Tools

A collection of PowerShell functions for managing Azure Entra ID application registrations with automated secret management and permission configuration.

## Overview

This repository provides a set of PowerShell scripts to automate the creation and management of Entra ID application registrations. These tools are designed to simplify the process of deploying service principals with the necessary permissions for Azure tenant management.

## Prerequisites

- PowerShell 5.1 or later
- Azure PowerShell module (`Az` module)
- Appropriate permissions in Azure Entra ID:
  - Application Administrator or Global Administrator role
  - Owner or Contributor role at the tenant root level (for root permissions)

## Installation

1. Clone this repository:
```powershell
git clone https://github.com/Ronibuilds/Azure-Tenant-Mgmt-Identity.git
cd Azure-Tenant-Mgmt-Identity
```

2. Install the Azure PowerShell module if not already installed:
```powershell
Install-Module -Name Az -AllowClobber -Scope CurrentUser
```

3. Connect to your Azure account:
```powershell
Connect-AzAccount
```

## Functions

### Deploy-EntraIDTenantApplicationRegistration

**Purpose**: Complete deployment of an Entra ID application registration with all necessary configurations.

**Description**: Creates an application registration, assigns permissions, creates secrets, and configures root-level access in a single operation.

**Parameters**:
- `DisplayName` (Optional): The display name for the application. Default: `"Azure Management Service"`
- `TenantType` (Optional): The tenant type. Default: `"AzureADMyOrg"`
  - `AzureADMyOrg`: Single-tenant
  - `AzureADMultipleOrgs`: Multi-tenant
  - `AzureADandPersonalMicrosoftAccount`: Multi-tenant with personal accounts
- `GraphPermission` (Optional): Microsoft Graph permission ID. Default: `"e1fe6dd8-ba31-4d61-89e7-88639da4683d"` (User.Read)
- `GraphApiId` (Optional): Microsoft Graph API ID. Default: `"00000003-0000-0000-c000-000000000000"`

**Example**:
```powershell
# Load the function
. .\\Deploy-EntraIDTenantApplicationRegistration.ps1

# Deploy with default settings
Deploy-EntraIDTenantApplicationRegistration

# Deploy with custom display name
Deploy-EntraIDTenantApplicationRegistration -DisplayName "My Organization Service"
```

---

### New-EntraIDApplicationRegistration

**Purpose**: Creates a new Entra ID application registration with a service principal.

**Parameters**:
- `DisplayName` (Optional): The display name. Default: `"Azure Management Service"`
- `TenantType` (Optional): The tenant type. Default: `"AzureADMyOrg"`

**Example**:
```powershell
# Load the function
. .\\New-EntraIDApplicationRegistration.ps1

# Create a single-tenant application
$app = New-EntraIDApplicationRegistration -DisplayName "Azure Management Service"

# Create a multi-tenant application
$app = New-EntraIDApplicationRegistration -DisplayName "My Organization Service" -TenantType "AzureADMultipleOrgs"
```

---

### New-EntraIDApplicationRegistrationSecret

**Purpose**: Creates a new secret for an existing Entra ID application registration.

**Parameters**:
- `AppId` (Optional): The Application ID. Default: `$AppRegistration.AppId`

**Secret Details**:
- Validity: 6 months from creation
- Key Identifier Format: `AppSecret-yyyyMMdd`

**Example**:
```powershell
# Load the function
. .\\New-EntraIDApplicationRegistrationSecret.ps1

# Create a secret for an application
New-EntraIDApplicationRegistrationSecret -AppId "your-application-id"
```

---

### New-EntraIDApplicationRegistrationPermissions

**Purpose**: Assigns Microsoft Graph API permissions to an application registration.

**Parameters**:
- `ObjectId` (Required): The Object ID of the application registration
- `GraphPermission` (Optional): Permission ID. Default: `"e1fe6dd8-ba31-4d61-89e7-88639da4683d"` (User.Read)
- `GraphApiId` (Optional): API ID. Default: `"00000003-0000-0000-c000-000000000000"`

**Example**:
```powershell
# Load the function
. .\\New-EntraIDApplicationRegistrationPermissions.ps1

# Assign User.Read permission
New-EntraIDApplicationRegistrationPermissions -ObjectId "your-object-id"

# Assign custom permission
New-EntraIDApplicationRegistrationPermissions -ObjectId "your-object-id" -GraphPermission "your-permission-id"
```

---

### New-EntraIDApplicationRegistrationRootPermissions

**Purpose**: Assigns Owner role at the tenant root level to the application's service principal.

**Parameters**:
- `AppId` (Optional): The Application ID. Default: `$AppRegistration.AppId`

**Example**:
```powershell
# Load the function
. .\\New-EntraIDApplicationRegistrationRootPermissions.ps1

# Assign Owner role at tenant root
New-EntraIDApplicationRegistrationRootPermissions -AppId "your-application-id"
```

---

### Get-EntraIDApplicationRegistrationSecrets

**Purpose**: Checks for expiring secrets and renews them automatically.

**Parameters**:
- `DisplayName` (Required): The display name of the application to check

**Functionality**:
- Checks for secrets expiring within 30 days
- Automatically creates new secrets for applications with expiring credentials

**Example**:
```powershell
# Load the function
. .\\Get-EntraIDApplicationRegistrationSecrets.ps1

# Check and renew secrets
Get-EntraIDApplicationRegistrationSecrets -DisplayName "Azure Management Service"
```

---

### Test-EntraIDTenantAccess

**Purpose**: Validates application registration configuration and permissions.

**Parameters**:
- `DisplayName` (Mandatory for ByDisplayNameSet): Application display name
- `ApplicationId` (Mandatory for ByAppIdSet): Application ID
- `ExpiresIn` (Optional): Days threshold for secret expiry check. Default: 30

**Checks Performed**:
- Application registration exists
- Service principal exists
- Owner permissions on root management group
- Microsoft Graph API permissions
- Secret expiration status
- Hub subscription access

**Example**:
```powershell
# Load the function
. .\\Test-EntraIDTenantAccess.ps1

# Test by display name
$results = Test-EntraIDTenantAccess -DisplayName "Azure Management Service"

# Test by application ID
$results = Test-EntraIDTenantAccess -ApplicationId "your-app-id" -ExpiresIn 60

# View results
$results | Format-Table
```

## Quick Start Guide

### Complete Deployment

To deploy a fully configured application registration:

```powershell
# 1. Connect to Azure
Connect-AzAccount

# 2. Load and run the deployment function
. .\\Deploy-EntraIDTenantApplicationRegistration.ps1
Deploy-EntraIDTenantApplicationRegistration -DisplayName "My Organization Service"

# 3. The function will output:
#    - Application Registration details
#    - Service Principal information
#    - Secret credentials
#    - Permission assignments
```

### Manual Step-by-Step Deployment

```powershell
# 1. Create the application registration
. .\\New-EntraIDApplicationRegistration.ps1
$app = New-EntraIDApplicationRegistration -DisplayName "My Organization Service"

# 2. Create a secret
. .\\New-EntraIDApplicationRegistrationSecret.ps1
New-EntraIDApplicationRegistrationSecret -AppId $app.AppId

# 3. Assign Graph API permissions
. .\\New-EntraIDApplicationRegistrationPermissions.ps1
New-EntraIDApplicationRegistrationPermissions -ObjectId $app.Id

# 4. Assign root-level Owner permissions
. .\\New-EntraIDApplicationRegistrationRootPermissions.ps1
New-EntraIDApplicationRegistrationRootPermissions -AppId $app.AppId

# 5. Verify the configuration
. .\\Test-EntraIDTenantAccess.ps1
Test-EntraIDTenantAccess -DisplayName "My Organization Service"
```

## Secret Management

### Secret Lifecycle

- **Duration**: 6 months
- **Format**: `AppSecret-yyyyMMdd` (e.g., `AppSecret-20231215`)
- **Automatic Renewal**: Use `Get-EntraIDApplicationRegistrationSecrets` to check and renew

### Secret Rotation

```powershell
# Automated rotation for expiring secrets
. .\\Get-EntraIDApplicationRegistrationSecrets.ps1
Get-EntraIDApplicationRegistrationSecrets -DisplayName "Azure Management Service"
```

## Common Microsoft Graph Permission IDs

| Permission | ID | Type |
|------------|-----|------|
| User.Read | e1fe6dd8-ba31-4d61-89e7-88639da4683d | Delegated |
| Application.ReadWrite.OwnedBy | 18a4783c-866b-4cc7-a460-3d5e5662c884 | Delegated |

## Troubleshooting

### Permission Issues

If you encounter permission errors:

1. Ensure you have the required role in Entra ID:
   ```powershell
   Get-AzRoleAssignment -SignInName your-email@domain.com
   ```

2. Verify Graph API permissions are granted:
   ```powershell
   $app = Get-AzADApplication -DisplayName "Azure Management Service"
   Get-AzADAppPermission -ObjectId $app.Id
   ```

3. Grant admin consent for permissions in the Azure Portal:
   - Navigate to Azure Active Directory → App registrations
   - Select your application
   - Go to API permissions
   - Click "Grant admin consent"

### Secret Expiration

To check when secrets expire:

```powershell
$app = Get-AzADApplication -DisplayName "Azure Management Service"
$credentials = Get-AzADAppCredential -ObjectId $app.Id
$credentials | Select-Object KeyId, StartDateTime, EndDateTime
```

## Security Considerations

- **Secret Storage**: Never commit secrets to version control
- **Permission Scope**: Grant minimum required permissions
- **Regular Audits**: Periodically review application permissions using `Test-EntraIDTenantAccess`
- **Secret Rotation**: Implement regular secret rotation policies
- **Root Access**: Use root-level Owner permissions carefully

## Contributing

Contributions are welcome! Please ensure:
- Code follows existing PowerShell best practices
- Functions include proper documentation (synopsis, description, parameters, examples)
- Changes maintain backward compatibility
- Author attribution is preserved

## Author

**Roni Alarashye**

## License

Please refer to the repository license for usage terms.

## Support

For issues or questions, please open an issue in the GitHub repository.
