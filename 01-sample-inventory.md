# 01 - Sample Inventory

## Scope

`fact`: Sample root: `D:\Programs\plasticity codex\portable-sample`.

`fact`: Clean installed baseline available in the workspace: `D:\Programs\plasticity codex\app-26.1.3`.

`fact`: The portable package contains an executable named `Plasticity_25.2.8.exe`, while the clean installed baseline is Plasticity `26.1.3`. Treat direct byte comparison as version-mismatched until an official 25.2.8 installer is available.

## Top-Level Structure

`fact`: Top-level entries observed:

| Path | Meaning |
| --- | --- |
| `portable-sample\Plasticity_25.2.8.exe` | large unsigned portable launcher/executable |
| `portable-sample\Plasticity\` | virtualized filesystem/profile tree |
| `portable-sample\resources\` | duplicated resources and mod/loader content |
| `portable-sample\DeleteTurbo\DeleteTurbo.bat` | cleanup script for Turbo registry/temp artifacts |
| `portable-sample\README.txt` | portable package notes |

`fact`: File count and size:

| Metric | Value |
| --- | ---: |
| Files | 621 |
| Total size | 904,569,665 bytes |
| Total size | 862.66 MiB |

## Extension Distribution

`fact`: Top extensions by file count:

| Extension | Count |
| --- | ---: |
| `.lnk` | 202 |
| `.json` | 127 |
| `.js` | 69 |
| `.__meta__` | 65 |
| no extension | 29 |
| `.dll` | 18 |
| `.mp4` | 16 |
| `.exe` | 15 |
| `.manifest` | 13 |
| `.webp` | 10 |
| `.png` | 6 |
| `.dmp` | 5 |
| `.txt` | 5 |
| `.log` | 5 |
| `.css` | 4 |
| `.jsc` | 3 |

`inference`: The high count of `.lnk`, `.__meta__`, `.__deleted__`, virtualized AppData paths, and stub executables is consistent with an application virtualization/container format rather than a normal Squirrel/Electron install tree.

## Virtualization Indicators

`fact`: The sample contains virtualized path markers such as:

| Marker | Example |
| --- | --- |
| `@APPDATA@` | `Plasticity\roaming\modified\@APPDATA@\Plasticity\...` |
| `@APPDATALOCAL@` | `Plasticity\local\modified\@APPDATALOCAL@\...` |
| `@PROGRAMFILES@` | `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\...` |
| `@WINDIR@` | present in virtualized trees |
| `__Xenocode` | present under virtualized app paths |
| `stubexe` | `Plasticity\local\stubexe\...` |

`fact`: `README.txt` states that after closing Plasticity, Turbo state remains in `HKEY_CURRENT_USER\Software\Turbo` and in a Temp `TURBO` folder. `DeleteTurbo.bat` attempts to remove those artifacts.

`inference`: The portable launcher likely relies on Turbo/Xenocode-style filesystem and registry virtualization, including shim executables and redirected user profile state.

## Electron Metadata

`fact`: Clean Plasticity 26.1.3 package metadata:

| Field | Value |
| --- | --- |
| `name` | `Plasticity` |
| `productName` | `Plasticity` |
| `version` | `26.1.3` |
| `main` | `.webpack/main` |

`fact`: Portable package metadata appears in multiple duplicated `package.json` files:

| Path | name | version | main |
| --- | --- | --- | --- |
| `Plasticity\resources\.app\package.json` | `plasticity-pcmc` | `Plasticity` | `loader.js` |
| `Plasticity\resources\app\package.json` | `plasticity-pcmc` | `Plasticity` | `loader.js` |
| `resources\.app\package.json` | `plasticity-pcmc` | `26.1.0-beta6` | `loader.js` |
| `resources\.app\resources\app\package.json` | `plasticity-pcmc` | `app` | `loader.js` |
| `resources\app\package.json` | `plasticity-pcmc` | `Plasticity_25.2.8_Win64_Portable` | `loader.js` |

`inference`: The portable package redirects Electron startup from the official `.webpack/main` entrypoint to a third-party `loader.js` entrypoint in several duplicated app-resource trees.

## Bytenode Artifacts

`fact`: The portable package contains three `.jsc` files:

| Path | Size | SHA-256 |
| --- | ---: | --- |
| `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\main\index.compiled.jsc` | 1,372,872 | `B5ED3DB326559B72508F408FFE458DB5EE16DA3AEEB14B9E1DF7E2A12F5216EE` |
| `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\renderer\app_window.compiled\index.jsc` | 10,894,072 | `9D0D30AD72976DE5CD6C3284AD750809A9F21F5663AB5057DFBA2B82DE919121` |
| `Plasticity\local\modified\@PROGRAMFILES@\Plasticity\resources\app\.webpack\renderer\license_window.compiled\index.jsc` | 1,513,848 | `FE2968F7938C5471A327FEB9E1AD0F372DA4355C9D5B1D9DF4D836ADA1E6D6B5` |

`fact`: Clean installed 26.1.3 `.jsc` hashes:

| Path | Size | SHA-256 |
| --- | ---: | --- |
| `app-26.1.3\resources\app\.webpack\main\index.compiled.jsc` | 2,076,120 | `6E233226729A000B5F31E04371E7E5367230F11FAD29EEABD8517C9888B4419A` |
| `app-26.1.3\resources\app\.webpack\renderer\app_window.compiled\index.jsc` | 11,996,760 | `983FDF2BBA24B1EE34B0CD897E2C70296747163C0E14E481903D33A4B4C19D50` |
| `app-26.1.3\resources\app\.webpack\renderer\license_window.compiled\index.jsc` | 2,325,208 | `873078E0421611A1FB84F0323B110D41079C12B1AAB9A2A051C462A7068AA8D1` |

`inference`: The `.jsc` hash mismatch is expected because the compared versions differ. The stronger portable-specific evidence is the changed Electron entrypoint and wrapper artifacts, not a 25.2.8-to-26.1.3 byte delta.

