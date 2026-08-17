---
type: "core"
name: "Version History"
status: "stable"
description: "Formal release log and 3-level versioning strategy for the application."
---

# Version History & Policy

This log records the formal releases, deployments, and the 3-level versioning strategy enforced across the application.

## 📌 Versioning Strategy (3-Level System)

All versioning follows the semantic hierarchy configured within the `/Test-and-Deploy` pipeline:

1. **Level 1 (Major)**: User-directed primary versions (e.g., `1.02.003` -> `2.00.000`). Triggered for fundamental architectural updates, paradigm shifts, or major product milestones. Resets both minor and patch levels to double/triple zero padding.
2. **Level 2 (Minor)**: New feature versions (e.g., `1.02.003` -> `1.03.003`). Adds `.01` to Level 2 versioning (allowing up to 99 level 2 versions), while preserving the patch level as-is. Prompted and confirmed when introducing discrete new features, capabilities, or major screen flows.
3. **Level 3 (Patch)**: Automated deployment versions (e.g., `1.02.003` -> `1.02.004`). Adds `.001` to Level 3 versioning (allowing up to 999 level 3 versions), while preserving the minor level as-is. Automatically bumped on every routine code deployment or patch push if no major/minor bump is specified.

---

## 📈 Release Log

| Version | Date | Level | Deployer | Key Release Highlights / Milestones |
|---|---|---|---|---|
| **v0.1.0** | 2026-08-18 | Patch | deepseek-v4-flash | Parcel orchestration overhaul: High-Visionary Phase 4 (no code snippets), Grumpy Architect → Spec & Logic Audit (Phase 5), Smooth Operator Phase 6, Code Surgeon single-pass direct-to-disk (Phases 7-8), deterministic `PHASE_4_REVISION` rejection loop at Gate C, canonical model registry (mimo-2.5 / v4-flash-max / deepseek-v4-flash), PREFIX-LOCKED cache enforcement (.gitattributes + check scripts + pre-commit hook). |
| **v1.0.0** | YYYY-MM-DD | Major | [Deployer Name] | Initial stable release of the unified ecosystem. |
