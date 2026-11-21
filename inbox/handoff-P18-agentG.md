# P-18 hand-off: sim-layer support for N players / teams

Owner of game.gd + data.gd is agent A; main.gd is coordinator-assigned. I only
touched ai.gd and menu.gd. Nothing below was edited by me.

## Verified: the sim is hard-locked to exactly two players

- `game.gd:229` `players = [new_player(0,...), new_player(1,...)]`
- `game.gd:1335-1338` `_start_positions()` returns two corners only
- `game.gd:1346` `_spawn_starts()` `for i in 2`
- `game.gd:162` corpse cleanup `for pi in 2`
- `game.gd:1466` `nearest_mine()` scans only `buildings_of(0)+buildings_of(1)`
- `game.gd:2396-2401` AI income cheat hard-coded to `players[1]`
- `game.gd:2524` upkeep `for pi in 2`
- `game.gd:3652,3658-3660` victory `for pi in 2`, `winner = 1 - pi`
- `main.gd:408-410,464-465,553-558` creates AI for player 1 (and CLI player 0) only
- `data.gd:159` `PLAYER_NATIONS := ["rus","bav"]`; no player-count/team fields
- `menu.gd` (mine, now emits keys but has no sim consumer): `opponents`, `teams`

## Required sim changes (file:line)

1. `data.gd:159` add `static var PLAYER_COUNT := 2` and `static var TEAMS: Array = []`
   (per-player team ids; empty = free-for-all). Extend `PLAYER_NATIONS` with
   fallback nations so indices >=2 resolve.
2. `config.gd:390-392` apply `gameplay.players` / `gameplay.teams` into those vars.
3. `game.gd:229` build `players` with `for i in Data.PLAYER_COUNT`, set
   `new_player(i, _nation_name(i,pn), i > 0)` and `players[i]["team"]` from
   `Data.TEAMS`. `_nation_name()` near 249 already handles out-of-range indices.
4. `game.gd:1335-1338` `_start_positions()` must return N well-separated starts;
   all mapgen consumers of `map_starts` (`game.gd:367,389,422,444,551,659,671,684,711`)
   must make at least N safe start clearings.
5. `game.gd:1346` `_spawn_starts()` `for i in players.size()`.
6. `game.gd:162` `for pi in players.size()`.
7. `game.gd:1466` `nearest_mine()` must scan `live_blds` filtered to `mine_*`
   for every player. Without this, AI players 2+ can never fill mines.
8. `game.gd:2396-2401` apply the hard trickle to every `p.is_ai` player, not just 1.
9. `game.gd:2524` `for pi in players.size()`.
10. `game.gd:1508` `enemies_in_radius()` must skip allies when `team` is set;
    AI `_defense()` relies on it.
11. `game.gd:3652,3658-3660` victory over all players; for team games decide by
    surviving team, never `winner = 1 - pi`.
12. `main.gd:408-410,464-465,553-558` instantiate one `C3AI` per AI player;
    map `cfg["opponents"]` -> `Data.PLAYER_COUNT = opponents + 1` and
    `cfg["teams"] == "2v1"` -> `TEAMS = [0,0,1]`; `"ffa"` -> `[]`.
    `uitest.gd:111` asserts `PLAYER_NATIONS == ["tur","rus"]` for the default
    2-player path, so defaults must stay 1 opponent.

## Already done on my side

- `ai.gd:_is_enemy(other)` team-aware enemy test; `_waves()` now picks the
  nearest building of ANY enemy player/team instead of `1 - player`;
  `_raids()` targets enemy peasants via `_is_enemy`. Two-player behaviour
  is unchanged.
- `menu.gd`: "Opponents" (1/2/3) and "Teams" (Free for all / 2 vs 1) rows,
  emitted as `cfg["opponents"]` and `cfg["teams"]`. Default 1 / ffa, so the
  existing 2-player selftest/uitest paths are untouched.

No missions/network work (deferred by charter).
