# call-media-negotiation Specification

## Purpose

Signaling and SDP for camera and screen share in connected calls: escalation answers and same-peer renegotiation behave so the remote side accepts media lines and delayed camera answers still apply.

## Requirements

### Requirement: Escalation answer keeps offer line count

During media renegotiation with escalation, the answer signaled to Teams MUST have the same number of media lines as the remote offer. An internally folded multi-stream line MUST go back as exactly one signaled m-line.

#### Scenario: Multi-stream line without extra mid

- **WHEN** the remote offer carries a video line with `x-multi-stream` that was unfolded internally into several browser mids
- **THEN** the signaled answer for that role contains exactly one m-line and no extra mid used only for internal unfolding

#### Scenario: Line count matches the offer

- **WHEN** the remote offer has N media lines
- **THEN** the signaled escalation answer also has N media lines

### Requirement: Late same-peer camera answer counts

If the app sends a same-peer renegotiation for camera in a direct 1:1 and the matching answer arrives shortly after the local answer timeout, the app MUST still apply that answer when it belongs to the last sent offer. An answer with receive-side camera direction (`recvonly` from the remote party’s view) MUST count as successfully enabling local send.

#### Scenario: Answer a few seconds after timeout

- **WHEN** the local same-peer camera offer was rolled back due to timeout and the matching answer arrives shortly after
- **THEN** the app applies the answer and the camera stays or becomes sending again instead of discarding the answer

### Requirement: Faster 1:1 connect with prefetched relay

For 1:1 answers the client SHALL avoid waiting on slow TCP/TLS relays when a prefetched relay grant can be reused, so calls connect without stalling on that path.

#### Scenario: Prefetched relay reused

- **WHEN** a 1:1 call answer proceeds and a relay grant was fetched ahead
- **THEN** the connect path reuses that grant instead of blocking on a slow TCP/TLS relay fetch

### Requirement: Fullband Opus request

The client SHALL ask Teams for fullband Opus on the call audio path when that capability is available.

#### Scenario: Fullband Opus offered

- **WHEN** a call negotiates audio with Teams
- **THEN** the client requests fullband Opus rather than only a narrowband default

### Requirement: Server mixer leg switch refreshes control links

When the meeting media controller moves an active call to a new media leg via renegotiation and sends `call/mediaAcknowledgement`, the client SHALL adopt the new leg's control links (`updateMediaDescriptions`, `applyChannelParameters`, `controlVideoStreaming`, `mediaRenegotiation`, `callLeg`) and switch to the new peer connection once media connectivity is established without waiting for an unrelated retarget timeout. Inbound and outbound camera video SHALL continue working on the new leg.

#### Scenario: Second participant joins or is admitted after solo join

- **WHEN** the local user joins a meeting first and a second participant joins or is admitted from the lobby, causing a server-initiated media renegotiation and `call/mediaAcknowledgement`
- **THEN** the client switches to the new media leg once connected and sends subsequent media description and channel parameter updates to the new leg's URLs rather than the ended leg
- **AND** turning the camera on before or after the switch delivers outbound video to the remote participant

### Requirement: Screen share upgrades cleanly from a multi-stream mixer offer

When the active mixer peer answered a folded `x-multi-stream` screen-share line as receive-only, answering that offer MUST NOT emit send SSRC ranges or groups that fail Teams SDP parsing. Starting local screen share from that state SHALL upgrade the media leg to a send-capable screen-share line and begin transmitting the shared picture.

#### Scenario: Lobby admit does not fail SDP parsing

- **WHEN** the mixer sends an escalation offer whose screen-share line carries `x-multi-stream`
- **THEN** the client answers that line without `SdpParsingFailure` and keeps the call connected

#### Scenario: Starting screen share after a server mixer switch

- **WHEN** the call is on a server-offered mixer peer whose screen-share line is receive-only and the user starts screen sharing
- **THEN** the client negotiates a send-capable conference share line and delivers the shared screen to remote participants

### Requirement: Leaving a call removes the local tile immediately

When the local user hangs up a connected call or meeting, the client SHALL stop active camera and screen-share publishing, notify the media controller, leave the conversation, and end active call legs before closing local WebRTC peer connections.

#### Scenario: Hangup with camera active

- **WHEN** the local user hangs up a meeting while local camera or screen share is active
- **THEN** remote participants no longer keep a frozen camera frame or active participant tile after the hangup completes

### Requirement: Detaching sender tracks across peer switches is safe

Replacing or closing a peer connection while camera or screen share is active or pending SHALL detach local sender tracks without crashing or spinning the call loop.

#### Scenario: Peer switch with active camera

- **WHEN** a peer escalation switches from the old peer connection to the new one while the camera is running
- **THEN** the old sender detaches its track cleanly and the call stays responsive
