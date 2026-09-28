# scripts/lib — the sync engine's dot-sourced modules

`scripts/sync-architecture.ps1` stays the entry point: it holds the `param()` block, the CLI
dispatch and the run's orchestration (verify-only, pre-flight, copy, stamp, bindings, post-sync
verification). Everything else lives here, dot-sourced by explicit path in dependency order —
**manifest → bindings → migrate → run → prune → prefix → verify → selftest → selftest-fixtures**.

| Module | Owns |
|---|---|
| `sync-manifest.ps1` | `Read-Manifest`, the hashing helpers, the version bookkeeping helpers, and the `-Check` verdict emitters (`Add-Verdict`, `Compare-Item`) |
| `sync-bindings.ps1` | The Model Registry force-propagation over the three binding surfaces, and the write-guard's host-monotone candidate verdict (`Test-JsonShape`, beside `Find-MatchingBrace`) |
| `sync-migrate.ps1` | The `opencode.json` key-shape migration of `T1-E1.05` — the `skills` flat-array rewrite and the root-scoped member delete, under one re-parse-and-revert guard |
| `sync-run.ps1` | The profile-aware run path: the `-Check` drift report (and its exit codes) and the surface copy (dirs, effective skills, files, then the prune plan) |
| `sync-prune.ps1` | The prune plan — `PRUNE` verdict, `DRYRUN would prune`, the delete |
| `sync-prefix.ps1` | PREFIX-LOCKED prefix regeneration / check-only, inside the target |
| `sync-verify.ps1` | `Invoke-StructuralVerify`, `Invoke-VerificationGates` |
| `sync-selftest.ps1` | The `-SelfTest` harness: the throwaway target, `Invoke-CapturedChild` (with the F3 self-check that no direct child launch sits outside it) and the transport-contract fixtures |
| `sync-selftest-fixtures.ps1` | The `-SelfTest` capability fixture families, in the order they were added: retirement transport, the ordering-aware counter, the claims smoke, the skill tier, the key-shape migration |

**Every module is declared in `.devops/sync-manifest.yaml` `portable_files`** — a partial split
ships a satellite a broken engine, and `-SelfTest`'s manifest-mirror assertions catch a miss.

**Parameters, not `$PSScriptRoot`:** inside a dot-sourced file `$PSScriptRoot` resolves to
`scripts/lib`, not the repo root, so each function receives `$SrcRoot` / `$TgtRoot` (and
`$ShellExe` where it re-invokes a gate) as parameters. The self-test harness additionally
receives the **entry** path as `-EntryPath` — a module's own path is not the entry's — which is
the path its judged child re-invocations launch; `-HarnessPath` is this module's own file, which
is the text its F3 self-check scans for a direct child launch. Dot-sourcing shares the entry
script's scope, so script-scope state the modules cooperatively use (`$script:verdicts`,
`$script:fail`, `$shellExe`) resolves exactly as it did before the split.
