---
name: update-global-skills
description: Make sure to use this skill whenever the user mentions updating global skills, syncing workspace skills to .gemini, pushing workspace skills, starting a session, or when initializing work in this blueprint repository. This skill copies the skills present in the workspace `Skills` folder to the global `.gemini` config skills folder, ensuring the agent's runtime environment has the workspace's version of the skills.
---

# Syncing Workspace Skills to Global .gemini Config

This skill automates pushing the skills from the active workspace's `Skills` directory into the user's global `.gemini` config directory. Run this at the start of a session to ensure the runtime environment has the latest workspace versions.

## 1. Directory Structure
*   **Workspace Skills Source:** The `Skills` directory in the current active workspace (e.g., `.\Skills` relative to the workspace root).
*   **Global Skills Destination:** `~\.gemini\config\skills` (i.e., `$env:USERPROFILE\.gemini\config\skills` on Windows)

## 2. Synchronization Protocol

1.  **Identify Workspace Skills:**
    Scan the workspace `Skills` directory to list all subdirectories currently present (e.g., `agent-wrap-up`, `Test-and-Deploy`, etc.).
2.  **Perform Synchronization:**
    For each skill subdirectory found in the workspace, copy all files and folders recursively from the active workspace `Skills\<skill-name>\*` (e.g., `.\Skills\<skill-name>\*`) to the global directory `~\.gemini\config\skills\<skill-name>\` (i.e., `$env:USERPROFILE\.gemini\config\skills\<skill-name>\` on Windows).
    *   Ensure target files in the `.gemini` config directory are overwritten.
    *   Ensure subfolders (e.g., `references/`, `evals/`) are fully copied.
3.  **Verification:**
    *   Verify the copy operation completed successfully by listing files or checking sizes.
    *   Ensure no permissions issues prevented writing to the `.gemini` config directory.
