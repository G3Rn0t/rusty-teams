## Context

The mask-age unit test drives a `SlowSegmenter` and asserts `shown >= 3` before
the async mask completes. On `forgejo-runner-mac-01` the 60 ms delay often
finishes in one or two 10 ms poll loops.

## Approach

Keep the assertion; lengthen the artificial delay to 200 ms. No production code
paths change.

## Out of scope

- Background-blur product behaviour or ONNX timing
- Retry wrappers in CI for this test
