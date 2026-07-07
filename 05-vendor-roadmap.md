# 05 - Vendor Roadmap

## Priority 0: Confirm With Official 25.2.8 Baseline

`control`: Obtain official Plasticity 25.2.8 Windows installer/package from vendor release infrastructure.

`control`: Build a hash manifest for official 25.2.8:

- outer installer/launcher
- `resources\app\package.json`
- `.webpack\main`
- renderer `.jsc` files
- preload scripts
- native modules such as `pk.node`
- important DLLs

`control`: Compare the portable sample to that baseline. Separate version drift, wrapper-added files, replaced entrypoints, modified official files, and bundled profile state.

## Priority 1: Signed Resource Manifest

`risk`: The observed portable sample changes the Electron entrypoint to `loader.js`.

`control`: Add a vendor-signed resource manifest covering:

- `resources\app\package.json`
- `main` entrypoint
- `.webpack` bytecode bundles
- preload scripts
- native modules
- entitlement policy manifest
- critical static configuration

`control`: Verify this manifest before untrusted JavaScript execution. Ideally, a native bootstrap verifies the app resource set and refuses to initialize privileged licensing/command paths if integrity fails.

`control`: Log a clear state such as `APP_RESOURCE_INTEGRITY_FAILED`, distinct from license failure.

## Priority 2: Command-Level Entitlement Gates

`risk`: Identical binaries across Trial/Indie/Studio are acceptable only if entitlements are enforced at execution boundaries.

`control`: Define a signed entitlement-policy manifest:

| Command Class | Enforcement Point |
| --- | --- |
| Studio-only modeling operations | native/kernel dispatch |
| import/export formats | import/export service boundary |
| automation/macros | command dispatcher |
| cloud/license actions | main process service boundary |
| UI actions | renderer visibility only, advisory |

`control`: Every privileged command should evaluate `VerifiedLicenseContext` at dispatch time. Renderer state must not be the source of truth.

`control`: Add negative entitlement tests:

- Trial attempts Studio command: deny at dispatcher/native boundary.
- Expired subscription attempts Studio command: deny with `BUSINESS_EXPIRED`.
- Offline stale cache attempts paid command: deny or grace according to policy.
- Clock rollback detected: require refresh before paid commands.
- Renderer sends forged IPC state: deny because authorization context is not valid.

## Priority 3: Freshness And Offline State Hardening

`risk`: Portable containers can carry old profile state and logs. Offline-perpetual licensing needs explicit freshness semantics to avoid stale-state replay.

`control`: Replace ambiguous local validity with signed freshness envelopes:

- `license_claim_signed_at`
- `server_time_signed_at`
- `offline_valid_until`
- `business_expires_at`
- `activation_id`
- `machine_fingerprint_version`
- `entitlement_set`

`control`: Maintain monotonic anti-rollback metadata:

- last accepted signed server time
- last observed local wall-clock
- clock rollback tolerance
- grace window counter

`control`: Use explicit states:

- `VALID_ONLINE`
- `VALID_OFFLINE_FRESH`
- `VALID_OFFLINE_STALE_GRACE`
- `OFFLINE_REFRESH_REQUIRED`
- `BUSINESS_EXPIRED`
- `CLOCK_ROLLBACK_SUSPECTED`
- `APP_RESOURCE_INTEGRITY_FAILED`

## Priority 4: Profile Replay Resistance

`risk`: The sample bundles `@APPDATA@\Plasticity` state. If local profile artifacts can authorize features, portable replay becomes easier.

`control`: Do not store authorization as bare local storage values, renderer booleans, or unauthenticated JSON.

`control`: Bind cached authorization to:

- signed server freshness
- activation identifier
- machine fingerprint version
- platform keystore protection where possible
- app resource integrity status

`control`: If the same activation appears with multiple incompatible environment fingerprints or wrapper indicators, trigger server-side risk review without automatically burning a new activation.

## Priority 5: Fingerprint Resilience

`risk`: Portable/VM environments can clone or virtualize OS identifiers.

`control`: Version `GetCompoundFingerprint` and separate stable from volatile signals:

| Signal Class | Examples | Use |
| --- | --- | --- |
| stable | OS machine GUID, hardware UUID, TPM/keystore identity where available | core matching |
| semi-stable | volume serial, user SID, install GUID | weighted confidence |
| volatile | hostname, GPU driver, network adapter order | telemetry and soft mismatch only |

`control`: Implement soft mismatch workflow:

- low-confidence drift: allow grace and request refresh
- medium drift: online revalidation without consuming new activation if activation ID matches
- high drift: require account/device management

## Priority 6: Telemetry And Abuse Detection

`control`: Add privacy-preserving telemetry for:

- unexpected `package.json` main entrypoint
- missing/modified resource manifest
- wrapper/virtualization indicators
- repeated offline validity beyond expected TTL
- entitlement-denied command attempts from trial state
- clock rollback state transitions

`control`: Do not block all users solely because a virtualization signal exists. Combine signals into a risk score and preserve project file access to avoid harming legitimate users.

## Priority 7: Vendor Report Narrative

Recommended concise thesis:

`risk`: The licensing cryptography appears focused on license authenticity, but observed piracy packaging targets the local runtime enforcement boundary: Electron entrypoint redirection, virtualized profile replay, loader/mod mediation, and command entitlement confusion.

`impact`: This enables scalable unauthorized use without Ed25519 forgery if paid features can be reached through mutable client-side state or replayed offline validity.

`control`: Close the gap with signed resource integrity, signed freshness taxonomy, immutable authorization contexts, and operation-level entitlement enforcement.

