## MODIFIED Requirements

### Requirement: App manages a Chromium browser on a debug port

On macOS the app SHALL start the first Chromium browser it finds (Google Chrome, Chromium, Microsoft Edge, Brave, Helium, or Vivaldi) with a remote debugging port and its own profile under Application Support, keep it headless while signed in, and show the browser window when Teams needs a login. With `--endpoint` the app MUST attach to an existing Chromium debug endpoint instead of starting one. The app MUST NOT claim a finished built-in login that replaces that browser. Each managed instance MUST use the app's own profile so the user's everyday browser profile is never touched.

#### Scenario: Default start launches managed Chromium browser

- **WHEN** the user starts the app on macOS without `--endpoint`
- **THEN** the app starts a Chromium browser on the debug port with the managed profile
- **AND** can open Teams sessions through that instance

#### Scenario: Helium or Edge when Chrome is absent

- **WHEN** Google Chrome and Chromium are not installed but Helium, Edge, Brave, or Vivaldi is under `/Applications` or `~/Applications`
- **THEN** the app starts that browser for the managed session
- **AND** does not report that no browser is available

#### Scenario: External endpoint attaches instead

- **WHEN** the user starts with `--endpoint` pointing at a Chromium debug URL
- **THEN** the app attaches to that browser and does not start a second managed browser for that session

#### Scenario: Login window shows then returns to background

- **WHEN** Teams requires a sign-in
- **THEN** the managed browser window becomes visible for login
- **AND** after a successful Teams session with MSAL cache it returns to the background

### Requirement: Chromium browsers are found in standard locations

On macOS the app SHALL find a Chromium browser under `/Applications`, under the user's Applications folder, and on `PATH` before reporting that no browser is available. Preference order SHALL be Google Chrome, Chromium, Microsoft Edge, Brave, Helium, then Vivaldi.

#### Scenario: Chrome under Applications

- **WHEN** Google Chrome is installed under `/Applications` and not necessarily on `PATH`
- **THEN** the app still starts that Chrome for the managed session

#### Scenario: Only a Chromium fork under Applications

- **WHEN** only Helium (or Edge, Brave, Vivaldi) is installed under `/Applications`
- **THEN** the app starts that browser for the managed session

### Requirement: Headless user agent is macOS Chrome

When the managed browser runs headless on macOS, the app SHALL send a macOS Chrome user-agent string, not a Windows NT user-agent. The Chrome major in that string MUST come from the highest dotted major in the browser's `--version` output so Chromium forks that print their own product version first (for example `Helium 0.21.3.1 (Chromium 157.0.8103.78)`) still report a real Chromium major.

#### Scenario: Headless reports macOS

- **WHEN** the managed browser runs headless after sign-in on macOS
- **THEN** its user-agent identifies a macOS Chrome build

#### Scenario: Fork version line yields Chromium major

- **WHEN** `--version` prints a fork product version before the Chromium build
- **THEN** the user-agent major is the Chromium major from that line, not the fork's leading version

### Requirement: Only the managed browser owns the debug port kill

When the app stops a process that listens on the managed debug port on macOS, it MUST do so only when that process is the managed Chromium browser (including process names such as `Google Chrome`, `Chromium`, `Microsoft Edge`, `Brave Browser`, `Helium`, and `Vivaldi`).

#### Scenario: Non-browser listener is left alone

- **WHEN** another process holds the debug port
- **THEN** the app does not kill that process as if it were the managed browser
