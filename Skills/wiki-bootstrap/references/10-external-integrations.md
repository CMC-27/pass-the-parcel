---
type: "core"
name: "External Integrations"
status: "in-progress"
dependencies: ["util-csv-parser", "util-[domain]-parser"]
db_relations: ["[primary_table]", "[secondary_table]"]
description: "Documents all external data exchange points, field mapping tables, import/export specs, and integration protocols for [APP_NAME]."
---

# External Integrations

This document centralizes data mapping and exchange points between [APP_NAME] and external systems.

---

## 1. [Import Integration Name] — Ingestion Map

[APP_NAME] ingests [describe the source data format and origin — e.g., "high-volume engineering plans via a standard CSV format"] using `[parserUtil].js`.

| CSV / Source Field | Internal DB Column | Data Type | Parsing & Validation Rules |
| :--- | :--- | :--- | :--- |
| `[Source Field 1]` | `[db_column_1]` | `TEXT` | [Validation rule — e.g., "Unique identifier per project scope."] |
| `[Source Field 2]` | `[db_column_2]` | `TEXT` | [Validation rule — e.g., "Mapped to lookup categories. Must match a registered value."] |
| `[Source Field 3]` | `[db_column_3]` | `TEXT` | [Validation rule — e.g., "Primary descriptive label. No constraints."] |
| `[Source Field 4]` | `[db_column_4]` | `UUID` | [Validation rule — e.g., "Resolves to a registered template ID."] |
| `[Source Field 5]` | `[db_column_5]` | `FLOAT8` | [Validation rule — e.g., "Decimal coordinate; validated range -90 to 90."] |

**Parser:** `src/utils/[parserUtil].js`
**Trigger:** [When is this ingestion triggered? — e.g., "Step 2 of the Import Wizard after file upload."]

---

## 2. [Export Integration Name] — Export Spec

To sync with [external system — e.g., ERP, finance, warehouse management], [APP_NAME] generates [format — e.g., an agnostic flat CSV structure]:

* **Format:** [CSV / JSON / XLSX]
* **Trigger:** [When is this export triggered? — e.g., "Approved budget export from the PM Workspace."]
* **Columns Mapped:**

| Export Column | Source Field | Transformation |
| :--- | :--- | :--- |
| `[Export Column 1]` | `[db_column]` | [None / calculation / formatting rule] |
| `[Export Column 2]` | `[db_column]` | [None / calculation / formatting rule] |
| `[Export Column 3]` | `[db_column]` | [None / calculation / formatting rule] |
| `[Export Column 4]` | `[db_column]` | [None / calculation / formatting rule] |

---

## 3. [Third-Party API Integration Name] *(if applicable)*

* **Provider:** [Provider name — e.g., Google Maps, Stripe, SendGrid]
* **Auth Method:** [How auth is passed — e.g., "API key via `VITE_[PROVIDER]_API_KEY` environment variable. Never hardcoded."]
* **Endpoints Used:**
  * `[METHOD] [endpoint]` — [Purpose]
  * `[METHOD] [endpoint]` — [Purpose]
* **Field Mapping:**

| Internal Field | API Parameter | Notes |
| :--- | :--- | :--- |
| `[internal_field]` | `[api_parameter]` | [Notes] |

---

## 4. Integration Guardrails

* **Secrets Management:** All API keys and credentials MUST be stored in environment variables (`.env`). Verify `.gitignore` excludes `.env` before committing.
* **Rate Limiting:** All outbound API calls must be rate-limited or queued to prevent exceeding provider quotas.
* **Error Handling:** All integration calls must be wrapped in `try/catch`. Surface user-friendly error messages; do not expose raw API error details to the client.
* **Idempotency:** Import operations must be idempotent. Running the same import twice should produce the same result (use upsert strategies, not blind inserts).
