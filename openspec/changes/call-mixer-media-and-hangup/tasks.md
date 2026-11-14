## 1. Crash safety & non-blocking media lifecycle

- [x] 1.1 Make `RtpSender::set_track(None)` null-safe in `vendor/webrtc-sys` and `vendor/libwebrtc`
- [x] 1.2 Guard pending camera/share start while `next.is_some()` so peer switches never spin the call loop
- [x] 1.3 Set `PDEATHSIG` on the Linux `systemd-inhibit` child and move capture/effects thread joins off the async call task

## 2. Mixer leg switch, screen-share upgrade, and clean hangup

- [x] 2.1 Classify `call/mediaAcknowledgement` on Trouter callbacks, harvest nested leg links, complete server-escalation retargeting on ack, and reset send-control state on peer switch
- [x] 2.2 Keep `x-multi-stream` share answers `recvonly` (avoiding `SdpParsingFailure`), preserve carrier `source_stream_id` for inbound share, and trigger conference peer upgrade when starting local share from a receive-only share line
- [x] 2.3 Stop local camera/share publishing (`updateMediaDescriptions` `recvonly`), send `leave`, and `DELETE` remembered `callLeg` URLs before closing peers on hangup

## 3. Auto 720p ceiling & uplink bitrate governor

- [x] 3.1 Use a 720p capture ceiling for `VideoQuality::Auto` while preserving explicit `1080p` and stage receive budgets
- [x] 3.2 Set `MaintainFramerate` degradation preference on camera senders and add `BitrateGovernor` under sustained RTT/loss

## 4. Module structure (pure refactor, behaviour unchanged)

- [x] 4.1 Move `crates/calling/src/call.rs` to `crates/calling/src/call/mod.rs` and extract `peer_sdp`, `escalation`, `audio_switch`, `bots`, `teardown`, and `stats` submodules

## 5. Verify

- [x] 5.1 `cargo test -p calling --lib`
- [x] 5.2 `scripts/install-linux-local.sh --restart` and live two-party meeting test (solo join + lobby admit, camera both ways, screen share, clean hangup without frozen remote tile)
