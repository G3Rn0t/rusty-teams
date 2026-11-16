## 1. Layout guard

- [x] 1.1 When the scrolled settings inset is uneven, scroll to the end and settle again, at most twice more, then assert the resting insets.
- [x] 1.2 `openspec validate macos-settings-inset-scroll` passes.

## 2. Verify

- [x] 2.1 `cargo test -p app --bin teams settings_dialog_keeps_its_inset_at_every_size -- --test-threads=1` passes locally (Linux). macOS confirmation is the Forgejo `macos-arm64` job.
