# Flutter Chat App 

A **production‑grade, real‑time chat application** built with **Flutter**, supporting **1‑on‑1 chats**, **group chats**, and an **offline‑first architecture**. The app is designed with clean state boundaries, scalability in mind, and a smooth UX even on poor networks.

---

##  Features

<p align="center">
  <img src="https://github.com/user-attachments/assets/c3ba82fa-ef10-4651-83a3-139d31ebc85d" width="235" style="margin: 10px;" />
  <img src="https://github.com/user-attachments/assets/cb4c3a40-d8fb-4144-a3e5-9fe9628d7c36" width="235" style="margin: 10px;" />
</p>

###  Messaging

* Real‑time 1‑on‑1 chat
* Group chat with member management
* Message ordering with strong consistency
* Read / delivered state ready
* Optimistic UI updates

### Offline‑First

* Local message & user caching using **Hive**
* Instant chat hydration on app launch
* Seamless sync when network is restored
* No message duplication or reordering issues

### Authentication

* Google OAuth login
* Secure session handling
* User profile persistence

###  Chat Controls

* Mute conversations
* Disappearing / self‑destructing messages (configurable)
* Custom chat composer

### ⚙️ Architecture & State

* **Riverpod** for predictable, testable state management
* Strict widget boundaries (no leaky state)
* Separation of UI, domain, and data layers
* Offline cache → remote sync pipeline

---

## 🛠 Tech Stack

| Layer            | Technology                                    |
| ---------------- | --------------------------------------------- |
| Frontend         | Flutter                                       |
| State Management | Riverpod                                      |
| Backend          | Supabase (Auth, DB, Realtime, Edge Functions) |
| Local Storage    | Hive                                          |
| Auth             | Google OAuth                                  |
| UI               | flutter_chat_ui                               |

---

## Architecture Overview

```
UI Widgets
   ↓
Riverpod Providers (State / Notifiers)
   ↓
Repositories
   ↓
Local Cache (Hive)  ↔  Remote (Supabase)
```

### Key Design Decisions

* **Offline‑first by default**: UI never waits for network
* **Single source of truth** via providers
* **Atomic message writes** to prevent race conditions
* **Deterministic ordering** across local & remote data

---

## Project Structure (Simplified)

```
lib/
 ├─ features/
 │   ├─ auth/
 │   ├─ chat/
 │   │   ├─ data/
 │   │   ├─ domain/
 │   │   └─ presentation/
 │   └─ groups/
 ├─ core/
 │   ├─ services/
 │   ├─ utils/
 │   └─ constants/
 └─ main.dart
```

---

## Getting Started

### Prerequisites

* Flutter SDK (stable)
* Supabase project
* Google OAuth credentials

### Setup

```bash
git clone https://github.com/your-username/flutter_chat_app.git
cd flutter_chat_app
flutter pub get
```

### Environment Variables

Create a `.env` file:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

### Run the App

```bash
flutter run
```

---

## Security Notes

* No API keys are stored on the client beyond public Supabase anon keys
* Sensitive logic handled via **Supabase Edge Functions**
* RLS enabled on all database tables

---

## 📌 Roadmap

* Typing indicators
* Message reactions
* Media sharing
* End‑to‑end encryption (optional mode)
* Admin controls for groups

---

## 🧪 Testing

* Provider‑level unit testing ready
* Repository abstraction allows mock data sources

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you’d like to change.

---

## 📄 License

MIT License

---

## Acknowledgements

* Flutter Team
* Supabase
* Riverpod
* flutter_chat_ui

---

> Built with a focus on **real‑world reliability**, not demo‑ware.
