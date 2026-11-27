---
id: PORT1TO1-VIDEO-EVIDENCE-ASSESSMENT-2026-11-27
title: "Assessment of public Cossacks 3 gameplay video as parity evidence"
worker: COORD (read-only assessment)
date: 2026-11-27
status: DELIVERED__READ_ONLY__NO_DONOR_EXECUTION__NO_PARITY_CLAIM
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; no donor GPU A/B frame; chain 0/6; no approximation, no parity claim."
---

> **PORT APPROXIMATION — donor parity UNVERIFIED. No donor GPU A/B frame exists; this assessment certifies neither fidelity nor a gate pass.**

## 1. What the owner asked
The owner suggested watching Cossacks 3 gameplay videos online as a possible way to progress toward a full 1:1 port, after noting that I cannot click buttons in the donor GUI.

## 2. Sources found (web search, this pass)
- `Cossacks 3 - 4K GAMEPLAY` (YouTube, watch?v=SIi1Mc5M9dI)
- `Cossacks 3 Skirmish Gameplay` playlist (PLWrIqGszZr5kDDWVYEYkaMe1T9kcWf-8n)
- `Skirmish Battle: England vs. Turkey` (watch?v=9WtmQA9RB08)
- `Cossacks 3: Beginner Tutorial as the Netherlands (1/2)` (watch?v=4rzZWvabQTs) — visual terrain/forest/stone/settlement context
- `Cossacks 3 Map Editor Guide & Tutorial` playlist (PLWrIqGszZr5nZdzQ4w87ciDkrmmFpuc72)
- `What is Cossacks 3 - An Overview / Review` (watch?v=Uk1I7IT4Cl8)

All are third-party public uploads.

## 3. Why this is NOT admissible parity evidence
| Requirement | Public gameplay video | Verdict |
|---|---|---|
| Donor binary exact build (`t_87f0f3c130b0`, SHA `87F0F3C1…`) | Unknown uploader build/version/patch | FAIL |
| Same seed / map / season / nation as port capture | Not published, not controllable | FAIL |
| Matched camera (position, yaw, pitch, zoom, FOV) | Camera is player-controlled, unlogged | FAIL |
| Same tick / frame index | Unknown | FAIL |
| Pixel/geometry-byte A/B comparison | Video is compressed, resampled, cropped, overlaid with HUD/commentary | FAIL |
| COORD-signed zero-mismatch ruling | No ruling; no matched frame pair | FAIL |
| Reproducibility | Cannot replay the exact upload frame | FAIL |

A public video therefore cannot CLOSE any of the six parity conditions. It is at most **qualitative context** (e.g. seeing how forest/stone/water/settlements look in the shipped game), which cannot be transcribed into a port value without an invented number — explicitly forbidden.

## 4. GUI control status
- Tool catalog has no generic Windows desktop click/key/screen tool. `click`/`key`/`screenshot` tools belong to specific in-app servers (wordcraft, mailcraft, gridcraft, deckcraft, filmcraft, browser, etc.), not arbitrary programs.
- I cannot inject input into `cossacks.exe` or drive its UI.
- The owner conditionally authorized donor execution **if** I can control it; I cannot, so no donor process was launched.
- A blind launch would produce no seed/camera/tick-matched frame and would breach the earlier standing "no donor execution" rule; it was not attempted.

## 5. Honest bottom line
100% 1:1 parity is not reachable from this environment with the available tools and the read-only donor rule. The only admissible path remains an owner-supplied, matched-camera donor GPU A/B frame plus manifest and COORD ruling. This assessment adds no port value and closes no `[U]` or P0 row.

Parity **UNVERIFIED**; chain 0/6; nine P0 OPEN; 71 open `[U]`; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximations, no parity claim.
