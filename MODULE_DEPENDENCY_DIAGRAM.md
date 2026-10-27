# PrepNode Module Dependency Diagram

## Overview
This document outlines the module dependencies and architectural relationships within the PrepNode application.

## Core Layers

### 1. Core Layer (Shared Infrastructure)
- **Location**: `lib/core/`
- **Purpose**: Shared utilities, constants, theme, and widgets
- **Dependencies**: None (foundation layer)
- **Used By**: All feature modules

#### Components:
- `theme/` - App colors, typography, theme configuration
- `constants/` - App constants, dimensions, strings
- `widgets/` - Reusable UI components (AppButton, AppTextField, etc.)
- `utils/` - Utility functions and helpers

### 2. Domain Layer (Business Logic)
- **Location**: `lib/features/*/domain/`
- **Purpose**: Business entities, use cases, repository interfaces
- **Dependencies**: Core layer only
- **Used By**: Data and Presentation layers

#### Components per module:
- `entities/` - Business entities (models)
- `repositories/` - Repository interfaces
- `usecases/` - Business logic use cases

### 3. Data Layer (Data Access)
- **Location**: `lib/features/*/data/`
- **Purpose**: Data sources, repository implementations
- **Dependencies**: Domain layer, Core layer
- **Used By**: Presentation layer

#### Components per module:
- `datasources/` - Data sources (API, local storage)
- `models/` - Data transfer objects
- `repositories/` - Repository implementations

### 4. Presentation Layer (UI)
- **Location**: `lib/features/*/presentation/`
- **Purpose**: UI screens, widgets, state management
- **Dependencies**: Domain layer, Core layer
- **Used By**: App entry point

#### Components per module:
- `screens/` - Screen widgets
- `widgets/` - Feature-specific widgets
- `providers/` - Riverpod state providers

## Feature Modules

### M0: Authentication Module
- **Location**: `lib/features/auth/`
- **Purpose**: User authentication and onboarding
- **Dependencies**: Core layer
- **Screens**:
  - `SplashScreen` - App launch and session check
  - `OnboardingScreen` - App introduction
  - `LoginScreen` - User sign in
  - `RegisterScreen` - User registration
  - `ProfileSetupScreen` - Initial profile configuration

### M1: Dashboard Module
- **Location**: `lib/features/dashboard/`
- **Purpose**: Main dashboard and navigation hub
- **Dependencies**: Core layer, Authentication module
- **Screens**:
  - `DashboardScreen` - Main dashboard with quick actions

### M2: Knowledge Graph Module
- **Location**: `lib/features/knowledge_graph/`
- **Purpose**: Syllabus visualization and topic exploration
- **Dependencies**: Core layer
- **Screens**:
  - `KnowledgeGraphHomeScreen` - Subject list
  - `TopicListScreen` - Topic hierarchy
  - `TopicDetailScreen` - Topic details and resources
  - `GraphViewScreen` - Interactive graph visualization

### M3: Planner Module
- **Location**: `lib/features/planner/`
- **Purpose**: Study planning and task management
- **Dependencies**: Core layer, Knowledge Graph module
- **Screens**:
  - `PlannerScreen` - Task list and calendar

### M4: PYQ Module
- **Location**: `lib/features/pyq/`
- **Purpose**: Previous year question practice
- **Dependencies**: Core layer, Knowledge Graph module
- **Screens**:
  - `PyqHomeScreen` - Topic selection and quick actions
  - `PracticeSessionScreen` - Question practice interface
  - `SessionSummaryScreen` - Practice results and analysis

### M5: Mock Test Module
- **Location**: `lib/features/mock_test/`
- **Purpose: Full-length mock test simulation
- **Dependencies**: Core layer, Knowledge Graph module
- **Screens**:
  - `MockTestHomeScreen` - Test type selection
  - `TestInstructionsScreen` - Test rules and instructions
  - `TestInterfaceScreen` - Test taking interface
  - `ResultScreen` - Test results overview
  - `ReviewScreen` - Question-by-question review
  - `DetailedAnalysisScreen` - Detailed performance analysis

