#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Users.Actions, Microsoft.Graph.Groups

[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    [Parameter(Mandatory)][guid]$ExpectedTenantId,
    [Parameter(Mandatory)][guid]$ExpectedUserId,
    [Parameter(Mandatory)][string]$UserPrincipalName,
    [Parameter(Mandatory)]
    [ValidateSet('IT','Security','Finance','HR','Engineering','Sales')]
    [string]$Department
)

$ErrorActionPreference = 'Stop'
$context = Get-MgContext
if (-not $context -or $context.TenantId -ne $ExpectedTenantId.ToString()) {
    throw 'Connect to the expected lab tenant first.'
}
foreach ($scope in 'User.ReadWrite.All','GroupMember.ReadWrite.All') {
    if ($scope -notin $context.Scopes) { throw "Missing permission: $scope" }
}
if ($UserPrincipalName -eq $context.Account) {
    throw 'Cannot offboard the signed-in administrator.'
}

$user = Get-MgUser -UserId $UserPrincipalName `
    -Property Id,DisplayName,Department,UserType,AccountEnabled -ErrorAction Stop
if ($user.Id -ne $ExpectedUserId.ToString()) {
    throw 'User object ID does not match the approved target.'
}
if ($user.UserType -ne 'Member' -or $user.Department -ne $Department) {
    throw 'User type or department does not match the expected employee.'
}

$matches = @(Get-MgGroup -Filter "displayName eq 'SG-$Department-Users'" `
    -Property Id,SecurityEnabled,GroupTypes,IsAssignableToRole -ErrorAction Stop)
if ($matches.Count -ne 1) { throw 'Expected exactly one departmental group.' }
$group = $matches[0]
if (-not $group.SecurityEnabled -or $group.IsAssignableToRole -or
    'DynamicMembership' -in $group.GroupTypes) {
    throw 'Unsupported departmental group.'
}
$members = @(Get-MgGroupMember -GroupId $group.Id -All -ErrorAction Stop)

if (-not $PSCmdlet.ShouldProcess($UserPrincipalName,
    "Disable account, revoke sessions, and remove SG-$Department-Users membership")) {
    return
}

$logDirectory = Join-Path $PSScriptRoot '../logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$logPath = Join-Path $logDirectory 'offboarding.log'

try {
    Update-MgUser -UserId $user.Id -AccountEnabled:$false -ErrorAction Stop
    Add-Content $logPath "$(Get-Date -Format o) Disabled $UserPrincipalName"

    Revoke-MgUserSignInSession -UserId $user.Id -ErrorAction Stop | Out-Null
    Add-Content $logPath "$(Get-Date -Format o) Revocation request succeeded for $UserPrincipalName"

    if ($user.Id -in $members.Id) {
        Remove-MgGroupMemberByRef -GroupId $group.Id `
            -DirectoryObjectId $user.Id -ErrorAction Stop
    }
    Add-Content $logPath "$(Get-Date -Format o) Departmental membership removed for $UserPrincipalName"
    Write-Host 'Offboarding actions completed. Verify disabled status and membership removal.'
}
catch {
    Add-Content $logPath "$(Get-Date -Format o) FAILED offboarding $UserPrincipalName"
    Write-Warning 'Offboarding may be partially applied. Review the account and log.'
    throw
}
