# Operations and recovery

## Permissions

- Inventory: User.Read.All, GroupMember.Read.All, RoleManagement.Read.Directory.
- Hygiene: User.Read.All.
- Current lifecycle scripts: User.ReadWrite.All, GroupMember.ReadWrite.All.

Use a Global Administrator only to grant required consent; run lifecycle operations as the delegated User Administrator where supported. These delegated permissions are broad and constrained by the signed-in administrator's roles. End sessions with Disconnect-MgGraph.

The inventory script requires Microsoft.Graph.Identity.Governance as well as Authentication, Users, and Groups. Offboarding additionally requires Users.Actions.

## Safe execution

The revised inventory command requires `-ExpectedTenantId <your-tenant-guid>`. All other scripts already require the tenant guard. Offboarding also requires the approved user object ID. Review target identity and departmental group before confirming. These scripts are lab tools and do not perform a complete privileged-role exclusion check.

## Partial failure

Graph operations are not transactional. Read the account, memberships, and logs before retrying a failed mutation. Onboarding starts disabled, but failures after enablement (including a logging failure) can leave an enabled account. Transfer removes the old membership first and can leave the user without departmental membership if a later step fails. Offboarding stops on the first failure; group removal may not execute after a revocation failure. Repair explicitly; do not blindly rerun or delete identities.

Offboarding removes only the specified departmental group. It does not remove all possible application assignments, other groups, devices, credentials, or downstream access. Verify those separately for a real organization.

## Reporting limits

Direct group memberships and active directory role assignments are exported. Eligible PIM assignments and effective inherited access are outside scope. Non-user principals may have blank names in exports; preserve their IDs and investigate separately. Reports may be partially written when a later stage fails. Empty-result CSV handling is not standardized in the current inventory script.

Account hygiene does not query sign-in activity. Administrative accounts with intentionally absent employee attributes require a reviewed exception, not a fabricated employee profile.
