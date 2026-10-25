# Evidence selection and redaction register

37 supplied screenshots were visually reviewed. The following 15 are the primary selection. Originals remain private and unmodified. The public package contains 18 cropped/redacted images derived from these 15 originals. Original pixels were only cropped or covered with opaque boxes; no result text was replaced.

| Filename after redaction | What it supports | Redaction / interpretation |
|---|---|---|
| automation-final-iam-inventory.png | 18 users, 6 groups, 13 memberships, 3 active roles | Redact domain, tenant GUID, personal name, local username/path. |
| automation-account-hygiene-results.png | Two disabled identities and one profile-completeness finding | Use one result block; redact personal name, tenant GUID and local paths. Do not label the personal account exception approved. |
| mover-maya-profile-before.png | Security / Security Analyst | Crop top account header; redact UPN and object ID. |
| mover-maya-profile-after.png | Finance / Finance Analyst | Redact UPN and object ID. |
| mover-maya-groups-after.png | Finance membership and successful Security membership removal | Redact group object ID. |
| mover-maya-audit-profile-change.png | Audit old/new department and title values | Preserve old/new values and fictional employee identity; inspect truncated identity text. |
| mover-maya-audit-security-removal.png | Removal event references Security group | Redact group GUID; pair with successful event-list evidence. |
| leaver-jordan-account-disabled.png | Disabled status (identity context in private original) | Redact both UPNs and object ID; one group still present at this checkpoint. |
| jml-jordan-audit-timeline.png | Successful add user, group change, disable and session-related events | Redact target/actor UPN columns; preserve event, status, and timestamps. |
| automation-onboarding-verified.png | Casey Engineering, Software Engineer, enabled; membership in separate crop | Redact domain and local username/path; crop masked password prompt if practical. |
| automation-onboarding-duplicate-blocked.png | Existing Casey rejected before mutation | Redact domain, tenant GUID, local username/path. |
| automation-transfer-preview.png | WhatIf Sales to Finance | Redact domain, tenant GUID, local username/path. |
| automation-transfer-verified.png | Alex Finance profile; membership results in separate crop | Redact domain and local username/path. |
| automation-offboarding-preview.png | WhatIf disable, revoke, remove Finance membership | Redact domain, user GUID, tenant GUID, local username/path. |
| automation-offboarding-verified.png | Alex disabled and session timestamp; zero memberships in separate crop; log private | Redact domain and local username/path. Timestamp display differs from log offset; do not infer timezone from unlabeled display. |

## Excluded from the primary gallery

- Repeated inventory/CSV output and authentication welcome screens: redundant with stronger final results.
- Device-login timeout screenshots: contain expired authentication codes and do not independently prove the reason for the block.
- Full authentication context dumps: disclose identifiers without adding useful result evidence.
- Group-removal confirmation dialog: pending action, not proof of completion.
- Alex recovery and Casey code-entry screenshots: keep privately as troubleshooting history; use verified results in the main gallery.

## Evidence gaps

No supplied screenshot directly shows Security defaults enabled, completed MFA authentication details, or the delegated administrator failing to assign Global Administrator. Those tests were reported earlier in the conversation, but this gallery does not independently substantiate them. A role inventory proves assignments, not a permission-denial test. No need to repeat employee mutations to fill these gaps.

## Publication gate

Redacted copies were created and visually reviewed on October 24, 2026. Use opaque redaction or cropping; do not replace results or reconstruct UI. Preserve original files separately. Confirm that no UPN/domain, personal account name, IP, tenant/object ID, local username, device code, or secret remains unnecessarily visible. Mark copies as redacted for privacy.


Some public crops omit identity context to protect privacy. The private originals retain that context. The final inventory crop displays groups, memberships and roles; the 18-user count is retained in the private full original and documented test result. The offboarding crop shows disabled state and session-valid-from time; a separate crop shows zero memberships. Original execution logs remain private.
