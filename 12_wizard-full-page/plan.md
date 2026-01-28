# Wizard Architecture Plan

## Goal
Model a multi-step wizard that teaches:
- Nested state
- Opaque types
- Union types encoding workflow states
- Ruling out impossible states

## Structure

```elm
type Model
    = Welcome
    | ReportBug Bug.Model
    | RequestFeature Feature.Model
    | Confirm Submittable
```

## Key Design Decisions

### Generic `Confirm` step
`Confirm` holds a `Submittable` - an opaque type from the API layer that's agnostic about its origin (bug or feature).

### Sub-modules own their state
`Bug` and `Feature` modules each:
- Have their own `Model`, `Msg`, `update`, `view`
- Handle their own internal steps and validation
- Expose `toSubmittable : Model -> Maybe Submittable`

### Opaque `Submittable` type
Lives in an API module. Both wizard paths produce one. The confirm step doesn't know or care where it came from - it just displays and submits it.

## Module Responsibilities

| Module | Responsibility |
|--------|----------------|
| Main | Top-level routing between wizard phases |
| Bug | Multi-step bug report flow, internal state |
| Feature | Multi-step feature request flow, internal state |
| Api | `Submittable` type, submission logic |

## Teaching narrative
"The type represents what something *is* (ready to submit), not where it *came from*."
