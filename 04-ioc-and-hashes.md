# 04 - IOC And Hashes

## Major Artifacts

`fact`: Hashes and signature status for major portable files:

| Path | Size | SHA-256 | Signature |
| --- | ---: | --- | --- |
| `portable-sample\Plasticity_25.2.8.exe` | 286,056,192 | `6E314BE68A5DD64B48F7D88365BCEC34847C2FDF14BC09EAC18F472C866B2390` | NotSigned |
| `portable-sample\DeleteTurbo\DeleteTurbo.bat` | 100 | `75B7350F6EC738E9EB426BB8D37B8DEE8025A74011DDF7FD8251871B53D81249` | UnknownError |
| `portable-sample\Plasticity\local\modified\@PROGRAMFILES@\Plasticity\Plasticity.exe` | 149,174,272 | `8179DB3C26143AEE62BF8CD0AA21ACBCA2841C58FE19A5CBCD98C7CEE529E4EC` | NotSigned |
| `portable-sample\Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\renderer\pk.node` | 32,108,032 | `27AEBDB1D51467FEE3D8D4E85D7C65D2C8B1962C6F4A15A5ED0A41B1CF681E4B` | NotSigned |
| `portable-sample\Plasticity\local\modified\@PROGRAMFILES@\Plasticity\ffmpeg.dll` | 2,789,376 | `E7714A1D6AC3F4C4AE22564B9CA301E486F5F42691859C0A687246C47B5CF5C9` | NotSigned |
| `portable-sample\Plasticity\local\modified\@PROGRAMFILES@\Plasticity\libGLESv2.dll` | 7,179,264 | `7897EB2441975523E3E78DBEABF2D9DEBA66534C69B6CEFBF87EA638EE641EA6` | NotSigned |

## Loader/Injection Artifacts

`fact`: Repeated JavaScript artifacts:

| File | Count | Size | SHA-256 |
| --- | ---: | ---: | --- |
| `loader.js` | 5 | 19,756 | `A493E0F4301AC2C4C633EF5A1E2192D60BB578833BAA2051AB882BDBA5AF7295` |
| `injector.js` | 5 | 27,711 | `4ED3D1A5CAA59642A5491887E7B2EC69B5AF7103DFA86C26394C55B9138B8937` |
| `gatekeeper.js` | 5 | 9,251 | `6788AFC6FAE72A7AC0D7087B3021461915C4B31907F52646275D93913922E5E7` |
| `AuthGuard.js` | 2 | 72,623 | `4FE627CDFAEC18B09FBC5159F39779699ADD3A9A8543F53CBD29A8DB1D3FF62C` |

`risk`: These are high-signal YARA/EDR-style indicators for this portable family, but they should not be treated as universal indicators of all piracy variants.

## Bytenode Artifacts In Portable Package

`fact`: Portable `.jsc` files:

| Path | Size | SHA-256 |
| --- | ---: | --- |
| `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\main\index.compiled.jsc` | 1,372,872 | `B5ED3DB326559B72508F408FFE458DB5EE16DA3AEEB14B9E1DF7E2A12F5216EE` |
| `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\renderer\app_window.compiled\index.jsc` | 10,894,072 | `9D0D30AD72976DE5CD6C3284AD750809A9F21F5663AB5057DFBA2B82DE919121` |
| `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\renderer\license_window.compiled\index.jsc` | 1,513,848 | `FE2968F7938C5471A327FEB9E1AD0F372DA4355C9D5B1D9DF4D836ADA1E6D6B5` |

## Wrapper Indicators

`fact`: Stub executables under `Plasticity\local\stubexe\...` are small files around 42,016 bytes and signed by `Code Systems Corporation`.

Observed names include:

- `cmd.exe`
- `ConsoleRender.exe`
- `msedge.exe`
- `net.exe`
- `net1.exe`
- `Plasticity.exe`
- `PlasticitySt.exe`
- `powershell.exe`
- `reg.exe`
- `timeout.exe`

`inference`: These are consistent with Turbo/Xenocode wrapper shims. They are useful as packaging indicators, not as standalone proof of malicious code.

## Path Indicators

`fact`: High-signal path fragments:

| Indicator | Meaning |
| --- | --- |
| `HKEY_CURRENT_USER\Software\Turbo` | registry state referenced by README/cleanup script |
| `Temp\TURBO` | temp state referenced by README/cleanup script |
| `Plasticity\local\stubexe\` | virtualization shim executables |
| `Plasticity\roaming\modified\@APPDATA@\Plasticity\` | bundled AppData profile |
| `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\` | virtualized Program Files image |
| `__Xenocode` | virtualization artifact |
| `plasticity-pcmc` | portable/mod framework package name |
| `main: loader.js` | redirected Electron startup entrypoint |

