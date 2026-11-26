# PHOTO-SEQUENCE — contact-sheet review

Date: 2026-11-26  
Scope: candidate image sequences only; no donor A/B frame.

## Contact sheets

- `inbox/qa/captures/contact_close-shorealpha.png` — frames 0,4,8,12,16,20,23 of the 64² close pan.
- `inbox/qa/captures/contact_shorealpha2.png` — same frames after extending neutral alpha to ids 87–90.
- `inbox/qa/captures/contact_wide-final.png` — frames 0,4,8,12,16,20,23 of the 240² wide pan.

## Observations

1. **Ground is temporally stable.** The 16 m subcell art matrix does not shimmer or crawl across adjacent frames; the former 2 m checkerboard is absent in both sequences.
2. **Shore ring is stable and continuous after neutral alpha.** In the close sheet the large central sandsea region reads as one photograph through all frames, with no frame-to-frame brightness pulses. This supports the A/B result that the id-hash alpha modulation was the chevron amplifier.
3. **Outer shore edge still has parallel thin stripes.** In every close frame the boundary between the sand region and grass shows repeated narrow bands. `DEC_SHORE_EDGE` identifies them as `sandrock1..4` (87–90) transition cells from live smoothing chains C01/C02/C03, not face art; after extending neutral alpha to 87–90 the bands are thinner but remain.
4. **Close-frame metrics confirm partial improvement:** interior dark fraction `35.8% → 1.3%`, gradient `8.17 → 3.69`, AC48 ≈ 0.01 from `donor_64_final` to `donor_64_shorealpha2` (`SEQ_CLOSE_analysis.md`); full-frame luma std `30.17 → 24.33`, gradient `9.79 → 6.40`. The central chevrons are gone; residual anisotropy is concentrated at the outer transition edge.
5. **Temporal stability is clean.** Motion-compensated residual MAD is 0.1–1.0 luma with pure horizontal shifts, matching the deterministic smoothstep pan; no flicker/shimmer/snap was found in 24 frames.
5. **Relief patches remain dark and chevroned in the wide sheet.** Frames 0/4/12 show nested dark bands; frames 8/20/23 show mostly empty grass. The artifact is local to a few stamped areas, not a global shader/light problem.
5. **Props and trees stay fixed to the ground** across the pan; no sliding parallax was visible. Forest coverage remains sparse, consistent with REVIEW3 rank 8.
6. **No motion aliasing from the atlas.** The corrected tile map and mip guard hold up under camera motion.

## Interpretation

The contact sheets support separating three remaining visual problems:

| Problem | Evidence | Owner |
|---|---|---|
| Outer shore thin stripes | close frames, stable boundary bands | shore/UV + cell-centre topology |
| Dark chevron relief patches | wide frames 0/4/12, local to stamps | stamp geometry / shore overlap |
| Sparse forest | all wide frames | forest placement |

No parity claim is made. The sheets are candidate-internal diagnostics.
