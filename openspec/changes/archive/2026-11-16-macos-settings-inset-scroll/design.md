## Context

`scrolled_inset_violation` sends one wheel of `-100_000` px and then reads `settings/main/body` against `settings/main/body/content`. The scroll offset is clamped to the content size of that frame. A later grow (image decode, conversation rebuild) leaves the offset short of the new end. The failure on macOS was `Left 24` and `Bottom 4` for Notifications at 1280×800: 20 px of the 24 px bottom padding still unscrolled. Linux passed. Run 93 on the same layout sources passed macOS; runs after that only touched Flatpak packaging.

## Goals / Non-Goals

**Goals:**

- Measure the inset after the body has been scrolled to the end of the settled content.
- Keep the existing rule: left and bottom insets match within 1 px.

**Non-Goals:**

- Changing settings padding, scrollbar metrics, or section layout.
- Ignoring the assertion when the resting inset is actually uneven.

## Decisions

1. If the first reading is uneven, scroll to the end and settle again, up to two further attempts. The passing path stays one scroll. A real inset bug still fails after the content has stopped growing.
2. Keep the wheel on the body center. The scroll handle lives inside the dialog and is not needed for this check.

## Risks / Trade-offs

- A grow that happens after the last attempt can still flake. Two retries cover the single late grow seen in this job. More attempts would add the settle sleep on every overflowing section.
- The retry only runs when the first reading fails, so the steady Linux run does not pay for extra frames.

## Migration Plan

Land on `main`. The next Test workflow re-runs the macOS job. No data migration.

## Open Questions

None.
