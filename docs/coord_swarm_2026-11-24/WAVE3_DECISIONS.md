# Wave 3 decisions — building UX (owner directive 2026-11-24)

Based on X1 recon (`reports/X01_building_ux_sites.md`). Coordinator rulings on
the recon's open questions, to unblock the W3 builders:

1. **Selection aura** — procedural ellipse glow in player colour + tinted
   `ring_sel.png` + pulse on corner diamonds, using existing overlays only.
   No donor texture copy (private-use rule).
2. **Rally flag visibility** — show the flag when the building is SELECTED and
   keep always-on for own buildings as an option; owner said "rally points are
   visible and used when building is selected", so selected-gated is the default,
   always-on acceptable only if it does not clutter (visual A/B by coordinator).
3. **Orphan site recovery** — refuse human placement with zero selected peasants
   (X1 rank 2); add stale-site cancel/refund via `Data.refund` for sites that
   already exist. Do NOT auto-build without a player-chosen peasant.
4. **Cost escalation** — UI must display and gate on the ESCALATED cost that
   `place_building` charges (`pow(1.5,cnt)` / `pow(3,cen)`). Never enable a
   ghost/button the sim would refuse.
5. **Missing buildables** — expose `bar18`/`dip`/`gat`/`dock` in the HUD build
   list if their data + art exist; otherwise remove their dead hotkeys. Do not
   leave a hotkey that silently does nothing.
6. **Capture rally loss** — re-arm the default rally when a trainer changes owner.
7. **Refund percentage** — use `Data.refund(..., 1.0)` (full) for cancel of a
   not-yet-started site; partial only if a builder already worked (document).

Ownership remains per `WAVE3_CHARTER.md`. Wave 3 opens when wave-2 owners of
`game.gd` (W2-1 closed), `input_controller.gd`/`hud.gd` (W2-3 open), and
`world.gd` (W2-5 open) release those files.
