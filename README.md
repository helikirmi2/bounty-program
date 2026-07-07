# Safe Studio Entitlement Canary Demo

This is a standalone toy demonstration for explaining the license-bypass class without touching Plasticity or any real Studio feature.

It models the dangerous pattern:

```text
signed claim -> client verification -> mutable runtime state -> Studio command gate
```

The demo shows two implementations:

- vulnerable flow: command trusts mutable renderer/runtime state;
- hardened flow: command ignores renderer state and validates signed entitlement at the command boundary.

## Run

```powershell
powershell -ExecutionPolicy Bypass -File .\safe-studio-canary-demo\Invoke-StudioEntitlementCanaryDemo.ps1
```

## What It Proves

It proves the class of bug:

`risk`: If a Studio command trusts mutable client-side state after license verification, a local mediator can cause a Studio-only command to execute without a signed Studio entitlement.

It does not prove Plasticity is vulnerable and does not enable Plasticity Studio.

## Safe Mapping To Plasticity

The equivalent real invariant for Plasticity should be:

> No Studio-only operation can execute unless the dispatcher or native operation layer validates immutable signed Studio entitlement at execution time.

If this invariant holds, renderer-state or IPC tampering should not enable Studio behavior.

