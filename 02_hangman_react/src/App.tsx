import { useState, useEffect, useMemo } from "react";
import type { ReactElement } from "react";

const MAX_LIVES = 6;

type GameStatus = "playing" | "won" | "lost";

interface HangmanProps {
  initialWord?: string;
}

export default function Hangman({ initialWord = "FUNCTIONAL" }: HangmanProps) {
  const [wordToGuess] = useState(initialWord);
  const [guessedLetters, setGuessedLetters] = useState<Set<string>>(new Set());
  const [livesRemaining, setLivesRemaining] = useState(MAX_LIVES);
  const [gameStatus, setGameStatus] = useState<GameStatus>("playing");

  // Derived state: display word with blanks
  const displayWord = useMemo((): string => {
    return wordToGuess
      .split("")
      .map((char: string): string => (guessedLetters.has(char) ? char : "_"))
      .join(" ");
  }, [wordToGuess, guessedLetters]);

  // Check win condition
  useEffect((): void => {
    if (gameStatus !== "playing") return;

    const hasWon: boolean = wordToGuess
      .split("")
      .every((char: string): boolean => guessedLetters.has(char));
    if (hasWon) {
      setGameStatus("won");
    } else if (livesRemaining <= 0) {
      setGameStatus("lost");
    }
  }, [guessedLetters, livesRemaining, wordToGuess, gameStatus]);

  const handleGuess = (letter: string): void => {
    if (gameStatus !== "playing") return;
    if (guessedLetters.has(letter)) return;

    const newGuessedLetters = new Set(guessedLetters);
    newGuessedLetters.add(letter);
    setGuessedLetters(newGuessedLetters);

    if (!wordToGuess.includes(letter)) {
      setLivesRemaining((prev: number): number => prev - 1);
    }
  };

  const handleNewGame = (): void => {
    setGuessedLetters(new Set());
    setLivesRemaining(MAX_LIVES);
    setGameStatus("playing");
  };

  const renderGameStatus = (): ReactElement | null => {
    if (gameStatus === "won") return <div>🎉 You Won!</div>;
    if (gameStatus === "lost")
      return <div>😞 Game Over! The word was: {wordToGuess}</div>;
    return null;
  };

  const renderLetterButtons = (): ReactElement[] => {
    return Array.from({ length: 26 }, (_: unknown, i: number): string =>
      String.fromCharCode(65 + i),
    ).map((letter: string): ReactElement => {
      const isGuessed: boolean = guessedLetters.has(letter);
      const isDisabled: boolean = isGuessed || gameStatus !== "playing";

      return (
        <button
          key={letter}
          onClick={() => handleGuess(letter)}
          disabled={isDisabled}
        >
          {letter}
        </button>
      );
    });
  };

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
      {renderGameStatus()}
      <div>{displayWord}</div>
      <div>Lives remaining: {livesRemaining}</div>
      <div>{renderLetterButtons()}</div>
      <button onClick={handleNewGame}>New Game</button>
    </div>
  );
}