### M6: Insights Module (Placeholder)
- **Location**: `lib/features/insights/`
- **Purpose**: Analytics and performance insights
- **Dependencies**: Core layer
- **Status**: Not implemented

### M7: Profile Module (Placeholder)
- **Location**: `lib/features/profile/`
- **Purpose**: User profile and settings
- **Dependencies**: Core layer, Authentication module
- **Status**: Not implemented

## Cross-Module Dependencies

### Navigation Dependencies
- **Dashboard** → All feature modules (via quick actions)
- **Knowledge Graph** → Planner (via task creation)
- **Knowledge Graph** → PYQ (via topic practice)
- **Planner** → Knowledge Graph (via topic learning)
- **Planner** → PYQ (via task practice)
- **Planner** → Mock Test (via mock test tasks)
- **PYQ** → Knowledge Graph (via related topics)
- **PYQ** → Planner (via revision task creation)
- **Mock Test** → Knowledge Graph (via related topics)
- **Mock Test** → PYQ (via related PYQ practice)
- **Mock Test** → Planner (via revision task creation)

### Data Dependencies
- **Knowledge Graph** provides topic data to Planner, PYQ, and Mock Test
- **PYQ** provides practice data to Insights
- **Mock Test** provides test data to Insights
- **Authentication** provides user data to all modules

## Shared Dependencies

### External Packages
- `flutter` - UI framework
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `google_fonts` - Typography
- `flutter_svg` - SVG assets

### Internal Shared
- `AppColors` - Color palette
- `AppConstants` - App-wide constants
- `AppButton` - Primary button component
- `AppSecondaryButton` - Secondary button component
- `AppTextField` - Text input component

## Dependency Graph (ASCII)

```
                    ┌─────────────────┐
                    │     Core Layer   │
                    │ (theme, widgets) │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼────────┐  ┌────────▼────────┐  ┌───────▼────────┐
│ Authentication │  │   Dashboard     │  │ Knowledge Graph│
│     Module     │  │     Module      │  │     Module     │
└───────┬────────┘  └────────┬────────┘  └───────┬────────┘
        │                    │                    │
        │                    │                    │
        │              ┌─────▼─────┐              │
        │              │  Planner  │◄─────────────┤
        │              │  Module   │              │
        │              └─────┬─────┘              │
        │                    │                    │
        │              ┌─────▼─────┐              │
        │              │    PYQ    │◄─────────────┤
        │              │  Module   │              │
        │              └─────┬─────┘              │
        │                    │                    │
        │              ┌─────▼─────┐              │
        │              │ Mock Test │◄─────────────┤
        │              │  Module   │              │
        │              └─────┬─────┘              │
        │                    │                    │
        │              ┌─────▼─────┐              │
        └─────────────►│  Insights │◄─────────────┘
                       │  Module   │
                       └───────────┘
```

## Clean Architecture Compliance

### Dependency Rule
Dependencies must only point inward, from outer layers to inner layers:
- Presentation → Domain
- Data → Domain
- No dependencies from Domain to Data or Presentation

### Module Independence
Each feature module is independently deployable and testable:
- Modules communicate through well-defined interfaces
- Navigation uses GoRouter routes (decoupled)
- State management uses Riverpod providers (reactive)

### Testing Strategy
- Domain layer: Pure Dart unit tests
- Data layer: Mock repository tests
- Presentation layer: Widget tests with mock providers

## Future Module Additions

### Planned Modules
- **Insights Module**: Analytics and performance tracking
- **Profile Module**: User settings and preferences
- **Notification Module**: Push notifications and alerts
- **Social Module**: Study groups and sharing
- **Content Module**: Rich content and media

### Integration Points
- Insights will aggregate data from PYQ and Mock Test modules
- Profile will integrate with Authentication module
- Notification will integrate with all modules for alerts
