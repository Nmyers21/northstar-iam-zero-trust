# Architecture and identity model

Northstar Technologies is a fictional organization hosted in one Microsoft Entra tenant. Six assigned cloud security groups represent IT, Security, Finance, HR, Engineering, and Sales. Twelve original employees established the department model; Jordan, Alex, and Casey were added during lifecycle testing. The final inventory observed 18 identities including administrative and original personal identities.

```mermaid
flowchart TD
    A[Organizational administrator: consent and tenant setup] --> T[Microsoft Entra tenant]
    D[Delegated User Administrator: routine operations] --> G[Microsoft Graph PowerShell]
    G --> T
    T --> U[Employee identities and profile attributes]
    U --> S[Six departmental security groups]
    T --> M[Security defaults and MFA]
    G --> R[Private inventory exports and execution logs]
    T --> L[Directory audit evidence]
```

Department groups establish an access-assignment model. No protected application was configured and tested to prove effective access changes. Entra directory roles are separate from department groups: the inventory observed two Global Administrators and one User Administrator, all at tenant scope. Zero Trust principles demonstrated include MFA, separation of administration, least-privilege delegation, and removal of obsolete department membership. This does not establish a complete Zero Trust architecture.
