# Tasks

## 1. App behaviour under Flatpak

- [x] 1.1 Add a small helper that reports whether `FLATPAK_ID` is set, and resolve the Linux desktop-entry id as that value when set else `rusty-teams`; verify with unit tests for set and unset env
- [x] 1.2 Gate XDG self-install offer and Settings Install/Replace/Remove when Flatpak is detected; verify with unit tests that `should_offer_install` / settings visibility stay false under `FLATPAK_ID`
- [x] 1.3 Gate `self_update_allowed` (and any Check now / Automatic updates path that replaces the binary) when Flatpak is detected; verify with unit tests
- [x] 1.4 Use the Flatpak desktop-entry id for notification hints and tray StatusNotifierItem identity; verify with unit tests that the hint equals `FLATPAK_ID` when set

## 2. Flatpak packaging artifacts

- [x] 2.1 Commit desktop file, AppStream metainfo, and icon wiring for `net.devops_geek.RustyTeams` under `packaging/flatpak/`; verify with `desktop-file-validate` and `appstreamcli validate` (or document CI equivalents)
- [x] 2.2 Rewrite `packaging/flatpak/net.devops_geek.RustyTeams.yml` for SDK build, finish-args from the design, zypak module, Chrome `extra-data` + `/app/bin/google-chrome` wrapper, cargo sources, and `only-arches: [x86_64]`; verify the manifest parses (`flatpak-builder --show-deps` or dry-run) and finish-args include notifications, tray, pipewire, pulseaudio, and `--device=all`
- [x] 2.3 Replace `packaging/flatpak/build_flatpak.sh` to generate cargo sources, run `flatpak-builder`, validate, and emit `dist/rusty-teams-<ver>-x86_64.flatpak`; verify the script fails loudly on missing tools and does not wrap a host binary by default
- [x] 2.4 Add `iproute2` (or equivalent) into `/app` if the Platform lacks `ss`; verify managed Chrome kill path can locate a listener PID inside the sandbox, or confirm `ss` is present and skip the module
- [x] 2.5 Jammy compatibility: rewrite metainfo on the host and inject Google OAuth via a temporary manifest `build-options.env` (no `flatpak-builder --env`); verify the script invokes builder without `--env=` flags
- [x] 2.6 Before `flatpak-builder`, set process-local `protocol.file.allow=always` so zypak's `nickle` submodule can clone from the local git cache; verify the build no longer fails with `transport 'file' not allowed`

## 3. Release CI and docs

- [x] 3.1 Split `.forgejo/workflows/release-linux.yaml` into packages + flatpak jobs with a publish job that waits for both; verify Flatpak failure fails the workflow (no `|| true` / best-effort)
- [x] 3.2 Update `GITHUB_RELEASE.md` and the Linux packaging notes in `README.md` for Flatpak install and Flatpak-owned updates; verify docs no longer call Flatpak best-effort

## 4. Verification

- [x] 4.1 Run `cargo test -p app-base --lib` (and any new app tests for install gating) and confirm they pass
- [x] 4.2 Run `openspec validate flatpak-package` and confirm it passes
