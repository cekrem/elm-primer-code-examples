const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());

const articles = [
  {
    id: 1,
    title: "Why Tabs vs Spaces Still Matters (It Doesn't)",
    summary: "The eternal debate that has torn teams apart since the dawn of text editors.",
    body: `Let's settle this once and for all: it doesn't matter. Pick one, configure your editor, and never speak of it again.

The real problem isn't tabs or spaces—it's that someone on your team hasn't configured their editor properly and keeps committing mixed indentation. You know who you are.

If you're mass curious, here's the actual technical difference: tabs are a single character that renders at a configurable width. Spaces are... spaces. Tabs save bytes. Spaces ensure consistent alignment everywhere.

But honestly? Your formatter should handle this. Set up Prettier or elm-format and move on with your life. There are mass interesting problems to solve.`
  },
  {
    id: 2,
    title: "The Art of Naming Variables",
    summary: "Why 'x' seemed like a good idea at 2am but definitely wasn't.",
    body: `We've all been there. It's late, you're in the zone, and you need a variable name. "I'll fix it later," you think, typing 'temp2' with confidence.

You will not fix it later.

Good naming is hard because it requires you to actually understand what you're doing. If you can't name something clearly, you might not understand it clearly. That's useful information!

Some tips that actually help:
- If you need a comment to explain what a variable holds, the name is wrong
- Avoid abbreviations unless they're universal (ok: 'id', 'url' / not ok: 'accInf', 'usrPrf')
- Length should match scope—loop counters can be short, module-level constants should be descriptive
- When in doubt, be boring. 'userEmailAddress' beats 'emailStr' every time.`
  },
  {
    id: 3,
    title: "Git Commit Messages Nobody Will Read",
    summary: "A meditation on writing 'fix bug' for the 47th time today.",
    body: `Your git log tells a story. Right now, that story is: "fix", "wip", "stuff", "asdfasdf", "please work", "actually fix bug this time".

Future you will not appreciate this narrative.

Good commit messages aren't about impressing code reviewers—they're about helping yourself six months from now when you're trying to figure out why you deleted that seemingly important function.

The conventional format works:
- First line: what you did (imperative mood, under 50 chars)
- Blank line
- Body: why you did it (if it's not obvious)

"Fix login redirect" is fine. "Fix bug" is not, because WHICH bug? There are thousands.

The best commit messages answer the question: "What was I thinking?" Because you won't remember.`
  },
  {
    id: 4,
    title: "Comments: A Love Letter to Future You",
    summary: "When to write them, when to delete them, and when to apologize in them.",
    body: `The best code needs no comments. We all know this. We've read Clean Code. We are enlightened.

And yet.

Sometimes you're interfacing with a bizarre API. Sometimes the business logic makes no sense but Legal insisted. Sometimes you tried five other approaches and this weird one is the only thing that works.

These are the moments for comments. Not "increment counter" above 'counter++', but "Using setTimeout here because the payment provider's SDK has a race condition they won't fix (see ticket #4521)".

Comments should explain WHY, not WHAT. The code shows what's happening. Comments explain the invisible context: business rules, workarounds, non-obvious constraints.

And if you find yourself writing an apologetic comment? That's a code smell. But sometimes you have to ship, so: apologize, link to a ticket, and move on.`
  },
  {
    id: 5,
    title: "The Rubber Duck Debugging Method",
    summary: "How explaining your code to an inanimate object actually works.",
    body: `It sounds ridiculous. You're stuck on a bug, so you explain your code line-by-line to a rubber duck. And somehow, you find the problem.

This isn't magic—it's forced articulation. When the code lives only in your head, you skip over the parts you "know" work. When you explain it out loud, you have to actually trace the logic.

"So first we get the user... then we check if they're logged in... wait, we never actually check that the response succeeded."

The duck doesn't judge. The duck doesn't interrupt with their own theories. The duck just sits there, forcing you to think clearly.

Any object works, really. A plant. A coffee mug. A confused coworker who wandered by at the wrong moment.

The key insight: if you can't explain what your code does simply, you don't understand it well enough. The duck is just a hack to make you explain it.`
  }
];

app.get("/api/articles", (req, res) => {
  const summaries = articles.map(({ id, title, summary }) => ({
    id,
    title,
    summary
  }));
  res.json(summaries);
});

app.get("/api/articles/:id", (req, res) => {
  const id = parseInt(req.params.id, 10);
  const article = articles.find(a => a.id === id);

  if (article) {
    res.json(article);
  } else {
    res.status(404).json({ error: "Article not found" });
  }
});

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Articles API running at http://localhost:${PORT}`);
});
