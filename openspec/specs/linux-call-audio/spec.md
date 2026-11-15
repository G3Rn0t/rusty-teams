# linux-call-audio Specification

## Purpose

On Linux the remote party hears the same microphone as Teams in the browser: Auto and Low send over the Pulse ADM path. Auto runs DeepFilterNet plus a speech gate on that capture buffer so background noise stays silent. Music Mode, Off, and computer sound use the software chain. Hanging up must not crash or hang the client.

## Requirements

### Requirement: Auto and Low use the Pulse device track on Linux

With noise suppression Auto or Low and music mode off, the call SHALL send the platform ADM microphone track (Pulse), not a separate silent ALSA default capture. Auto SHALL run DeepFilterNet on that capture path (WebRTC capture post-processor hook) so residual noise is gated without leaving the Pulse track. Low SHALL keep classical WebRTC noise suppression only.

#### Scenario: Default Auto matches Web Teams input

- **WHEN** the user places a call on Linux with default mic settings (Auto, music mode off)
- **THEN** the remote party hears the Pulse-selected microphone
- **AND** the local user still hears the remote party through Pulse playback
- **AND** the capture hook is armed for DeepFilterNet on that device track

#### Scenario: Low stays on the device track

- **WHEN** the user sets noise suppression to Low
- **THEN** the outgoing track remains the Pulse ADM device track
- **AND** the DeepFilterNet capture hook is not armed

### Requirement: Music mode, Off and computer sound use the software path

Music mode, noise suppression Off, and sharing computer sound SHALL capture through the software audio path. A named microphone that cannot be resolved for that path MUST fail clearly instead of falling back to an unrelated default device without notice. While that software path owns the microphone, the DeepFilterNet capture hook SHALL stay disarmed so the model does not run twice.

#### Scenario: Unresolved named mic does not silently switch

- **WHEN** the software path needs a named input that is not available for capture
- **THEN** capture fails with an error or notice
- **AND** the app does not quietly send a different default mic

#### Scenario: Computer sound keeps the capture hook off

- **WHEN** the user shares computer sound with noise suppression Auto
- **THEN** DeepFilterNet runs only in the software mic chain
- **AND** the Pulse capture hook is not armed

### Requirement: Hangup tears down audio without hanging the call task

Ending a call SHALL stop software-audio workers without joining a blocked feeder on the Tokio worker, and SHALL close the far-end sink without racing mid-callback in a way that aborts the whole app.

#### Scenario: Hangup after a software-audio call

- **WHEN** a call that used software audio ends
- **THEN** the app returns to the idle call UI
- **AND** the process stays alive

### Requirement: Diagnostics stay useful during calls

Realtime Pulse playout chatter («requesting data», «will write») MUST NOT fill the diagnostics log to the exclusion of useful call events.

#### Scenario: Diagnostics keep non-frame lines

- **WHEN** a call runs with Pulse playout
- **THEN** those per-frame Pulse lines are not written to the diagnostics log
