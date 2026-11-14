# Design

## Context

When a user joins a Teams meeting alone, Teams initially connects an early mixer leg and then sends `call/mediaRenegotiation` (`newOffer: true` / `escalationOccurring: true`) once another participant joins or is admitted from the lobby. `POST mediaAnswer` returns an empty `HTTP 202`, and the new mixer controller delivers its control links (`updateMediaDescriptions`, `applyChannelParameters`, `controlVideoStreaming`, `mediaRenegotiation`, `callLeg`, …) asynchronously on Trouter `call/mediaAcknowledgement`.

On that new mixer offer, `applicationsharing-video` carries `a=x-multi-stream:2 1 1 1`. Teams' SDP parser rejects `x-ssrc-range` / `ssrc-group` on `x-multi-stream` lines with `code=410 subCode=301000 phrase=SdpParsingFailure`.

On hangup, closing the WebRTC `PeerConnection` before stopping active video lines and deleting the call leg leaves the remote Teams client displaying the last decoded video frame or participant avatar until a server timeout expires.

## Goals / Non-Goals

- Goals:
  - Seamless video and screen share across server-initiated mixer leg switches (including lobby admit when joining first).
  - Immediate removal of the local participant's video/avatar tile for remote participants upon hangup.
  - Crash-free, non-blocking sender detach and capture/effects teardown.
  - Lower default CPU/uplink load via 720p `Auto` capture ceiling, `MaintainFramerate` degradation, and RTT/loss bitrate governing.
- Non-Goals:
  - Simulcast RIDs in answers to remote non-simulcast offers.
  - Direct MJPEG-to-YCbCr turbo path (kept out until measured necessary).

## Decisions

1. **Harvest leg links from `call/mediaAcknowledgement` and complete retargeting** — Parse `call/mediaAcknowledgement` in `crates/calling/src/trouter_events.rs` using recursive leg-link extraction (`nested_links`). When a server-answered `NextPeer` is pending, merge the links into `pending.leg_links` and set `pending.retargeted = true` so the call switches as soon as ICE reaches `Connected` (~0.5 s instead of timing out `RETARGET_WAIT` after 20 s). Reset `RequestFilter` and `SendCapabilityReporter` on switch so sequence numbers starting back at 1 and 720p send capabilities apply to the new leg.
2. **Keep `x-multi-stream` answers `recvonly` and upgrade on share start** — Keep `multi_stream.is_some()` placeholder SSRC serialization in `crates/calling/src/sdp.rs` and `stop_sending_on` for non-sending share lines in `answer_offer_with` so Teams never raises `SdpParsingFailure`. Preserve `source_stream_id` on the carrier mid of folded `ScreenShare` lines so inbound screen share still binds a receive slot. When starting local screen share while `!local_video.share_sending()`, trigger `begin_conference_upgrade()` + `escalate(...)` over the new leg's `mediaRenegotiation` link to negotiate our 13-line conference offer (`mid 11 sendrecv`).
3. **Ordered hangup teardown** — In `stop_local_publish` and `tear_down`, stop local camera/share capture, send `updateMediaDescriptions` (`recvonly`) for active publish lines, await `POST leave`, and send `DELETE` (`hangup_call_leg_body`) to every remembered `callLeg` URL before calling `peer.close()`.
4. **Null-safe `set_track(None)` and off-task thread joins** — Guard null `MediaStreamTrack` pointers in `vendor/webrtc-sys/src/rtp_sender.cpp` (`SetTrack(nullptr)`). Move blocking capture and segmentation/effects thread joins onto background drop helpers so the async call loop never stalls. Set `PR_SET_PDEATHSIG(SIGTERM)` on the `systemd-inhibit` child in `crates/calling/src/awake.rs`.
5. **720p `Auto` ceiling and `BitrateGovernor`** — Map `VideoQuality::Auto` capture ceiling to 720p in `crates/calling/src/video_quality.rs` while keeping stage receive requests at 1080p-class budgets for `Auto` and `1080p`. Add `BitrateGovernor` in `crates/calling/src/send_control.rs` to step down camera send bitrate after consecutive high-RTT/loss samples (floor 300 kbps) and recover gradually on a clean path.

## Risks / Trade-offs

- Starting screen share right after a server-initiated mixer leg switch performs one fast (~1 s) conference upgrade negotiation so `mid 11` is `sendrecv` without `x-multi-stream`; camera and audio stay continuous across the switch.
- Users who relied on `Auto` capturing 1080p locally now select `1080p` explicitly when needed.
