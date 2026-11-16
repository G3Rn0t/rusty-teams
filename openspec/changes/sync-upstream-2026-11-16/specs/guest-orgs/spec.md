# Spec Delta

## ADDED Requirements

### Requirement: Account menu lists home and guest orgs

The account menu SHALL list every org on the signed-in account, home and guest tenants, and SHALL mark the org the window is open on.

#### Scenario: Open org is checked

- **WHEN** the user opens the account menu
- **THEN** each org of the account is listed
- **AND** the org this window is using is checked

### Requirement: Switching org restarts onto that tenant

Choosing a different org SHALL restart the app onto that tenant with that org's own cache. The previous org's cache MUST stay intact for a later switch back.

#### Scenario: Pick a guest org

- **WHEN** the user picks a guest org from the account menu
- **THEN** the app restarts on that org
- **AND** chats shown after restart come from that org's cache

### Requirement: Other orgs still announce new messages

While one org is open, a new chat message from someone else in an org that is not open SHALL show a toast, and the account menu SHALL show how many chats in that org have new messages. Choosing that count SHALL switch to the org and open the chat. Calls MUST stay on the home tenant. Outlook calendar MUST be unavailable while a guest org is open.

#### Scenario: Message arrives in an org that is not open

- **WHEN** someone else posts a new chat message in an org this window is not showing
- **THEN** the user gets a toast for that message
- **AND** the account menu count for that org includes the chat

#### Scenario: Guest org has no Outlook calendar

- **WHEN** the open org is a guest tenant
- **THEN** Outlook calendar is not offered for that org
- **AND** starting a call still uses the home tenant
