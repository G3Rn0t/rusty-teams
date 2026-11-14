## MODIFIED Requirements

### Requirement: Camera capture prefers the selected quality ceiling

The client SHALL capture the local camera at the highest supported widescreen format at least 30 fps that does not exceed the active quality ceiling (720p or 1080p). Auto SHALL use a 720p capture ceiling; explicit 1080p SHALL use a 1080p ceiling when the camera can deliver it, otherwise 720p. The client SHALL NOT offer or use a 4K camera quality mode.

#### Scenario: Camera supports 1080p with Auto

- **WHEN** video quality is Auto and the selected camera exposes both 1280×720 and 1920×1080 widescreen formats at ≥30 fps
- **THEN** capture uses the 720p-class format unless the user explicitly selects 1080p

#### Scenario: Camera supports 1080p when 1080p is selected

- **WHEN** video quality is set to 1080p and the selected camera exposes a suitable 1920×1080 (or equivalent 16:9) format at ≥30 fps
- **THEN** capture uses that 1080p-class format

#### Scenario: Camera only supports 720p

- **WHEN** video quality is Auto or 1080p and the camera cannot provide a suitable 1080p format
- **THEN** capture falls back to a suitable 720p format without failing camera start solely for that reason

#### Scenario: User locks 720p

- **WHEN** video quality is set to 720p and a higher camera format is available
- **THEN** capture stays at or below 720p

## ADDED Requirements

### Requirement: Camera uplink adapts to sustained path stress

While sending camera video, the client SHALL prefer maintaining frame rate over resolution under encoder pressure and SHALL cap outbound camera bitrate below the mixer ceiling when round-trip time or packet loss stays elevated, recovering gradually once the path is clean.

#### Scenario: High RTT or packet loss caps camera bitrate

- **WHEN** consecutive call health samples report elevated round-trip time or packet loss while camera video is sending
- **THEN** the outbound camera bitrate cap steps down (never below a minimum floor) and recovers after sustained clean samples
