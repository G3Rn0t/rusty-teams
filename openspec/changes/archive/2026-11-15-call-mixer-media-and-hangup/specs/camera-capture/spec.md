## MODIFIED Requirements

### Requirement: Capture picks at least 30 fps when available

When the device offers at least one format at 30 fps, the app MUST open a stream at least 30 fps. An open below 30 fps (e.g. YUYV 1080p@5) MUST be discarded and replaced by the next candidate while a 30-fps candidate remains.

#### Scenario: C930e Auto picks MJPEG 1080p@30

- **WHEN** the camera offers YUYV only up to 1080p@5 / 720p@10 and MJPEG 1080p@30 is the highest 30-fps format within the selected 1080p ceiling (or the only 30-fps HD mode available for Auto downscaling)
- **THEN** the app opens a 30-fps MJPEG HD format rather than YUYV@5

#### Scenario: 720p quality

- **WHEN** quality is Auto or 720p and MJPEG 1280×720@30 is available
- **THEN** the app opens that 720p@30 format (or raw 30 fps at the same height), not a format below 30 fps
