# PrepGraph Flutter Project Structure

## Overview
Production-ready Flutter application following Clean Architecture, Feature-first organization, SOLID principles, Repository Pattern, and MVVM.

## Directory Structure

```
lib/
├── core/                          # Core application-level utilities
│   ├── constants/                 # App-wide constants (strings, numbers, etc.)
│   ├── theme/                     # Material Design 3 theme configuration
│   ├── utils/                     # Helper functions and utilities
│   └── config/                    # Environment and app configuration
│
├── shared/                        # Shared resources across features
│   ├── models/                    # Shared data models (API responses, DTOs)
│   ├── repositories/              # Shared repository implementations
│   ├── services/                  # Shared services (network, storage, etc.)
│   │   ├── offline_queue/         # Offline request queue management
│   │   ├── session_management/    # JWT session & refresh token logic
│   │   └── analytics_tracking/    # Analytics event tracking
│   ├── providers/                # Shared Riverpod providers
│   └── widgets/                   # Reusable UI components
│
├── features/                      # Feature modules (Clean Architecture)
│   ├── auth/                      # Authentication & Onboarding (M0)
│   │   ├── data/                  # Data layer
│   │   │   ├── models/           # Data transfer objects, API models
│   │   │   ├── repositories/     # Repository implementations
│   │   │   └── services/         # External service integrations
│   │   ├── domain/               # Domain layer (business logic)
│   │   │   ├── entities/         # Business entities
│   │   │   ├── repositories/     # Repository interfaces (abstract)
│   │   │   └── usecases/        # Business use cases
│   │   └── presentation/         # Presentation layer (UI)
│   │       ├── providers/        # Riverpod state providers
│   │       ├── screens/          # Screen widgets
│   │       └── widgets/          # Feature-specific widgets
│   │
│   ├── dashboard/                 # Home Dashboard (M2)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── learn/                     # Knowledge Graph (M3)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── planner/                  # AI Study Planner (M4)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── pyqs/                     # PYQ Practice Center (M5)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── mock_tests/                # Mock Tests (M6)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── cutoff/                    # Cutoff Intelligence (M7)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── insights/                  # Analytics Dashboard (M8)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── resources/                 # Resource Recommendations (M9)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── profile/                  # Profile & Settings (M10)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── settings/                 # App Settings (M10 subset)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── notifications/             # Notification Center (M11)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   └── ai_assistant/              # AI Doubt Solver (M12)
│       ├── data/
│       │   ├── models/
│       │   ├── repositories/
│       │   └── services/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── providers/
│           ├── screens/
│           └── widgets/
│
├── routes/                       # GoRouter route configuration
│
└── main.dart                     # App entry point
```

## Folder Explanations

### Core
- **constants/**: App-wide constants like API endpoints, app strings, durations, sizes
- **theme/**: Material Design 3 theme, color schemes, typography, custom themes
- **utils/**: Helper functions (formatters, validators, extensions, date utilities)
- **config/**: Environment configuration (dev/staging/prod), app settings

### Shared
- **models/**: Shared data models used across multiple features (user model, response wrappers)
- **repositories/**: Shared repository implementations (local storage, cache)
- **services/**: Shared services (Dio HTTP client, SharedPreferences, logging)
  - **offline_queue/**: Offline request queue management for network resilience
  - **session_management/**: JWT session & refresh token logic
  - **analytics_tracking/**: Analytics event tracking service
- **providers/**: Global Riverpod providers (theme, connectivity, auth state)
- **widgets/**: Reusable UI components (buttons, cards, loaders, dialogs)

### Features (Clean Architecture)
Each feature follows three-layer architecture:

#### Data Layer
- **models/**: Data transfer objects, API response models, JSON serialization
- **repositories/**: Concrete implementations of repository interfaces
- **services/**: External service integrations (API calls, database operations)

#### Domain Layer
- **entities/**: Business entities (pure Dart classes, no framework dependencies)
- **repositories/**: Abstract repository interfaces (contracts)
- **usecases/**: Business logic use cases (single responsibility functions)

#### Presentation Layer
- **providers/**: Riverpod state management providers (MVVM ViewModels)
- **screens/**: Full-screen widgets (pages)
- **widgets/**: Feature-specific reusable widgets

### Routes
- GoRouter route configuration, route guards, navigation logic

## Architecture Principles

1. **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
2. **Feature-First**: Each feature is self-contained with its own layers
3. **SOLID**: Single responsibility, Open/closed, Liskov substitution, Interface segregation, Dependency inversion
4. **Repository Pattern**: Abstract data sources behind repository interfaces
5. **MVVM**: Presentation layer uses Model-View-ViewModel pattern with Riverpod

## Tech Stack Integration

- **Riverpod**: State management in `providers/` folders
- **GoRouter**: Navigation configuration in `routes/`
- **Dio**: HTTP client in `shared/services/`
- **SharedPreferences**: Local storage in `shared/services/`
- **Flutter Animate**: Animations in presentation widgets
- **Flutter SVG**: SVG assets in `shared/widgets/`
- **Google Fonts**: Typography in `core/theme/`
