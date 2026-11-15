# Proposal

## Why

Joining a meeting first and having a second participant join triggers a server-initiated mixer leg switch (`call/mediaRenegotiation` followed by `call/mediaAcknowledgement`). Previously:
- Detaching video senders across a peer switch dereferenced a null track pointer in the C++ shim (SIGSEGV), and pending camera start spun the call loop.
- `call/mediaAcknowledgement` was ignored, leaving the call waiting 20 s for a `retargetCompletion` that never comes on that flow and keeping stale control URLs (`updateMediaDescriptions`, `applyChannelParameters`, `callLeg`) from the ended leg (HTTP 406/404).
- Answering a folded `x-multi-stream` screen-share line with send SSRCs triggered `SdpParsingFailure` (301000), while answering `recvonly` without upgrading on share start left screen share unable to publish.
- Hanging up closed the peer connection before stopping local media and ending the call leg, leaving remote participants with a frozen camera frame or avatar tile.
- `Auto` camera quality defaulted to 1080p capture without an uplink governor, causing unnecessary CPU/bandwidth pressure under tight uplinks.

## What Changes

- Keep `set_track(None)` null-safe when detaching senders and avoid requeueing pending camera/share start while a peer switch is in flight; tie the Linux inhibit helper to parent exit.
- Handle `call/mediaAcknowledgement` on Trouter callbacks: harvest the new mixer leg's control links, mark server-initiated peer switches ready as soon as ICE connects, and reset send-control sequence/capability state for the new leg.
- Keep folded `x-multi-stream` share lines `recvonly` in mixer answers (no `SdpParsingFailure`), recognize the carrier mid's `x-source-streamid` for inbound share, and upgrade to a conference send offer when starting local screen share from a receive-only share line.
- Before leaving a call, turn off active camera/share publishing (`updateMediaDescriptions` `recvonly`), send `leave` and `DELETE callLeg` while peers are still open, and close peers afterwards so remote tiles disappear immediately.
- Use a 720p capture ceiling for `Auto` video quality (keeping explicit `1080p` available), prefer `MaintainFramerate` degradation on camera senders, govern camera send bitrate under sustained high RTT/loss, and move capture/effects thread teardown off the call task.

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `call-media-negotiation`: Server-initiated mixer leg switches refresh leg links via `call/mediaAcknowledgement`, upgrade receive-only share lines on share start without `SdpParsingFailure`, detach tracks safely across peer switches, and cleanly unregister media/call legs on hangup.
- `camera-video-quality`: `Auto` uses a 720p local capture ceiling while keeping 1080p stage receive budgets and explicit `1080p` capture; camera uplink bitrate adapts under sustained RTT/loss.
- `camera-capture`: Update the `Auto` vs `1080p` format-selection scenario to match the 720p `Auto` ceiling.

## Impact

- `crates/calling` (`call`, `sdp`, `signaling`, `trouter_events`, `send_control`, `video_layout`, `video_quality`, `video_receive`, `video_send`, `camera`, `capture`, `effects`, `awake`)
- `crates/app-state/src/call` (non-blocking call cleanup wiring)
- `vendor/libwebrtc` & `vendor/webrtc-sys` (`RtpSender::set_track(None)` null safety)
