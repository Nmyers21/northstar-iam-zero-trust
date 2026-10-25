#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Groups, Microsoft.Graph.Identity.Governance

[CmdletBinding()]
param(
    [Parameter(Mandatory)][guid]$ExpectedTenantId,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../reports')
)

$ErrorActionPreference = 'Stop'

try {
    $context = Get-MgContext
    if (-not $context -or $context.TenantId -ne $ExpectedTenantId.ToString()) {
        throw 'Connect to the expected lab tenant before running this script.'
    }

    foreach ($scope in 'User.Read.All','GroupMember.Read.All','RoleManagement.Read.Directory') {
        if ($scope -notin $context.Scopes) { throw "Missing permission: $scope" }
    }

    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

    $users = @(Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled,UserType -ErrorAction Stop)

    $reportPath = Join-Path $OutputDirectory ("users-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

    $users |
        Sort-Object DisplayName |
        Select-Object Id,DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled,UserType |
        Export-Csv -LiteralPath $reportPath -NoTypeInformation -Encoding utf8

    Write-Host "Exported $($users.Count) users to $reportPath"
}
catch {
    throw "User inventory export failed: $($_.Exception.Message)"
}

# Export departmental groups and their direct memberships.
try {
    $groups = @(Get-MgGroup -All -Property Id,DisplayName,SecurityEnabled -ErrorAction Stop |
        Where-Object DisplayName -like 'SG-*-Users')

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

    $groups |
        Select-Object Id,DisplayName,SecurityEnabled |
        Export-Csv -LiteralPath (Join-Path $OutputDirectory "groups-$stamp.csv") -NoTypeInformation -Encoding utf8

    $userLookup = @{}
    foreach ($user in $users) {
        $userLookup[$user.Id] = $user
    }

    $memberships = @(
        foreach ($group in $groups) {
            foreach ($member in (Get-MgGroupMember -GroupId $group.Id -All -ErrorAction Stop)) {
                $user = $userLookup[$member.Id]
                [pscustomobject]@{
                    GroupName         = $group.DisplayName
                    GroupId           = $group.Id
                    MemberId          = $member.Id
                    DisplayName       = $user.DisplayName
                    UserPrincipalName = $user.UserPrincipalName
                }
            }
        }
    )

    $memberships |
        Export-Csv -LiteralPath (Join-Path $OutputDirectory "memberships-$stamp.csv") -NoTypeInformation -Encoding utf8

    Write-Host "Exported $($groups.Count) departmental groups and $($memberships.Count) direct memberships."
}
catch {
    throw "Group export failed: $($_.Exception.Message)"
}

# Export active directory role assignments.
try {
    $assignments = @(Get-MgRoleManagementDirectoryRoleAssignment -All -ExpandProperty RoleDefinition -ErrorAction Stop)

    $roleRows = @(
        foreach ($assignment in $assignments) {
            $user = $userLookup[$assignment.PrincipalId]
            [pscustomobject]@{
                AssignmentId      = $assignment.Id
                PrincipalId       = $assignment.PrincipalId
                DisplayName       = $user.DisplayName
                UserPrincipalName = $user.UserPrincipalName
                Role              = $assignment.RoleDefinition.DisplayName
                DirectoryScopeId  = $assignment.DirectoryScopeId
                AppScopeId        = $assignment.AppScopeId
            }
        }
    )

    $roleRows |
        Export-Csv -LiteralPath (Join-Path $OutputDirectory "roles-$stamp.csv") -NoTypeInformation -Encoding utf8

    $roleRows |
        Select-Object DisplayName,Role,DirectoryScopeId |
        Format-Table -AutoSize

    Write-Host "Exported $($roleRows.Count) active directory role assignments."
}
catch {
    throw "Role export failed: $($_.Exception.Message)"
}
