# 06 - Runtime Memory Tamper Assessment

## Boundary

`fact`: No process was executed, debugged, attached to, or memory-scanned during this assessment.

`fact`: No memory addresses, offsets, byte patches, pointer chains, or Cheat Engine tables are documented here.

`control`: This section is suitable for a vendor report because it discusses mitigation posture and threat model, not an operational bypass recipe.

## Static PE Mitigation Results

`fact`: Static PE header inspection produced the following mitigation flags:

| File | PE | ImageBase | DYNAMICBASE | HIGHENTROPYVA | NXCOMPAT | GUARD_CF |
| --- | --- | --- | --- | --- | --- | --- |
| `Plasticity.exe` | PE32 | `0x400000` | true | false | true | false |
| `app-26.1.3\Plasticity.exe` | PE32+ | `0x140000000` | true | true | true | true |
| `app-26.1.3\resources\app\.webpack\renderer\pk.node` | PE32+ | `0x180000000` | true | true | true | false |
| `portable-sample\Plasticity_25.2.8.exe` | PE32+ | `0x400000` | false | true | true | false |
| `portable-sample\Plasticity\local\modified\@PROGRAMFILES@\Plasticity\Plasticity.exe` | PE32+ | `0x140000000` | true | true | true | true |
| `portable-sample\Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\renderer\pk.node` | PE32+ | `0x180000000` | true | true | true | false |

## Interpretation

`inference`: The official 26.1.3 Electron executable has `DYNAMICBASE`, `HIGHENTROPYVA`, `NXCOMPAT`, and `GUARD_CF` enabled. Its module base should not be assumed stable across process launches on modern Windows.

`inference`: The native `pk.node` addon has `DYNAMICBASE`, `HIGHENTROPYVA`, and `NXCOMPAT`, but not `GUARD_CF`. Its module base should also not be assumed stable across launches.

`inference`: The portable outer launcher `Plasticity_25.2.8.exe` lacks `DYNAMICBASE`, which means the launcher image itself is less protected against fixed-base assumptions. However, the inner virtualized Plasticity executable still has `DYNAMICBASE`, `HIGHENTROPYVA`, `NXCOMPAT`, and `GUARD_CF`.

`risk`: Even when absolute addresses are unstable because ASLR is enabled, mutable runtime state remains attackable as a class. Commodity dynamic instrumentation can search for values, object layouts, state transitions, strings, IPC messages, or module-relative patterns instead of relying on a single absolute address.

`risk`: In Electron, license state may exist in several places at once: main process JavaScript/V8 heap, renderer process heap, IPC payloads, local storage cache, native addon state, and UI view-model state. ASLR reduces fixed-address reliability, but it does not make mutable client-side authorization trustworthy.

## Vendor-Facing Conclusion

`risk`: A report should not depend on proving a stable address. The stronger claim is architectural: if authorization becomes a mutable client-side value such as `isValid`, `tier`, `expiresAt`, `canUseStudio`, or equivalent renderer/native state, then runtime tampering remains feasible even with ASLR.

`control`: Do not treat ASLR as a licensing control. ASLR is an exploit mitigation, not an authorization boundary.

`control`: Minimize long-lived mutable authorization state:

- derive permissions from an immutable `VerifiedLicenseContext`;
- bind that context to a process session and resource-integrity status;
- avoid exposing raw booleans over IPC;
- validate entitlements at command dispatch and native operation boundaries;
- fail closed on missing or malformed authorization context;
- log explicit denial states without revealing sensitive internals.

`control`: For anti-tamper evidence, measure resource integrity and startup integrity rather than trying to detect every memory editor. The goal is to make tampering non-portable, noisy, and unable to reach privileged commands.

## Suggested Report Language

`risk`: "Static mitigation review indicates the official executable and native addon use ASLR/DYNAMICBASE, so fixed absolute memory addresses are not expected to be stable across launches. However, this does not eliminate runtime-tampering risk. The security issue is the existence of mutable client-side enforcement state after cryptographic license verification. Attackers do not need to forge Ed25519 signatures if they can alter, replay, or mediate the local transition from verified claim to authorized command execution."

`control`: "The vendor should treat local memory as outside the trust boundary and enforce entitlements at operation boundaries using immutable verified claims, signed freshness, IPC hardening, native command checks, and signed resource manifests."

