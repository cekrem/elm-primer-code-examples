import { useState } from "react";

const MAX_LIVES = 6;

type GameStatus = "playing" | "won" | "lost";

interface HangmanProps {
  initialWord?: string;
}

const Hangman = ({ initialWord = "FUNCTIONAL" }: HangmanProps) => {
  const [wordToGuess] = useState(initialWord);
  const [guessedLetters, setGuessedLetters] = useState<Set<string>>(new Set());

  // Compute derived state
  const wrongGuesses = Array.from(guessedLetters).filter(
    (letter) => !wordToGuess.includes(letter)
  ).length;

  const livesRemaining = MAX_LIVES - wrongGuesses;

  const hasWon = wordToGuess
    .split("")
    .every((char) => guessedLetters.has(char));
  const hasLost = livesRemaining <= 0;
  const gameStatus: GameStatus = hasWon ? "won" : hasLost ? "lost" : "playing";

  const displayWord = wordToGuess
    .split("")
    .map((char) => (guessedLetters.has(char) ? char : "_"))
    .join(" ");

  const handleGuess = (letter: string) => {
    if (gameStatus !== "playing" || guessedLetters.has(letter)) return;
    setGuessedLetters(new Set([...guessedLetters, letter]));
  };

  const handleNewGame = () => {
    setGuessedLetters(new Set());
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
