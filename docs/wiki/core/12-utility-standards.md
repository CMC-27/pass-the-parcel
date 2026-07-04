---
type: "core"
name: "Utility Standards"
status: "stable"
dependencies: []
db_relations: []
description: "Architectural guardrails for deterministic mathematical calculations, floating-point safety, rounding precision, and data formatting."
---

# Utility Standards

This document establishes the strict mathematical, rounding, and data formatting standards applied across all modules. Because JavaScript natively uses IEEE 754 double-precision floats, explicit guardrails are required to prevent compounding rounding errors.

---

## 1. Core Calculation Formula(s)

The definitive [output] calculation logic must account for [describe the inputs and hierarchy]:

### [Primary Calculation Name]

$$\text{[Output]} = \text{[Input A]} \times \text{[Input B]} \times \text{[Input C]}$$

### [Secondary Calculation Name — if applicable]

$$\text{[Adjusted Output]} = \text{[Base Output]} \times (1 + \text{[Adjustment Rate]})$$

[Explain when each formula applies.]

---

## 2. Floating-Point Safety & Financial Math

**Rule: Never use native JavaScript floating-point arithmetic for currency, billing, or precise calculations.** (e.g., `0.1 + 0.2 === 0.30000000000000004`).

### The Decimal Protocol

For any calculation that affects pricing, billing audits, or precise measurements, use an arbitrary-precision library (e.g., `decimal.js` or `big.js`) OR use integer-based arithmetic:

```javascript
// Avoid native JS floats for financial data
const calculateTotal = (priceInCents, qty, taxRate) => {
  return Math.round(priceInCents * qty * (1 + taxRate));
};
```

---

## 3. Precision & Rounding Rules

All utility functions must explicitly define their rounding strategy.

### Numeric Outputs by Category

| Material / Data Category | Data Type | Rounding Strategy | Rationale |
| --- | --- | --- | --- |
| **[Discrete / Countable Items]** | Integer | `Math.ceil()` | [Rationale] |
| **[Continuous / Linear Materials]** | Float | To **2 decimal places** | [Rationale] |
| **[Volumetric / Weight Materials]** | Float | To **3 decimal places** | [Rationale] |
| **[Currency / Financial Values]** | Integer (Cents) | To **2 decimal places** (UI) | [Rationale] |

### Tie-Breaking (Banker's Rounding)

For statistical or cost projections over many line items, implement **Round Half to Even** (Banker's Rounding) to minimize cumulative error.

---

## 4. Formatting & Localization Standards

Formatting must be strictly separated from calculation. Calculations happen on raw numbers; formatting happens at the final render cycle.

### Numbers & Currency

Always use the native `Intl.NumberFormat` API:

```javascript
const formatCurrency = (amountInCents, currencyCode = '[DEFAULT_CURRENCY]') => {
  return new Intl.NumberFormat('[locale]', {
    style: 'currency',
    currency: currencyCode,
  }).format(amountInCents / 100);
};
```

### Dates and Times

Timezone drift is a critical risk.

* **Database Layer:** All dates MUST be stored in UTC as ISO 8601 strings or Unix timestamps.
* **Transport Layer:** APIs only accept and return UTC.
* **UI Layer:** Dates are parsed to the user's local timezone exclusively within the component.

---

## 5. Architectural Rules for Utility Functions

1. **Pure Functions Only:** Functions must be 100% deterministic. No side-effects, no mutations, no network calls.
2. **Immutability:** Never mutate input arrays or objects. Always return a new copy.
3. **Mandatory Type Guarding:** Validate inputs before executing math. Return explicit errors if `NaN`, `null`, or `undefined` is encountered.
