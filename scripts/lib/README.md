# scripts/lib — the sync engine's dot-sourced modules

`scripts/sync-architecture.ps1` stays the entry point: it holds the `param()` block, the CLI
dispatch, the sync copy path and the `-SelfTest` body (which re-invokes `$PSCommandPath`, so it
must stay entry-scoped). Everything else lives here, dot-sourced by explicit path in dependency
order — **manifest → bindings → prune → prefix → verify**.

| Module | Owns |
|---|---|
| `sync-manifest.ps1` | `Read-Manifest`, the hashing helpers, the version bookkeeping helpers, and the `-Check` verdict emitters (`Add-Verdict`, `Compare-Item`) |
| `sync-bindings.ps1` | The Model Registry force-propagation over the three binding surfaces |
| `sync-prune.ps1` | The prune plan — `PRUNE` verdict, `DRYRUN would prune`, the delete |
| `sync-prefix.ps1` | PREFIX-LOCKED prefix regeneration / check-only, inside the target |
| `sync-verify.ps1` | `Invoke-StructuralVerify`, `Invoke-VerificationGates` |

**Every module is declared in `.devops/sync-manifest.yaml` `portable_files`** — a partial split
ships a satellite a broken engine, and `-SelfTest`'s manifest-mirror assertions catch a miss.

**Parameters, not `$PSScriptRoot`:** inside a dot-sourced file `$PSScriptRoot` resolves to
`scripts/lib`, not the repo root, so each function receives `$SrcRoot` / `$TgtRoot` (and
`$ShellExe` where it re-invokes a gate) as parameters. Dot-sourcing shares the entry script's
scope, so script-scope state the modules cooperatively use (`$script:verdicts`, `$shellExe`)
resolves exactly as it did before the split.
