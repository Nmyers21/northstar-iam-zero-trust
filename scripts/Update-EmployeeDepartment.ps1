#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Groups

[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    [Parameter(Mandatory)][guid]$ExpectedTenantId,
    [Parameter(Mandatory)][string]$UserPrincipalName,
    [Parameter(Mandatory)]
    [ValidateSet('IT','Security','Finance','HR','Engineering','Sales')]
    [string]$SourceDepartment,
    [Parameter(Mandatory)]
    [ValidateSet('IT','Security','Finance','HR','Engineering','Sales')]
    [string]$TargetDepartment,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$JobTitle
)

$ErrorActionPreference = 'Stop'
$context = Get-MgContext
if (-not $context -or $context.TenantId -ne $ExpectedTenantId.ToString()) {
    throw 'Connect to the expected lab tenant first.'
}
foreach ($scope in 'User.ReadWrite.All','GroupMember.ReadWrite.All') {
    if ($scope -notin $context.Scopes) { throw "Missing permission: $scope" }
}
if ($SourceDepartment -eq $TargetDepartment) {
    throw 'Source and target departments must differ.'
}

$user = Get-MgUser -UserId $UserPrincipalName `
    -Property Id,DisplayName,Department,AccountEnabled,UserType -ErrorAction Stop
if ($user.UserType -ne 'Member' -or -not $user.AccountEnabled) {
    throw 'Target must be an enabled internal employee.'
}
if ($user.Department -ne $SourceDepartment) {
    throw "Current department does not match $SourceDepartment."
}

$selectedGroups = @{}
foreach ($department in $SourceDepartment,$TargetDepartment) {
    $matches = @(Get-MgGroup -Filter "displayName eq 'SG-$department-Users'" `
        -Property Id,SecurityEnabled,GroupTypes,IsAssignableToRole -ErrorAction Stop)
    if ($matches.Count -ne 1) { throw "Expected one group for $department." }
    $group = $matches[0]
    if (-not $group.SecurityEnabled -or $group.IsAssignableToRole -or
        'DynamicMembership' -in $group.GroupTypes) {
        throw "Unsupported group for $department."
    }
    $selectedGroups[$department] = $group
}

$source = $selectedGroups[$SourceDepartment]
$target = $selectedGroups[$TargetDepartment]
$sourceMembers = @(Get-MgGroupMember -GroupId $source.Id -All -ErrorAction Stop)
$targetMembers = @(Get-MgGroupMember -GroupId $target.Id -All -ErrorAction Stop)
if ($user.Id -notin $sourceMembers.Id) {
    throw 'Employee is not a direct member of the source group.'
}

if (-not $PSCmdlet.ShouldProcess($UserPrincipalName,
    "Transfer $SourceDepartment to $TargetDepartment; set title to $JobTitle")) {
    return
}

$logDirectory = Join-Path $PSScriptRoot '../logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$logPath = Join-Path $logDirectory 'transfers.log'

try {
    # Remove obsolete departmental membership before granting the new membership.
    Remove-MgGroupMemberByRef -GroupId $source.Id `
        -DirectoryObjectId $user.Id -ErrorAction Stop
    Add-Content $logPath "$(Get-Date -Format o) Removed $UserPrincipalName from $SourceDepartment"

    if ($user.Id -notin $targetMembers.Id) {
        New-MgGroupMemberByRef -GroupId $target.Id -BodyParameter @{
            '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$($user.Id)"
        } -ErrorAction Stop
    }
    Add-Content $logPath "$(Get-Date -Format o) Assigned $UserPrincipalName to $TargetDepartment"

    Update-MgUser -UserId $user.Id -Department $TargetDepartment `
        -JobTitle $JobTitle -ErrorAction Stop
    Add-Content $logPath "$(Get-Date -Format o) Updated profile for $UserPrincipalName"
    Write-Host 'Transfer completed. Verify profile and both group memberships.'
}
catch {
    Add-Content $logPath "$(Get-Date -Format o) FAILED transfer for $UserPrincipalName"
    Write-Warning 'Transfer may be partially applied. Inspect the account before retrying.'
    throw
}
