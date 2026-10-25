# Lessons learned

- Readback verification matters: a success message alone does not establish the final profile or group state.
- Graph workflows are multi-step. A rejected password and a later patch defect required inspecting Alex's disabled account before completing provisioning. Casey then demonstrated a clean complete onboarding run and duplicate rejection.
- Browser authentication successfully selected the delegated administrator after device-code attempts failed. Keep authentication-flow troubleshooting separate from authorization-role conclusions.
- Explicit ErrorAction Stop on Graph writes prevented continuation after failed operations. Tenant and object-ID checks reduce accidental targeting.
- Group membership is evidence of assignment, not proof of application access. Session revocation request success is not proof that an existing session was interrupted immediately.
- Licensing boundaries should shape honest scope. Account hygiene reports disabled identities and missing attributes; it does not infer inactivity without sign-in evidence.
- Capture evidence at completed checkpoints, preserve private originals, and publish only sanitized copies with captions describing what each result proves.
