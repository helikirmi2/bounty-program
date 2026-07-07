# 03 - License State And Threat Model

## Passive License-State Evidence

`fact`: No literal `license.lic` or `license.key` files were found by filename search in `portable-sample`.

`fact`: The sample contains a bundled profile log at:

`portable-sample\Plasticity\roaming\modified\@APPDATA@\Plasticity\logs\main.log`

`fact`: That log contains 108 occurrences of `RENDER: License validity: true`.

`fact`: First observed occurrence:

`[2025-11-28 12:20:28.429] [info]  RENDER: License validity: true`

`fact`: Last observed occurrence:

`[2026-06-28 11:29:01.193] [info]  RENDER: License validity: true`

`inference`: The portable image carries captured runtime profile state where the renderer repeatedly recorded a valid license state over a long time window.

`risk`: Even without a visible `license.lic` artifact, replayable profile state can be part of a local license bypass class if the application trusts local renderer/cache state more than a fresh, immutable, signed authorization object.

## R-002: Client-Side Enforcement Compromise

`risk`: The client endpoint is outside the vendor trust boundary. If entitlement enforcement relies on mutable renderer state such as `isValid`, local storage, IPC messages, or UI gating, a wrapper/loader/mod layer can influence the runtime transition from "license verified" to "feature allowed".

`inference`: The portable sample's `main: "loader.js"` redirection and mod/AuthGuard layer are evidence that attackers target runtime mediation, not necessarily Ed25519 license forgery.

`control`: Move entitlement checks from UI-level booleans to operation-level gates:

- Define an immutable `VerifiedLicenseContext` created only after signature, freshness, machine, and entitlement checks pass.
- Do not serialize authorization as a simple mutable boolean across IPC.
- Pass signed or MAC-protected authorization context handles through IPC, with nonce/session binding.
- Require native/kernel command dispatch to query entitlements directly before privileged operations.
- Treat renderer UI as advisory only.

## R-004/R-010: Offline Freshness And Time Authority

`risk`: Offline-perpetual designs are vulnerable to stale-state replay and local clock manipulation if the app accepts cached validity without a signed freshness model.

`inference`: A portable image carrying historical AppData and logs demonstrates why local time and local cache state are weak authorities in a desktop Electron model.

`control`: Implement a server-time freshness envelope:

- Store `last_signed_server_time`, `license_not_before`, `license_expires_at`, `cache_issued_at`, and `offline_valid_until` as signed claims or as a signed server response envelope.
- Keep a monotonic local observation record: last accepted signed server time and last local wall-clock seen.
- If wall-clock moves backward beyond a small tolerance, transition to a restricted refresh-required state.
- Separate business expiry from cache freshness expiry.

Recommended state taxonomy:

| State | Meaning | User/Runtime Behavior |
| --- | --- | --- |
| `VALID_ONLINE` | Fresh online validation succeeded | full authorized access |
| `VALID_OFFLINE_FRESH` | Signed offline TTL still fresh | full authorized access |
| `VALID_OFFLINE_STALE_GRACE` | TTL stale but within short grace | limited grace, visible refresh request |
| `OFFLINE_REFRESH_REQUIRED` | Cache stale beyond grace | block paid features until refresh |
| `BUSINESS_EXPIRED` | Subscription/trial entitlement expired | block paid features; do not treat as network error |
| `CLOCK_ROLLBACK_SUSPECTED` | local time contradicts signed time history | refresh required; preserve user data access |

## R-006: Ambiguous Expired/Error Messaging

`risk`: If `expired`, `offline`, `cache stale`, and `network error` collapse into one user-visible or code-level state, attackers can exploit ambiguity to keep the app in a permissive fallback path.

`control`: Use explicit error taxonomy internally and in logs. Never let an unknown/error state degrade into a licensed state. Preserve user-friendly messaging, but keep enforcement states precise.

## R-009/R-011: Trial-To-Studio Entitlement Confusion

`fact`: The user reported that files are identical across trial and license tiers. This is common for Electron apps: one binary contains all code paths, and entitlements decide access.

`inference`: Identical binaries are not inherently a vulnerability. They become risky when Studio/paid command execution is controlled only by UI visibility, renderer flags, or local mutable state.

`risk`: A loader/mod/runtime layer can attempt to expose commands that are present in the binary but should be denied by entitlement policy.

`control`: Maintain a signed entitlement manifest mapping commands/features to required claims:

| Boundary | Required Control |
| --- | --- |
| UI menu/button visibility | advisory entitlement check |
| IPC command dispatch | mandatory entitlement check |
| native/kernel operation | mandatory entitlement check |
| export/save/cloud operation | mandatory entitlement check |
| background task invocation | mandatory entitlement check |

`control`: Add negative tests that run every restricted command under Trial, Indie, Studio, expired, stale-offline, and clock-rollback states. The expected result must be denial at dispatch/native boundary, not merely hidden UI.

## Vendor Evidence Framing

`fact`: This sample does not prove Ed25519 signature forgery.

`inference`: It supports a different report thesis: piracy tooling appears to target local execution integrity, startup mediation, profile replay, and entitlement confusion.

`risk`: The security bottleneck is not license signing. The bottleneck is local runtime enforcement in an Electron endpoint controlled by the user.

`control`: Keep Ed25519 for authenticity, but add resource integrity, startup integrity, state freshness, and command-level entitlement enforcement.

