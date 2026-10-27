# Remaining Placeholder Screens and Features

## Overview
This document lists all placeholder screens and features that are currently not fully implemented in the PrepNode application.

## Placeholder Screens

### 1. Insights Module
- **Route**: `/insights`
- **Status**: Not implemented
- **Purpose**: Analytics and performance insights
- **Current State**: Route exists in GoRouter but points to placeholder
- **Required Features**:
  - Performance analytics dashboard
  - Progress tracking charts
  - Strength/weakness analysis
  - Study time statistics
  - Topic-wise performance breakdown
  - Comparison with peers (optional)

### 2. Profile Module
- **Route**: `/profile`
- **Status**: Not implemented
- **Purpose**: User profile and settings
- **Current State**: Route exists in GoRouter but points to placeholder
- **Required Features**:
  - User profile display
  - Edit profile information
  - App settings
  - Notification preferences
  - Theme selection
  - Account management
  - Logout functionality

## Placeholder Features Within Implemented Screens

### PYQ Module

#### Retry Incorrect Questions
- **Location**: `PyqHomeScreen` (Quick Actions)
- **Status**: Button exists but navigation not implemented
- **Current State**: TODO comment in code
- **Required Implementation**:
  - Filter questions by incorrect status
  - Navigate to filtered practice session
  - Track incorrect question history

#### Bookmarked Questions
- **Location**: `PyqHomeScreen` (Quick Actions)
- **Status**: Button exists but navigation not implemented
- **Current State**: TODO comment in code
- **Required Implementation**:
  - Bookmark functionality in question cards
  - Filter questions by bookmark status
  - Navigate to bookmarked practice session
  - Persist bookmark state

#### Review Incorrect Answers
- **Location**: `SessionSummaryScreen`
- **Status**: Button exists but navigation not implemented
- **Current State**: TODO comment in code
- **Required Implementation**:
  - Filter session questions by incorrect answers
  - Navigate to review interface
  - Show explanations for incorrect answers

### Mock Test Module

#### Detailed Analysis Screen
- **Route**: `/mock-tests/analysis/:attemptId`
- **Status**: Screen exists but not fully implemented
- **Current State**: Placeholder implementation
- **Required Features**:
  - Detailed section-wise analysis
  - Time management analysis
  - Question difficulty breakdown
  - Topic-wise performance
  - Comparative analysis
  - Improvement suggestions

### Knowledge Graph Module

#### Resources Section
- **Location**: `TopicDetailScreen`
- **Status**: Button exists but navigation not implemented
- **Current State**: TODO comment in code
- **Required Implementation**:
  - Resource repository/data source
  - Resource list screen
  - Resource types (videos, notes, articles)
  - Resource filtering and search
  - Resource rating and feedback

### Dashboard Module

#### Notification Center
- **Location**: `DashboardScreen`
- **Status**: Notification button exists but navigation not implemented
- **Current State**: TODO comment in code
- **Required Implementation**:
  - Notification repository
  - Notification list screen
  - Notification types (reminders, achievements, updates)
  - Notification read/unread status
  - Notification preferences

## Partially Implemented Features

### Authentication Module

#### Session Management
- **Location**: `SplashScreen`
- **Status**: Session check is TODO
- **Current State**: Always routes to onboarding
- **Required Implementation**:
  - Secure token storage
  - Session validation
  - Auto-login on valid session
  - Session timeout handling

### Planner Module

#### Task Creation
- **Location**: `PlannerScreen`
- **Status**: UI exists but backend not implemented
- **Current State**: Mock data only
- **Required Implementation**:
  - Task repository
  - Task CRUD operations
  - Task scheduling
  - Task reminders
  - Task completion tracking

#### Revision Task Creation
- **Location**: `SessionSummaryScreen`, `ResultScreen`
- **Status**: Navigation exists but task creation not implemented
- **Current State**: Only navigates to planner
- **Required Implementation**:
  - Automatic revision task generation
  - Weak topic detection
  - Priority-based task scheduling
  - Integration with planner module

### PYQ Module

#### AI Hints
- **Location**: `PracticeSessionScreen`
- **Status**: UI exists but backend not implemented
- **Current State**: Static hint text
- **Required Implementation**:
  - AI hint generation
  - Hint repository
  - Hint quality tracking
  - Hint relevance scoring

#### Confidence Rating
- **Location**: `PracticeSessionScreen`
- **Status**: UI exists but backend not implemented
- **Current State**: UI only, no persistence
- **Required Implementation**:
  - Confidence tracking
  - Confidence analytics
  - Confidence vs accuracy correlation
  - Confidence-based recommendations

### Mock Test Module

#### Test Generation
- **Location**: `MockTestHomeScreen`, `TestInstructionsScreen`
- **Status**: UI exists but backend not implemented
- **Current State**: Mock data only
- **Required Implementation**:
  - Question bank management
  - Test generation algorithms
  - Difficulty balancing
  - Topic distribution
  - Time allocation

#### Test Submission
- **Location**: `TestInterfaceScreen`
- **Status**: Navigation exists but submission not implemented
- **Current State**: Only navigates to result
- **Required Implementation**:
  - Answer validation
  - Score calculation
  - Result generation
  - Attempt persistence
  - Submission analytics

## Data Layer Placeholders

### Repository Implementations
Most repository implementations are currently using mock data:
- `AuthRepository` - Mock authentication
- `PlannerRepository` - Mock task data
- `KnowledgeGraphRepository` - Mock graph data
- `PyqRepository` - Mock question data
- `MockTestRepository` - Mock test data

### Data Sources
No actual data sources are implemented:
- No API integration
- No local database (SQLite, Hive, etc.)
- No caching mechanism
- No offline data sync

## State Management Placeholders

### Riverpod Providers
Most providers are using mock data:
- Authentication providers
- Planner providers
- Knowledge Graph providers
- PYQ providers
- Mock Test providers

### Missing Providers
- Insights providers
- Profile providers
- Notification providers
- Settings providers

## Summary

### Total Placeholder Count
- **Complete Modules**: 2 (Insights, Profile)
- **Placeholder Features**: 8
- **Partial Implementations**: 7
- **Data Layer**: All repositories
- **State Management**: Missing 4 provider sets

### Priority Implementation Order
1. **High Priority**:
   - Session management (Authentication)
   - Task creation (Planner)
   - Test generation (Mock Test)
   - Resources (Knowledge Graph)

2. **Medium Priority**:
   - Retry Incorrect (PYQ)
   - Bookmarked (PYQ)
   - Detailed Analysis (Mock Test)
   - Notification Center (Dashboard)

3. **Low Priority**:
   - Insights Module
   - Profile Module
   - Social features
   - Advanced analytics

### Implementation Notes
- All placeholder features have UI components ready
- Navigation paths are defined in GoRouter
- Data models and entities are defined
- Repository interfaces are defined
- Only implementations and data sources are missing
