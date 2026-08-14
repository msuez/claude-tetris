# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Classic Tetris implemented in vanilla JavaScript with HTML5 Canvas. No dependencies, no build step, no package.json — just static files.

- `index.html` — DOM structure: main `#board` canvas (300×600), side panel (score/lines/level), `#next-canvas` preview, pause/game-over overlay.
- `style.css` — dark/retro arcade styling (flexbox, backdrop-filter for overlays).
- `game.js` — all game logic (~300 lines), single file, no modules.

## Running

No build or install step. Either open `index.html` directly in a browser, or serve it locally:

```bash
python3 -m http.server 8000
# or
npx serve .
```

There is no test suite, linter, or build/bundle command in this repo.

## Architecture (`game.js`)

Everything lives in one file with module-level `let` state (`board`, `current`, `next`, `score`, `lines`, `level`, `paused`, `gameOver`, `dropInterval`, etc.) — no classes, no state management library.

- **Board model**: `ROWS × COLS` matrix; each cell is `0` (empty) or a color index `1–12` identifying which piece locked there.
- **Pieces**: `PIECES` array of matrices (index 0 unused/null), indices `1–7` are the standard tetrominoes, `8–10` are pentominoes (`+`, `U`, `Y`), `11` is a hollow 3×3 "nut" piece, `12` is a 1×1 single. Rotation is done via `rotateCW` (transpose + reverse), which works for non-square shapes too, not by storing pre-rotated states.
- **Piece selection** (`randomType`): weighted roll — `CHALLENGE_CHANCE` (5%) for the hollow 3×3 nut, `PENTOMINO_CHANCE` (10%) for one of the three pentominoes, otherwise one of the 7 standard tetrominoes. The 1×1 single (`REWARD_TYPE`) is never drawn randomly — `clearLines` sets `rewardPending` on a 4-line clear, and `spawn` forces the next generated piece to be the single as a reward.
- **Collision** (`collide`): checks board bounds and overlap with locked cells for a given shape/offset.
- **Wall kicks** (`tryRotate`): after rotating, tries offsets `[0, -1, 1, -2, 2]` until one doesn't collide, else the rotation is discarded.
- **Game loop** (`loop`): driven by `requestAnimationFrame`; accumulates elapsed time in `dropAccum` and advances the piece one row once `dropInterval` is exceeded, otherwise calls `lockPiece()`.
- **Line clearing** (`clearLines`): scans bottom-to-top, splices full rows out and unshifts empty rows at the top; re-checks the same row index after a splice.
- **Scoring**: `LINE_SCORES = [0, 100, 300, 500, 800]` multiplied by `level`; hard drop adds 2 pts/row dropped, soft drop adds 1 pt/row.
- **Leveling/speed**: level = `floor(lines / 10) + 1`; `dropInterval = max(100, 1000 - (level - 1) * 90)` ms.
- **Ghost piece** (`ghostY`): projects `current` straight down until collision, drawn at `globalAlpha = 0.2`.
- **Rendering**: `draw()` clears and redraws the grid, locked board, ghost piece, and current piece every frame onto `#board`; `drawNext()` renders the preview piece onto `#next-canvas`.

Control flow: `init()` resets state → `spawn()` promotes `next` to `current` and generates a new `next` (calling `endGame()` if the new piece already collides) → `requestAnimationFrame(loop)` drives the drop timer and redraw each frame. Keyboard input (`keydown` listener) handles movement/rotation/soft-drop/hard-drop/pause and is ignored while paused or game over (except `P`).

## Tunable constants (top of `game.js`)

`COLS`, `ROWS`, `BLOCK`, `COLORS`, `LINE_SCORES`, `dropInterval` (initial), `PENTOMINO_CHANCE`, `CHALLENGE_CHANCE`. If `COLS`/`ROWS`/`BLOCK` change, update the `#board` canvas `width`/`height` in `index.html` to match (`COLS × BLOCK`, `ROWS × BLOCK`).
