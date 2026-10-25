# Test and evidence register

Results derive from supplied screenshots, operator confirmations, and the private October 24 inventory CSVs. Packaging did not authenticate to or change the tenant.

| Test | Result | Included public evidence |
|---|---|---|
| Delegated role restrictions | Earlier operator/handoff report: user administration allowed; Global Administrator assignment denied | Dedicated denial screenshot not supplied |
| Administrator MFA | Earlier operator confirmation: both organizational administrators completed Authenticator sign-ins | Dedicated MFA screenshot not supplied |
| Manual mover | Maya Security to Finance; audit old/new values observed | mover-maya-profile-before.png, mover-maya-profile-after.png, mover-maya-audit-profile-change.png, mover-maya-groups-after.png |
| Manual leaver | Jordan disabled, revocation performed, group membership removed | leaver-jordan-account-disabled.png and jml-jordan-audit-timeline.png; zero membership also confirmed earlier and in private final inventory |
| Final inventory | October 24: 18 users, 6 groups, 13 memberships, 3 active roles | automation-final-iam-inventory.png shows group/membership/role totals; 18-user total verified in private full original and CSV |
| Onboarding success | Casey enabled with Engineering membership | automation-onboarding-verified.png and automation-onboarding-membership.png |
| Duplicate prevention | Existing Casey account rejected before mutation | automation-onboarding-duplicate-blocked.png |
| Automated mover preview | WhatIf produced transfer plan | automation-transfer-preview.png |
| Automated mover | Alex Finance profile; Sales false, Finance true | automation-transfer-verified.png and automation-transfer-memberships.png |
| Automated leaver preview | WhatIf produced disable/revoke/remove plan | automation-offboarding-preview.png |
| Automated leaver | Alex disabled, zero direct directory memberships, revocation log recorded | automation-offboarding-verified.png and automation-offboarding-memberships.png; execution log is private |
| Hygiene | Three accounts flagged for review, October 23 | automation-account-hygiene-results.png |

Historical October 13 inventory counts (16 users, 12 memberships) precede addition of Alex and Casey and later offboarding. They are not conflicting final totals. The October 24 snapshot confirms Casey enabled in Engineering, Maya enabled in Finance, and Alex/Jordan disabled without departmental memberships.

## Evidence interpretation

Public images were cropped or covered with opaque boxes for privacy. Some omit identity context or show only one part of a test. Private originals retain the complete context. No result values were rewritten. The gallery lists each public crop separately.

MFA and the RBAC-denial test remain operator-reported tests without dedicated screenshots in this package. Security defaults was reported enabled. The original administrator's missing profile attributes remain a review item; no exception has been approved merely from the report output.

Session revocation success and session-valid-from values do not prove that an existing application session was interrupted. Application access enforcement was not tested. See operations.md and security-assessment.md for remaining lab limitations.
