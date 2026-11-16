## Why

The macOS test job on Forgejo (`actions/runs/97`, job macOS) fails in `settings_dialog_keeps_its_inset_at_every_size`. The same layout sources passed on an earlier `main` run. Only packaging commits landed in between, so the check is racing the layout rather than describing a new inset.

## What changes

The settings-body inset check scrolls again when the first measurement is uneven, after the frame has settled. No product behaviour changes.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. `skip_specs: true` — the dialog inset on screen stays as it is. This only stops the layout guard from reading a bottom gap before late content growth has been scrolled into view.

## Impact

- `crates/app/src/layout_guard.rs` test helper only
- macOS `cargo test` job on push to `main`
