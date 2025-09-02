# ChanBaner MVP - 禅修计时与机锋照见

A mindfulness app combining meditation timing with Koan guidance, prioritizing mobile-first and local-first architecture.

## Architecture

- **Flutter Mobile App**: Timer, Koan dialog, and journal pages
- **Koan Orchestrator**: Stateless backend for generating mirror reflections and koans
- **Local SQLite**: Encrypted storage for sessions and reflections
- **Offline-first**: Graceful fallback when API unavailable

## Features

- 定课计时 (Meditation Timer)
- 觉察日记 (Awareness Journal) 
- 机锋照见 Bot (Koan Guidance - no enlightenment judgment)

## Quick Start

### Backend
```bash
cd backend
docker-compose up
```

### Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```

## Privacy & Ethics
- No persistent storage of user text on server
- Local encryption for sensitive data
- Crisis detection with appropriate guidance
- No enlightenment state evaluation