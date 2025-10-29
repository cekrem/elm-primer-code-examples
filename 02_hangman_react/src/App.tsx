import { useState, useEffect, useMemo } from "react";

const MAX_LIVES = 6;

type GameStatus = "playing" | "won" | "lost";

interface HangmanProps {
  initialWord?: string;
}

const Hangman = ({ initialWord = "FUNCTIONAL" }: HangmanProps) => {
  const [wordToGuess] = useState(initialWord);
  const [guessedLetters, setGuessedLetters] = useState<Set<string>>(new Set());
  const [livesRemaining, setLivesRemaining] = useState(MAX_LIVES);
  const [gameStatus, setGameStatus] = useState<GameStatus>("playing");

  // Derived state: display word with blanks
  const displayWord = useMemo(() => {
    return wordToGuess
      .split("")
      .map((char) => (guessedLetters.has(char) ? char : "_"))
      .join(" ");
  }, [wordToGuess, guessedLetters]);

  // Check win condition
  useEffect(() => {
    if (gameStatus !== "playing") return;

    const hasWon = wordToGuess
      .split("")
      .every((char) => guessedLetters.has(char));
    if (hasWon) {
      setGameStatus("won");
    } else if (livesRemaining <= 0) {
      setGameStatus("lost");
    }
  }, [guessedLetters, livesRemaining, wordToGuess, gameStatus]);

  const handleGuess = (letter: string) => {
    if (gameStatus !== "playing") return;
    if (guessedLetters.has(letter)) return;

    const newGuessedLetters = new Set(guessedLetters);
    newGuessedLetters.add(letter);
    setGuessedLetters(newGuessedLetters);

    if (!wordToGuess.includes(letter)) {
      setLivesRemaining((prev) => prev - 1);
    }
  };

  const handleNewGame = () => {
    setGuessedLetters(new Set());
    setLivesRemaining(MAX_LIVES);
    setGameStatus("playing");
  };

  const alphabet = Array.from({ length: 26 }, (_, i) =>
    String.fromCharCode(65 + i)
  );

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: "1rem",
      }}
    >
      <h1>Hangman</h1>
      
      {gameStatus === "won" && <div>🎉 You Won!</div>}
      {gameStatus === "lost" && (
        <div>😞 Game Over! The word was: {wordToGuess}</div>
      )}
      
      <div>{displayWord}</div>
      <div>Lives remaining: {livesRemaining}</div>
      
      <div>
        {alphabet.map((letter) => {
          const isGuessed = guessedLetters.has(letter);
          const isDisabled = isGuessed || gameStatus !== "playing";

          return (
            <button
              key={letter}
              onClick={() => handleGuess(letter)}
              disabled={isDisabled}
            >
              {letter}
            </button>
          );
        })}
      </div>
      
      <button onClick={handleNewGame}>New Game</button>
    </div>
  );
};

export default Hangman;
