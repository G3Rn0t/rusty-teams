# Spec Delta

## MODIFIED Requirements

### Requirement: Everyday work pushes to Forgejo SoT

Everyday commits and feature branches SHALL be pushed to the `origin` remote (`forgejo.lan/devops-geek/rusty-teams`). The `upstream` remote MUST NOT be the push target for routine development. The `github` remote MUST NOT be used as a work remote: no pushes, no branches created there, no commits authored against it. `.githooks/pre-push` (installed via `scripts/install-git-hooks.sh`) MUST reject pushes whose URL is `d0dg3r/rusty-teams` and pushes whose URL is `danieldaeschle/rusty-teams`.

#### Scenario: Feature branch tracks origin

- **WHEN** a developer pushes the current product branch
- **THEN** the remote is `origin` (`devops-geek/rusty-teams` on Forgejo)
- **AND** `upstream` is not updated by that push

## ADDED Requirements

### Requirement: Open upstream PR heads live on Forgejo

While a pull request from `d0dg3r/rusty-teams` to `danieldaeschle/rusty-teams` is open, its head branch SHALL exist on Forgejo (`origin`). Before any push to `origin`, `.githooks/pre-push` MUST refuse the push when such a head is absent from Forgejo and is not part of that push, and MUST refuse a push that deletes such a head. The Forgejo push mirror deletes GitHub branches that Forgejo does not have; that deletion closes the upstream pull request.

#### Scenario: Merge to Forgejo does not drop an open upstream PR

- **WHEN** a developer pushes to `origin` while an upstream pull request from `d0dg3r` is open
- **THEN** the head branch already exists on Forgejo or is included in the same push
- **AND** the pre-push hook rejects the push when the head is missing or would be deleted

#### Scenario: GitHub fork is not where the PR head is created

- **WHEN** a developer prepares an upstream pull request
- **THEN** the head is pushed to `origin` first
- **AND** the GitHub fork receives that branch only through the Forgejo push mirror
