# IAM security assessment

## Evidence-based outcomes

The October 24 inventory recorded 18 users, six departmental groups, 13 direct departmental memberships, and three active directory role assignments. Casey onboarding, duplicate rejection, Alex transfer, and Alex offboarding were verified by Graph readback. Maya's audit modified-properties evidence links Security-to-Finance profile changes to old/new values. Jordan's audit timeline records successful provisioning and offboarding events. Local logs support execution history but are not tamper-resistant centralized audit records.

## Findings

| Finding | Observed state | Disposition |
|---|---|---|
| Standing privileged access | Two active Global Administrators, including the original personal identity | Review necessity, protect recovery access, and propose eligible roles when licensing permits; no role removal performed |
| Intentional disabled identities | Alex and Jordan disabled after leaver scenarios | Retain as lab evidence; define retention and deletion criteria for enterprise use |
| Incomplete attributes | Original personal identity flagged for department/job title | Confirm account purpose/type and record an exception if appropriate; not automatically an employee defect |
| Broad delegated automation permissions | User.ReadWrite.All and GroupMember.ReadWrite.All used for lifecycle work | Restrict consent and operators; keep write sessions short; consider narrower scopes per operation in future |
| Partial workflow failures | Alex required recovery during onboarding development | Disabled-first creation and explicit error handling limit exposure; inspect state before retrying |
| Offboarding scope | Specified department membership removed; Alex readback showed zero directory memberships | General script is not exhaustive downstream deprovisioning |
| Audit retention | Historical screenshots saved; current historical-log availability not checked | Export evidence promptly; propose centralized retention |

## Controls not deployed or not tested

Custom Conditional Access, Identity Protection, PIM, access reviews, and sign-in-based inactivity reporting remain proposed/license-dependent. Existing-session interruption, application authorization, full privileged-account exclusion, automated rollback, and enterprise-scale performance were not tested. Administrator MFA and RBAC-denial tests were reported by the operator earlier, but dedicated screenshots are absent from this batch.

## Audit procedure

For a lifecycle event, identify the approved employee and intended change; correlate event time, actor, target, activity, result, and modified properties. Compare the event with current profile and membership state and the script log. Investigate unexpected actors, privilege grants, disabled identities retaining access, and mismatch between HR attributes and access assignments. Distinguish evidence of an operation from evidence of effective application/session behavior.
