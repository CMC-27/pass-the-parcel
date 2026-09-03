---
name: test-and-deploy
description: Make sure to use this skill whenever the user mentions running tests, executing npm tests, checking lint rules, linting, code formatting, git pushing, pushing to GitHub, or deploying commits to the remote repository. This skill ensures a secure pre-push pipeline by validating tests and linter output prior to any git push.
version: 2
updated: 2026-09-03
---

# NPM Test, Lint, and GitHub Deployment Pipeline

Follow this systematic procedure to safely validate code and push verified changes to the remote GitHub repository.

## 0. Prerequisites (One-time Setup)
After cloning or running `npm install`, verify the pre-commit hook is active:
* Check `.husky/pre-commit` exists and contains `npx lint-staged`.
* The `husky` + `lint-staged` devDependencies are in `package.json`. If missing, run: `npm install -D husky lint-staged && npx husky init` and write `npx lint-staged` to `.husky/pre-commit`.
* The pre-commit hook automatically runs `eslint --fix` on staged `.ts`/`.tsx` files before every commit, preventing lint errors from reaching CI.

## 1. Environment and Script Verification
Before executing any test or git command, verify the target project environment has the necessary tools:
* Check `package.json` to ensure the `test` and `lint` scripts are defined under `"scripts"`.
* Verify that Git is initialized (`git status`) and a remote origin repository is configured (`git remote -v`).

## 2. Test and Lint Phase
Run tests and linting to ensure zero regressions or formatting errors exist before code leaves the developer environment. **Lint, tests, and build (§3) are independent — run them concurrently** (PowerShell 5.1: use `Start-Job`; never `&&`). This cuts wall-clock time from the sum of all three to the longest single one, and prevents token overrun by design:

1. Launch all three as background jobs. Redirect each stream's full output to a log file (e.g. `.agent-logs/lint.log`, `test.log`, `build.log`); return only a pass/fail flag per job.
2. Poll each job **once** at completion — never stream or repeatedly poll output. That polling discipline is what prevents overrun, not call count.
3. **Lint Verification** (`npm run lint`): if there are fixable lint errors, run `npm run lint -- --fix` (or the equivalent project command), then re-verify. If non-fixable errors persist, read `lint.log`, halt the execution, present the logs to the user, and prompt them to resolve the errors.
4. **Unit & Integration Tests** (`npm test` or `npm run test`): on failure, read `test.log`, do NOT proceed. Halt execution, print the failure details, and prompt for bug remediation.

## 3. Build Verification
Run the build locally to catch issues before they fail in CI. Under the §2 concurrency model this job is already running alongside lint and tests — do not re-run it; just check its result:
1. **Build Verification**: on failure, read `build.log`, halt, and prompt the user to fix TypeScript or bundler errors.

## 4. Version Increment Phase
Before staging and committing, you MUST check and bump the version in `package.json` following the project's **3-Level Versioning Strategy**:
1. **Read Current Version**: Retrieve the current `"version"` value from `package.json`.
2. **Determine/Select Increment Level**: Default to **Level 3 (Patch) silently** — do not prompt. Only ask the user which level should be bumped when they explicitly signal a feature or breaking release, or when the session clearly shipped a new user-facing feature:
   * **Level 1 (Major)**: User-directed primary versions (e.g., `1.02.003` -> `2.00.000`). Resets minor and patch levels to double/triple zero padding.
   * **Level 2 (Minor)**: New feature versions (e.g., `1.02.003` -> `1.03.003`). Increments the minor level by 1, while preserving the patch level as-is.
   * **Level 3 (Patch)**: Routine deployment versions (e.g., `1.02.003` -> `1.02.004`). Increments the patch level by 1, while preserving the minor level as-is. If the user does not request a Major or Minor bump, increment this automatically.
3. **Update Files**: 
   * Write the updated version string back to the `"version"` field in `package.json`.
   * Append a new row to the **Release Log** table in `.devops/logs/version-history.md` detailing the new version, current date, increment level, deployer name/model, and primary release highlights.
4. **Trace Version**: Ensure the new version (formatted e.g. `V1.2.3` or `1.2.3`) is prominently displayed in the commit message and noted in the agent changelog.

## 5. Git Staging & Local Commits
Only proceed to Git staging and committing after a 100% clean pass of linting, tests, and build, and after successfully incrementing the version:
1. Run `git status` to identify modified, deleted, or untracked files.
2. Stage appropriate changes using selective staging (`git add <file>`) or full directory staging (`git add .`) depending on the context of modifications. Ensure the modified `package.json` and `.devops/logs/version-history.md` are staged!
3. Formulate a highly informative, structured commit message summarizing the changes (following any workspace-specific logging rules, such as `AGENTS.md` guidelines or standard conventional commits) and include the updated version.
4. Run `git commit -m "<message>"`.

## 6. GitHub Push
Push the local verified commits to the active branch on the remote repository. **You MUST ask the user for explicit permission before pushing.** Never push automatically.
1. Summarize what will be pushed: the branch name, number of commits, and a brief description of changes.
2. Ask the user: "Ready to push to GitHub?" and wait for their confirmation.
3. Only after the user confirms, retrieve the active branch name using `git branch --show-current`.
4. Push changes: `git push origin <branch-name>`.
5. Confirm the push command prints success, and report the successful deployment to the user.
