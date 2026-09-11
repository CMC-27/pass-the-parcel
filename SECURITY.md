# Security Policy

## Supported versions

Only the latest release of the template is supported. Fixes land on `main` and are tagged as a new release; there are no maintained long-term branches.

## What this repository is

Pass the Parcel is a **template** — planning skills, agent definitions, wiki governance, and shell/Python validation scripts. It ships no runtime service, no database, and no hosted endpoint. The realistic security surface is therefore:

- **Script execution** — the PowerShell sync/validation scripts and the Python wiki scripts run locally and in CI.
- **Secret hygiene** — the machinery must never require or embed credentials. The wiki claims layer is deliberately secret-free (drift *detection* only).
- **Supply chain** — additions to CI workflows or script dependencies.

## Reporting a vulnerability

Please **do not** open a public issue for a security problem. Use GitHub's private vulnerability reporting:

1. Go to the **Security** tab of this repository.
2. Click **Report a vulnerability**.
3. Include: affected file(s), a description of the issue, reproduction steps, and the impact you believe it has.

You will get an acknowledgement as soon as a maintainer is available. Please allow time for a fix and a coordinated disclosure before publishing details.

## Out of scope

- Vulnerabilities in third-party tools you point at this template (your own GitHub org, your own agent runtime).
- Issues that require an attacker to already have write access to the repository.
- Template content that is informational only (for example, guidance in `AGENTS.md`).
