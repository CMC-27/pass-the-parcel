---
type: "core"
name: "Utility Standards"
status: "stable"
dependencies: ["[math-library]", "[date-library]"]
db_relations: []
description: "Architectural guardrails for deterministic mathematical calculations, floating-point safety, rounding precision, and data formatting in [APP_NAME]."
---

# 🧮 Utility Standards

This document establishes the strict mathematical, rounding, and data formatting standards applied across all modules. Because JavaScript natively uses IEEE 754 double-precision floats, explicit guardrails are required to prevent compounding rounding errors in engineering and financial data.

---

## 1. Core Calculation Formula(s)

The definitive [output] calculation logic inside `[calculator].js` must account for [describe the inputs and any multiplicative hierarchy]:

### [Primary Calculation Name]

$$\text{[Output]} = \text{[Input A]} \times \text{[Input B]} \times \text{[Input C]}$$

### [Secondary Calculation Name — if applicable, e.g., waste/scrap factor]

$$\text{[Adjusted Output]} = \text{[Base Output]} \times (1 + \text{[Adjustment Rate]})$$

*[Explain when each formula applies — e.g., "Use the adjusted formula for continuous/linear materials; use the base formula for discrete countable items."]*

---

## 2. Floating-Point Safety & Financial Math

**Rule: Never use native JavaScript floating-point arithmetic for currency, billing, or precise engineering calculations.** (e.g., `0.1 + 0.2 === 0.30000000000000004`).

### The Decimal Protocol

For any calculation that affects pricing, billing audits, or precise material cuts, use an arbitrary-precision library (e.g., `decimal.js` or `big.js`) OR use integer-based arithmetic:

```javascript
// ❌ BAD: Native JS floats will cause fractional leaks over time
const totalCost = itemPrice * quantity * taxRate;

// ✅ GOOD: Using integer arithmetic (e.g., cents) for financial data
const calculateTotal = (priceInCents, qty, taxRate) => {
  return Math.round(priceInCents * qty * (1 + taxRate));
};
```

---

## 3. Precision & Rounding Rules

All utility functions must explicitly define their rounding strategy. Implicit type coercion or accidental truncation is treated as a severe bug.

### Numeric Outputs by Category

| Material / Data Category | Data Type | Rounding Strategy | Rationale |
| --- | --- | --- | --- |
| **[Discrete / Countable Items]** | Integer | `Math.ceil()` | [Rationale — e.g., "Items packed individually cannot be fractional. Always round up."] |
| **[Continuous / Linear Materials]** | Float | To **2 decimal places** | [Rationale — e.g., "Fractional dimensions for cable, pipe, etc."] |
| **[Volumetric / Weight Materials]** | Float | To **3 decimal places** | [Rationale — e.g., "Precision required for volume or mass."] |
| **[Currency / Financial Values]** | Integer (Cents) | To **2 decimal places** (UI) | [Rationale — e.g., "Stored as raw integers. Formatted only at UI layer."] |

### Tie-Breaking (Banker's Rounding)

When calculating large aggregates, standard `Math.round` biases upwards. For statistical or cost projections over many line items, utility functions should implement **Round Half to Even** (Banker's Rounding) to minimize cumulative error.

---

## 4. Formatting & Localization Standards

Formatting must be strictly separated from calculation. Calculations happen on raw numbers; formatting happens at the final render cycle.

### Numbers & Currency

Always use the native `Intl.NumberFormat` API:

```javascript
// ✅ GOOD: Locale-aware currency formatting
const formatCurrency = (amountInCents, currencyCode = '[DEFAULT_CURRENCY]') => {
  return new Intl.NumberFormat('[locale]', {
    style: 'currency',
    currency: currencyCode,
  }).format(amountInCents / 100);
};
```

### Dates and Times

Timezone drift is a critical risk in distributed operations.

* **Database Layer:** All dates MUST be stored in UTC format as ISO 8601 strings (e.g., `2026-01-01T00:00:00Z`) or Unix timestamps.
* **Transport Layer:** APIs only accept and return UTC.
* **UI Layer:** Dates are parsed and converted to the user's local timezone exclusively within the React component. Use a lightweight utility like `date-fns` or `Intl.DateTimeFormat`.

---

## 5. Architectural Rules for Utility Functions

1. **Pure Functions Only:** Functions inside `/utils` must be 100% deterministic. Given the same inputs, they must return the exact same output. They must not cause side-effects, mutate external state, or make network calls.
2. **Immutability:** Never mutate the arrays or objects passed into a utility function. Always return a new copy.
3. **Mandatory Type Guarding:** Utility functions must validate that their inputs are actually numbers (or parseable strings) before executing math. Return explicit errors or fallback values if `NaN`, `null`, or `undefined` is encountered to prevent crashes.
