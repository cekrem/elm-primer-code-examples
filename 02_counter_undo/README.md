# Counter with Undo

A simple counter that demonstrates The Elm Architecture with history tracking and undo functionality.

## Features

- Increment and decrement a counter
- Undo to previous values
- Reset to initial state
- Visual history tracking

## Running the Example

### Option 1: Using elm reactor (simplest)

```bash
elm reactor
```

Then open http://localhost:8000 and click on `src/Main.elm`

### Option 2: Compile and open in browser

```bash
elm make src/Main.elm --output=main.js
open index.html
```

### Option 3: Live development server

```bash
elm-live src/Main.elm -- --output=main.js
```

## What This Example Teaches

This example demonstrates:

1. **Model** - State with both current value and history
2. **Msg** - Four distinct actions (Increment, Decrement, Undo, Reset)
3. **update** - Pattern matching on messages and nested pattern matching on history
4. **view** - Pure function rendering based on model

It shows how The Elm Architecture handles:
- State management (current count)
- History tracking (list of previous values)
- Conditional logic (undo only works if history exists)
- State reset (returning to initial state)

## Concepts Covered

- Type aliases for records
- Union types for messages
- Pattern matching on messages
- Pattern matching on lists
- Record update syntax (`{ model | field = value }`)
- List operations (`::`  for prepending)
- Pure functions (init, update, view)

This is the example used in Chapter 2: "The Elm Architecture: A Recipe for Reliable Apps"
