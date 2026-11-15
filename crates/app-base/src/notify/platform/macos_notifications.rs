//! Desktop notifications on macOS through Notification Center (`notify-rust`).

use std::collections::HashMap;
use std::sync::Mutex;
use std::sync::mpsc::{Receiver, Sender, channel};
use std::thread;

use notify_rust::{Notification, Timeout};

use crate::APP_NAME;

/// RGBA image kept for API parity with Linux; macOS Notification Center uses the app icon.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct NotificationImage {
    pub width: u32,
    pub height: u32,
    pub rgba: Vec<u8>,
}

/// One notification Notification Center should show.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BusNotification {
    pub logical_key: String,
    pub replace_key: String,
    pub summary: String,
    pub body: String,
    pub actions: Vec<(String, String)>,
    pub timeout_ms: i32,
    pub urgency: u8,
    pub category: String,
    pub image: Option<NotificationImage>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NotificationEvent {
    Action {
        logical_key: String,
        action_id: String,
    },
    Reply {
        logical_key: String,
        text: String,
    },
    Closed {
        logical_key: String,
        reason: u32,
    },
}

enum Command {
    Sync {
        visible: Vec<BusNotification>,
        close: Vec<String>,
    },
    Shutdown,
}

/// macOS Notification Center client. Poll from the UI tick like the tray.
pub struct DesktopNotifications {
    commands: Sender<Command>,
    events: Mutex<Receiver<NotificationEvent>>,
}

impl DesktopNotifications {
    pub fn start() -> Option<Self> {
        let (command_tx, command_rx) = channel();
        let (event_tx, event_rx) = channel();
        thread::Builder::new()
            .name("macos-notifications".into())
            .spawn(move || run(command_rx, event_tx))
            .ok()?;
        Some(Self {
            commands: command_tx,
            events: Mutex::new(event_rx),
        })
    }

    pub fn sync(&self, visible: Vec<BusNotification>, close: Vec<String>) {
        let _ = self.commands.send(Command::Sync { visible, close });
    }

    pub fn poll(&self) -> Vec<NotificationEvent> {
        let Ok(events) = self.events.lock() else {
            return Vec::new();
        };
        let mut out = Vec::new();
        while let Ok(event) = events.try_recv() {
            out.push(event);
        }
        out
    }
}

impl Drop for DesktopNotifications {
    fn drop(&mut self) {
        let _ = self.commands.send(Command::Shutdown);
    }
}

fn fingerprint(note: &BusNotification) -> u64 {
    use std::hash::{Hash, Hasher};
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    note.replace_key.hash(&mut hasher);
    note.summary.hash(&mut hasher);
    note.body.hash(&mut hasher);
    note.timeout_ms.hash(&mut hasher);
    note.urgency.hash(&mut hasher);
    hasher.finish()
}

fn run(commands: Receiver<Command>, events: Sender<NotificationEvent>) {
    let mut published: HashMap<String, u64> = HashMap::new();
    while let Ok(command) = commands.recv() {
        match command {
            Command::Shutdown => break,
            Command::Sync { visible, close } => {
                for key in close {
                    if published.remove(&key).is_some() {
                        let _ = events.send(NotificationEvent::Closed {
                            logical_key: key,
                            reason: 3,
                        });
                    }
                }
                let mut keep = HashMap::new();
                for note in visible {
                    let key = note.replace_key.clone();
                    let print = fingerprint(&note);
                    let unchanged = published.get(&key) == Some(&print);
                    if !unchanged {
                        show(&note);
                    }
                    keep.insert(key, print);
                }
                for key in published.keys() {
                    if !keep.contains_key(key) {
                        let _ = events.send(NotificationEvent::Closed {
                            logical_key: key.clone(),
                            reason: 1,
                        });
                    }
                }
                published = keep;
            }
        }
    }
}

fn show(note: &BusNotification) {
    let timeout = if note.timeout_ms < 0 {
        Timeout::Never
    } else {
        Timeout::Milliseconds(note.timeout_ms.max(0) as u32)
    };
    let mut builder = Notification::new();
    builder
        .appname(APP_NAME)
        .summary(&note.summary)
        .body(&note.body)
        .timeout(timeout);
    // Action callbacks are limited on macOS; default activation is enough for open-chat.
    if let Err(error) = builder.show() {
        log::debug!("macos notification failed: {error}");
    }
}

/// Focus Assist / Do not disturb is not exposed the same way as freedesktop `Inhibited`.
pub fn notifications_inhibited() -> bool {
    false
}
