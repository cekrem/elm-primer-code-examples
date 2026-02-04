# Articles SPA - Chapter 13 Example

A simple single-page application demonstrating Elm routing and navigation.

## Running the Example

### 1. Start the API server

```bash
cd server
npm install
npm start
```

The server runs at http://localhost:3001

### 2. Build and serve the Elm app

```bash
# Build the Elm code
elm make src/Main.elm --output=elm.js

# Serve with any static server, e.g.:
npx serve .
# or
python -m http.server 8000
```

Then open http://localhost:8000 (or whatever port your server uses).

## What This Demonstrates

- **Browser.application**: Full SPA with URL handling
- **Route parsing**: Using `Url.Parser` with `oneOf`
- **Route building**: Using `Url.Builder` for type-safe links
- **Sub-models per route**: Each page has its own Model/Msg/update/view
- **RemoteData pattern**: Loading states for HTTP requests
- **Query parameters**: Search page uses `?q=` parameter
- **404 handling**: NotFound route for invalid URLs

## Project Structure

```
src/
├── Main.elm          # Browser.application, routing orchestration
├── Route.elm         # Route type, parser, URL builder
├── Api.elm           # Article types, HTTP requests
└── Page/
    ├── Home.elm      # Article list
    ├── Article.elm   # Single article view
    ├── Search.elm    # Search with client-side filtering
    └── NotFound.elm  # 404 page
```
