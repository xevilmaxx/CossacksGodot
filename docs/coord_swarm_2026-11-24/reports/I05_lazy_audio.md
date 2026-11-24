---
owner: I5
date: 2026-11-24
item: recon P3 opportunity A2 (P03_assets_memory.md) — lazy sound loading
status: done
---

# I05 — Remove eager startup preload of all 325 OGG files

## What changed

`app/scripts/audio.gd::_ready()` eagerly called `_stream(f)` for every entry in
`files` (all 325 OGG basenames discovered under `res://assets/sounds`), forcing
a synchronous `load()` of every clip at startup — ~281.81 MiB of I/O/RAM (P3
measurement). A lazy path already existed: `_stream()` loads-and-caches on
first request. Removing the two-line eager loop leaves every sound resolvable
on demand; `files` itself is retained because `names_for()` scans it.

## Exact diff (file:line numbers refer to the post-edit file)

Removed from `app/scripts/audio.gd::_ready()` (the loop sat between the
16-player pool construction at `:42-45` and the music comment at `:47`):

```diff
 	for i in 16:
 		var p := AudioStreamPlayer.new()
 		add_child(p)
 		players.append(p)
-	for f in files:
-		_stream(f)
 
 # The music of the player's nation and the air around it.
```

- Deleted the two lines `for f in files:` / `_stream(f)` (originally `:46-47`).
- No dedicated comment described the loop, so no comment was removed. The
  file header (`:6-8`, "They are loaded when they are first needed, so the game
  starts fast") is now accurate and was left untouched.
- No other line changed: `files` population (`:37-41`), the 16-player pool
  (`:42-45`), `start_music()` (`:48-82`), `_stream()` (`:171-176`),
  `names_for()` (`:155-166`), and `play()` (`:179-212`) are byte-identical.
  Indentation is tabs, matching surrounding style.

## Backup

`inbox/backup/audio.gd.bak-I5-LAZYAUDIO` (copied from `app/scripts/audio.gd`
before edits). A `git diff --no-index` against the backup confirms the diff is
exactly the two deleted lines above, nothing else.

## Runner job + result

- Command: `python app\tools\godot_runner.py run --id i5-audio-lazy --timeout 180 -- --headless --path app --script res://tests/t_audio_events.gd`
- Runner ticket: **1236**, id **i5-audio-lazy** — START, END **ok** (run 1.07 s).
- Result file `app/tests/results/t_audio_events.json`: `"passed": true`, **5/5**
  checks passed:
  - `event_prefix_files_exist` — 20/20 prefixes backed by .ogg; missing: none
    (of 325 files).
  - `audio_names_for_resolves_events` — `names_for()` unresolved: none.
  - `walk_sound_prefixes_resolve` — unresolved walk sids: none.
  - `chop_event_maps_to_sound` — chop → `["workwood"]`, resolves
    workwood1..workwood9.
  - `nation_theme_files_or_fallback` — 21 nations, 21 themed, fallback=true;
    missing: [].

## Why every play(prefix) still resolves via the lazy path

- `files` is still filled in `_ready()` (`:37-41`) from `DirAccess.open(DIR)`;
  the eager loop never contributed to it. `names_for(prefixes)` (`:157-168`)
  still scans `files` and applies the same "name matches when rest is empty or
  starts with a digit" rule, so the set of resolvable names is unchanged.
- `play(prefixes, ...)` (`:181-214`) resolves candidates with `names_for()`,
  picks one with `randi()`, then obtains the stream via `_stream(n)` (`:206`).
  `_stream()` (`:173-178`) checks `cache`, else `load("%s/%s.ogg")`, caches and
  returns — so the first `play()` of a clip loads it on demand and all later
  plays hit the cache. The `if s == null: return` guard (`:207-208`) is
  unchanged, so a missing file is still a silent no-op. Volumes, pitch
  randomisation, the 16-player round-robin, the 0.09 s debounce and the
  distance attenuation are untouched.
- `has()` (`:170-171`) delegates to `names_for()`, so it too is unaffected.
- Music: `start_music()` (`:48-82`) was already fully lazy — it calls
  `_stream(nation)`, falls back to `_stream(MUSIC_FALLBACK)` when that is null
  (`:54-56`, P-13 national-music fallback intact), then `_stream("amb_atmosphere")`
  and `_stream("amb_windmill")`. It never depended on the eager loop, so music
  still starts exactly when invoked (from main.gd) as before. Ambience/windmill
  setup and `_process()` proximity logic are unchanged.

Net effect: identical play semantics and identical set of loadable sounds; only
the *timing* of each `load()` moves from `_ready()` to first use. The two-line
loop was the sole consumer of the eager path; nothing else referenced the
pre-populated `cache` as a startup invariant.

## First-play hitch note

The trade-off is a possible one-off synchronous `load()`/OGG-decode stall on the
first play of each clip (and when `start_music()` first requests the nation
theme, atmosphere and windmill beds), instead of a single large stall at
startup. Subsequent plays of a clip are served from `cache` with no I/O. This
is a latency relocation, not extra work: the same 325 files are loaded at most
once each. OGG streams decode incrementally during playback, so the synchronous
cost per clip is small relative to the ~282 MiB removed from startup. No
streaming/threading was introduced; if per-first-play smoothness later matters,
a targeted preload of only the handful of frequently-used event clips (rather
than all 325) would be the next step — out of scope here.

## Determinism note

Deterministic. Removing a startup `load()` loop adds no randomness, wall-clock
dependence or frame-count dependence. `files` is still populated by iterating
`DirAccess.get_files()` in the same order; `names_for()` and the `randi()`/
`randf_range()` calls in `play()` are unchanged (the RNG was and remains seeded
by the engine's global state). The `cache` is a plain name→stream map filled on
first access; for any fixed sequence of `play()`/`start_music()` calls the set
of loaded streams is identical run-to-run. The test passes deterministically
(5/5) and depends only on file existence/name resolution, not on load timing.

## Open questions

- Not measured in this turn: peak RSS / startup-time delta on the real target.
  The ~281.81 MiB figure is the P3 finding's measurement; this change is
  expected to remove that eager cost but no new memory profile was taken
  (would require a non-headless or instrumented run).
- The headless test verifies name resolution and file existence, not audible
  playback or actual decode timing; first-play hitch is reasoned, not measured.
- Deferred (not in scope): whether to preload only a small hot-set of clips
  (shot/work/walk/music) to smooth the very first skirmish seconds. Left to
  coordinator discretion.
