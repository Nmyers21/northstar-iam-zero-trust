# Northstar Technologies — Microsoft Entra IAM Lab

A fictional organization used to demonstrate identity administration, least privilege, MFA, Joiner–Mover–Leaver processes, and Microsoft Graph PowerShell automation.

## Verified implementation

- Six departmental security groups and twelve original employee identities.
- Separate Global Administrator and delegated User Administrator identities.
- Delegated administration exercised; the earlier handoff/operator reported inability to assign Global Administrator. A dedicated denial screenshot is not included.
- Security defaults reported enabled; successful MFA sign-ins reported for both organizational administrators. Dedicated configuration/MFA screenshots are not included.
- Maya transferred from Security to Finance, with profile, group, and audit evidence.
- Jordan provisioned manually, subsequently disabled, sessions revoked, and group membership removed.
- Casey provisioned by script under the delegated administrator; profile and Engineering membership verified. Duplicate creation blocked.
- Alex provisioned with recovery after a script defect, transferred by script from Sales to Finance, and offboarded by script. Disabled state, zero direct directory memberships, session-valid-from timestamp, and execution log verified.
- Revised inventory export verified October 24, 2026 under the delegated administrator: 18 users, 6 departmental groups, 13 direct memberships, and 3 active directory role assignments.
- Account hygiene report tested on October 23, 2026: two disabled identities and one identity missing department/job title.

## Scope and limitations

This is a lab implementation of selected IAM and Zero Trust practices, not a complete enterprise Zero Trust deployment. Departmental membership changes were verified; application authorization was not tested. Session revocation requests and stored state were verified; interruption of existing sessions was not tested. Premium Conditional Access, Identity Protection, PIM, access reviews, and sign-in-based inactivity reporting were not deployed. Hygiene findings are review candidates, not proof of inactivity or automatic deletion instructions.

## Scripts

| Script | Purpose |
|---|---|
| New-Employee.ps1 | Create disabled identity, assign department group, enable identity |
| Update-EmployeeDepartment.ps1 | Remove old department membership, add new membership, update profile |
| Disable-Employee.ps1 | Disable approved identity, revoke sessions, remove specified department membership |
| Export-IAMReport.ps1 | Export users, groups, memberships, and active directory roles |
| Get-AccountHygieneReport.ps1 | Report disabled identities and missing internal-user attributes |

Use PowerShell 7 and the Microsoft Graph modules declared at the top of each script. Authenticate interactively with MFA using `Connect-MgGraph -ContextScope Process`. Supply your own tenant and object IDs; do not embed credentials. Use `-WhatIf` before mutation scripts. Transfer and offboarding scripts request confirmation.

See [operations](documentation/operations.md), [test results](documentation/test-results.md), and [review](documentation/script-review.md). Local exports and execution logs must stay private. Only sanitized screenshots should enter version control.

## Architecture, assessment, and evidence

- [Architecture](documentation/architecture.md)
- [Security assessment](documentation/security-assessment.md)
- [Lessons learned](documentation/lessons-learned.md)
- [Evidence register and publication gaps](documentation/evidence-register.md)

Selected screenshots have been cropped/redacted and visually reviewed. See the [evidence gallery](documentation/evidence-gallery.md). Publication remains pending final user review and GitHub setup. No repository has been published.
