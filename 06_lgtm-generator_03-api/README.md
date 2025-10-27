# LGTM Generator with HTTP

This is the LGTM generator from Chapter 6, upgraded to fetch phrases from a real HTTP server instead of generating them randomly.

## Running the Example

### 1. Start the server

The server provides random LGTM phrases and deliberately fails sometimes (20% of requests) to help practice error handling:

```bash
node server.js
```

This starts the server on `http://localhost:3000`.

### 2. Compile the Elm code

In a separate terminal:

```bash
elm make src/Main.elm --output=elm.js
```

### 3. Open in browser

Open `index.html` in your browser. Click the refresh button (⟳) to fetch new phrases from the server.

## What You'll See

- Most clicks will fetch a new LGTM phrase successfully
- Occasionally you'll see "Http error: 500" when the server deliberately fails
- While waiting for the server, you'll see "Loading..." briefly

## Key Concepts

- **HTTP Commands**: Using `Http.get` to make requests
- **Result Types**: Handling both `Ok` and `Err` cases
- **Custom Types for State**: The `Phrase` type makes impossible states impossible
- **Error Handling**: Pattern matching on `Http.Error` to show appropriate messages

## Dependencies

This example uses:
- `elm/http` for HTTP requests
- `elm/random` (from Chapter 5, though not used in this version)
- Node.js for the simple test server
