---
name: update-workspace-skills
description: Make sure to use this skill whenever the user mentions updating workspace skills, syncing skills to workspace, pulling global skills, ending a session to save skills, or when wrapping up work in this blueprint repository. This skill scans the skills present in the workspace `Skills` folder and updates them to match their latest versions in the global `.gemini` config skills folder.
---

# Syncing Global .gemini Skills to Workspace

This skill automates pulling the latest versions of documented skills from the user's global `.gemini` configuration into the active workspace's `Skills` directory. Run this at the end of a session to save any architectural blueprint changes.

## 1. Directory Structure
*   **Global Skills Source:** `~\.gemini\config\skills` (i.e., `$env:USERPROFILE\.gemini\config\skills` on Windows)
*   **Workspace Skills Destination:** The `Skills` directory in the current active workspace (e.g., `.\Skills` relative to the workspace root).

## 2. Synchronization Protocol

1.  **Identify Documented Skills:**
    Scan the workspace `Skills` directory to list all subdirectories currently present (e.g., `agent-wrap-up`, `Test-and-Deploy`, etc.).
2.  **Verify Global Equivalents:**
    For each skill subdirectory found in the workspace:
    *   Confirm it exists in `~\.gemini\config\skills\` (i.e., `$env:USERPROFILE\.gemini\config\skills\`).
    *   If it does not exist globally, log a warning (do not attempt to copy).
3.  **Perform Synchronization:**
    For each validated skill, copy all files and folders recursively from `~\.gemini\config\skills\<skill-name>\*` (i.e., `$env:USERPROFILE\.gemini\config\skills\<skill-name>\*`) to the active workspace `Skills\<skill-name>\` (e.g., `.\Skills\<skill-name>\`).
    *   Ensure target files are overwritten to match the global version exactly.
    *   Ensure any subfolders (e.g., `references/`, `evals/`) are fully copied.
4.  **Verification:**
    *   Run `git status` or `git diff` to view the updated skills.
    *   Check for any unexpected changes or untracked files.
