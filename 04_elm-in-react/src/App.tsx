import { useState, useRef, useEffect } from "react";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import "./App.css";
import { Elm } from "./Main.elm";

function App() {
  const [count, setCount] = useState(0);

  // Use refs to track both the DOM node and the Elm app instance
  const elmNodeRef = useRef<HTMLDivElement>(null);
  const elmAppRef = useRef(null);

  // Familiar grounds for the battle-hardened React developer:
  useEffect(() => {
    // Only initialize Elm if it hasn't been initialized yet
    if (elmNodeRef.current && !elmAppRef.current) {
      elmAppRef.current = Elm.Main.init({
        node: elmNodeRef.current,
      });
    }
  }, []);

  return (
    <>
      <div>
        <a href="https://vite.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
      <div ref={elmNodeRef}></div>
    </>
  );
}

export default App;
