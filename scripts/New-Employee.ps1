#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Groups

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [guid]$ExpectedTenantId,

    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z][a-z0-9.-]{2,63}$')]
    [string]$Username,

    [Parameter(Mandatory)]
    [ValidatePattern('^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
    [string]$Domain,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DisplayName,

    [Parameter(Mandatory)]
    [ValidateSet('IT','Security','Finance','HR','Engineering','Sales')]
    [string]$Department,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$JobTitle
)

$ErrorActionPreference = 'Stop'
$context = Get-MgContext
if (-not $context -or $context.TenantId -ne $ExpectedTenantId.ToString()) {
    throw 'Connect to the expected lab tenant first.'
}
foreach ($scope in 'User.ReadWrite.All','GroupMember.ReadWrite.All') {
    if ($scope -notin $context.Scopes) {
        throw "Missing required permission: $scope"
    }
}

$upn = "$Username@$Domain"
$existing = @(Get-MgUser -Filter "userPrincipalName eq '$upn'")
if ($existing.Count) {
    throw "Account already exists: $upn"
}

$groupName = "SG-$Department-Users"
$groups = @(Get-MgGroup -Filter "displayName eq '$groupName'" `
    -Property Id,DisplayName,SecurityEnabled,GroupTypes,IsAssignableToRole)
if ($groups.Count -ne 1) {
    throw "Expected exactly one group named $groupName."
}
$group = $groups[0]
if (-not $group.SecurityEnabled -or
    $group.IsAssignableToRole -or
    'DynamicMembership' -in $group.GroupTypes) {
    throw 'Target must be an assigned, non-role-assignable security group.'
}

if (-not $PSCmdlet.ShouldProcess($upn,
    "Create employee, assign $groupName, and enable account")) {
    return
}

$password = Read-Host 'Enter a strong temporary password' -AsSecureString
$logDirectory = Join-Path $PSScriptRoot '../logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$logPath = Join-Path $logDirectory 'onboarding.log'
$newUser = $null
$plainPassword = $null
$body = $null

try {
    $plainPassword = [System.Net.NetworkCredential]::new('', $password).Password
    if ($plainPassword.Length -lt 16) {
        throw 'Use a temporary password of at least 16 characters.'
    }
    $body = @{
        AccountEnabled = $false
        DisplayName = $DisplayName
        MailNickname = $Username
        UserPrincipalName = $upn
        Department = $Department
        JobTitle = $JobTitle
        CompanyName = 'Northstar Technologies'
        EmployeeType = 'Employee'
        PasswordProfile = @{
            Password = $plainPassword
            ForceChangePasswordNextSignIn = $true
        }
    }

    $newUser = New-MgUser -BodyParameter $body -ErrorAction Stop
    if (-not $newUser.Id) { throw "User creation returned no ID; stopping." }
    Add-Content $logPath "$(Get-Date -Format o) Created disabled account $upn"

    New-MgGroupMemberByRef -ErrorAction Stop -GroupId $group.Id -BodyParameter @{
        '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$($newUser.Id)"
    }
    Add-Content $logPath "$(Get-Date -Format o) Assigned $upn to $groupName"

    Update-MgUser -UserId $newUser.Id -AccountEnabled:$true -ErrorAction Stop
    Add-Content $logPath "$(Get-Date -Format o) Enabled $upn"
    Write-Host "Provisioned $upn in $groupName. Verify the resulting account and membership."
}
catch {
    Add-Content $logPath "$(Get-Date -Format o) FAILED onboarding $upn"
    if ($newUser) {
        Write-Warning "Account $upn was created. Inspect its state before retrying."
    }
    throw
}
finally {
    if ($body) { $body.PasswordProfile.Password = $null }
    $plainPassword = $null
    $password.Dispose()
}
