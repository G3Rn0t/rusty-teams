## Why

The macOS CI job fails intermittently on
`blur::tests::the_mask_age_counts_the_frames_shown_since_its_source_frame` when a
fast host finishes the slow segmenter before three refresh loops. That is a test
timing flake, not a product behaviour change.

## What Changes

- Increase the test `SlowSegmenter` delay from 60 ms to 200 ms so CI Mac hosts
  still observe enough frames before the mask returns.

## Capabilities

- **New Capabilities:** none (`skip_specs: true`)
- **Modified Capabilities:** none

## Impact

- `crates/calling/src/blur.rs` test only
- Forgejo Test macOS job stability
