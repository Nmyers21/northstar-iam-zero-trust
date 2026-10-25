#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users

[CmdletBinding()]
param(
    [Parameter(Mandatory)][guid]$ExpectedTenantId,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../reports')
)

$ErrorActionPreference = 'Stop'
$context = Get-MgContext
if (-not $context -or $context.TenantId -ne $ExpectedTenantId.ToString()) {
    throw 'Connect to the expected lab tenant first.'
}
if ('User.Read.All' -notin $context.Scopes) {
    throw 'Connect with User.Read.All.'
}

try {
    $users = @(Get-MgUser -All `
        -Property Id,DisplayName,UserPrincipalName,UserType,Department,JobTitle,AccountEnabled `
        -ErrorAction Stop)

    $findings = @(
        foreach ($user in $users) {
            $issues = @()
            if ($user.AccountEnabled -eq $false) {
                $issues += 'Disabled account: review retention'
            }
            if ($user.UserType -eq 'Member') {
                if ([string]::IsNullOrWhiteSpace($user.Department)) {
                    $issues += 'Missing department'
                }
                if ([string]::IsNullOrWhiteSpace($user.JobTitle)) {
                    $issues += 'Missing job title'
                }
            }
            if ($issues.Count) {
                [pscustomobject]@{
                    Id = $user.Id
                    DisplayName = $user.DisplayName
                    UserPrincipalName = $user.UserPrincipalName
                    UserType = $user.UserType
                    AccountEnabled = $user.AccountEnabled
                    Findings = $issues -join '; '
                    ActivityAssessment = 'Not assessed: sign-in activity not queried'
                }
            }
        }
    )

    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
    $path = Join-Path $OutputDirectory ("hygiene-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

    if ($findings.Count) {
        $findings | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding utf8
        $findings | Select-Object DisplayName,Findings | Format-Table -AutoSize -Wrap
        Write-Host "Exported $($findings.Count) accounts for review to $path"
    }
    else {
        Write-Host 'No findings under the selected checks; no CSV generated.'
    }
}
catch {
    throw "Account hygiene report failed: $($_.Exception.Message)"
}
