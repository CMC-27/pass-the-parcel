---
type: "core"
name: "External Integrations"
status: "in-progress"
dependencies: []
db_relations: []
description: "Documents all external data exchange points, field mapping tables, import/export specs, and integration protocols."
---

# External Integrations

This document centralizes data mapping and exchange points between the application and external systems.

---

## 1. [Import Integration Name] — Ingestion Map

The application ingests [describe source data format and origin] using `[parserUtil].js`.

| CSV / Source Field | Internal DB Column | Data Type | Parsing & Validation Rules |
| :--- | :--- | :--- | :--- |
| `[Source Field 1]` | `[db_column_1]` | `TEXT` | [Validation rule] |
| `[Source Field 2]` | `[db_column_2]` | `TEXT` | [Validation rule] |
| `[Source Field 3]` | `[db_column_3]` | `TEXT` | [Validation rule] |
| `[Source Field 4]` | `[db_column_4]` | `UUID` | [Validation rule] |
| `[Source Field 5]` | `[db_column_5]` | `FLOAT8` | [Validation rule] |

**Parser:** `src/utils/[parserUtil].js`
**Trigger:** [When is this ingestion triggered?]

---

## 2. [Export Integration Name] — Export Spec

To sync with [external system], the application generates [format]:

* **Format:** [CSV / JSON / XLSX]
* **Trigger:** [When is this export triggered?]
* **Columns Mapped:**

| Export Column | Source Field | Transformation |
| :--- | :--- | :--- |
| `[Export Column 1]` | `[db_column]` | [None / calculation / formatting rule] |
| `[Export Column 2]` | `[db_column]` | [None / calculation / formatting rule] |
| `[Export Column 3]` | `[db_column]` | [None / calculation / formatting rule] |
| `[Export Column 4]` | `[db_column]` | [None / calculation / formatting rule] |

---

## 3. [Third-Party API Integration Name] *(if applicable)*

* **Provider:** [Provider name]
* **Auth Method:** [How auth is passed]
* **Endpoints Used:**
  * `[METHOD] [endpoint]` — [Purpose]
  * `[METHOD] [endpoint]` — [Purpose]
* **Field Mapping:**

| Internal Field | API Parameter | Notes |
| :--- | :--- | :--- |
| `[internal_field]` | `[api_parameter]` | [Notes] |

---

## 4. Integration Guardrails

* **Secrets Management:** All API keys MUST be stored in environment variables. Verify `.gitignore` excludes `.env` before committing.
* **Rate Limiting:** All outbound API calls must be rate-limited or queued.
* **Error Handling:** All integration calls must be wrapped in `try/catch`. Surface user-friendly error messages.
* **Idempotency:** Import operations must be idempotent (use upsert strategies, not blind inserts).
