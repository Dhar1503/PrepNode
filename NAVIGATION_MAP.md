# PrepNode Navigation Map

## Overview
This document maps the complete navigation flow of the PrepNode application, including all inter-module connections and routing paths.

## Authentication Flow

### Splash Screen
- **Route**: `/`
- **Screen**: `SplashScreen`
- **Navigation**: Auto-navigates to `/onboarding` after 2 seconds

### Onboarding
- **Route**: `/onboarding`
- **Screen**: `OnboardingScreen`
- **Navigation**: 
  - "Get Started" button → `/login`

### Login
- **Route**: `/login`
- **Screen**: `LoginScreen`
- **Navigation**:
  - "Sign In" → `/dashboard` (on success)
  - "Create Account" → `/register`

### Register
- **Route**: `/register`
- **Screen**: `RegisterScreen`
- **Navigation**:
  - "Create Account" → `/profile-setup`

### Profile Setup
- **Route**: `/profile-setup`
- **Screen**: `ProfileSetupScreen`
- **Navigation**:
  - "Complete Setup" → `/dashboard`

## Dashboard Navigation

### Main Dashboard
- **Route**: `/dashboard`
- **Screen**: `DashboardScreen`
- **Bottom Navigation**:
  - Home → `/dashboard`
  - Learn → `/learn`
  - Practice → `/practice`
  - Insights → `/insights` (placeholder)
  - Profile → `/profile` (placeholder)

### Quick Actions (Dashboard)
- **Planner Card** → `/planner`
- **Knowledge Graph Card** → `/learn`
- **PYQ Practice Card** → `/practice`
- **Mock Tests Card** → `/mock-tests`

## Knowledge Graph Module

### Knowledge Graph Home
- **Route**: `/learn`
- **Screen**: `KnowledgeGraphHomeScreen`
- **Navigation**:
  - Subject tap → `/learn/subject/:subjectId?subjectName=:subjectName`

### Subject/Topic List
- **Route**: `/learn/subject/:subjectId?subjectName=:subjectName`
- **Screen**: `TopicListScreen`
- **Navigation**:
  - Topic tap → `/learn/topic/:topicId`

### Topic Detail
- **Route**: `/learn/topic/:topicId`
- **Screen**: `TopicDetailScreen`
- **Navigation**:
  - "View in Graph" → `/learn/graph/:topicId?topicName=:topicName`
  - "Practice PYQs" → `/practice`
  - Related topic tap → `/learn/topic/:topicId`

### Graph View
- **Route**: `/learn/graph/:topicId?topicName=:topicName`
- **Screen**: `GraphViewScreen`
- **Navigation**:
  - Node tap → `/learn/topic/:nodeId`

## Planner Module

### Planner Home
- **Route**: `/planner`
- **Screen**: `PlannerScreen`
- **Navigation**:
  - Task tap (Learn type) → `/learn/topic/:topicId`
  - Task tap (PYQ type) → `/practice`
  - Task tap (Mock Test type) → `/mock-tests`

## PYQ Module

### PYQ Home
- **Route**: `/practice`
- **Screen**: `PyqHomeScreen`
- **Navigation**:
  - Topic tap → `/practice/session/:topicId`
  - "Retry Incorrect" → (not implemented)
  - "Bookmarked" → (not implemented)

### Practice Session
- **Route**: `/practice/session/:topicId`
- **Screen**: `PracticeSessionScreen`
- **Navigation**:
  - Finish → `/practice/summary/:sessionId`
  - Related topic tap → `/learn/topic/:topicId`
  - Exit → (with confirmation dialog)

### Session Summary
- **Route**: `/practice/summary/:sessionId`
- **Screen**: `SessionSummaryScreen`
- **Navigation**:
  - "Add to Revision Plan" → `/planner`
  - "Review Incorrect Answers" → (not implemented)
  - "Back to Practice Home" → `/practice`

## Mock Test Module

### Mock Test Home
- **Route**: `/mock-tests`
- **Screen**: `MockTestHomeScreen`
- **Navigation**:
  - Test start → `/mock-tests/instructions/:testId`

### Test Instructions
- **Route**: `/mock-tests/instructions/:testId`
- **Screen**: `TestInstructionsScreen`
- **Navigation**:
  - "Start Test" → `/mock-tests/test/:testId-attempt`

### Test Interface
- **Route**: `/mock-tests/test/:attemptId`
- **Screen**: `TestInterfaceScreen`
- **Navigation**:
  - Submit → `/mock-tests/result/:attemptId`
  - Time up → `/mock-tests/result/:attemptId`

### Result Screen
- **Route**: `/mock-tests/result/:attemptId`
- **Screen**: `ResultScreen`
- **Navigation**:
  - "Review Answers" → `/mock-tests/review/:attemptId`
  - "Detailed Analysis" → `/mock-tests/analysis/:attemptId`
  - "Add to Revision Plan" → `/planner`
  - "Back to Mock Tests" → `/mock-tests`

### Review Screen
- **Route**: `/mock-tests/review/:attemptId`
- **Screen**: `ReviewScreen`
- **Navigation**:
  - Related topic tap → `/learn/topic/:topicId`
  - "Practice Related PYQs" → `/practice/session/:topicId`

### Detailed Analysis
- **Route**: `/mock-tests/analysis/:attemptId`
- **Screen**: `DetailedAnalysisScreen`
- **Navigation**: (placeholder)

## Placeholder Screens

The following screens are currently placeholders and not fully implemented:
- `/insights` - Insights module
- `/profile` - Profile module
- Retry Incorrect questions (PYQ)
- Bookmarked questions (PYQ)
- Review Incorrect Answers (PYQ)
- Detailed Analysis (Mock Test)
- Resources (Topic Detail)
- Notification Center (Dashboard)

## Navigation Parameters

### Path Parameters
- `:subjectId` - Subject identifier
- `:topicId` - Topic identifier
- `:testId` - Mock test identifier
- `:attemptId` - Test attempt identifier
- `:sessionId` - Practice session identifier

### Query Parameters
- `subjectName` - Subject name for display
- `topicName` - Topic name for display

## Navigation Technology
- **Router**: GoRouter
- **Method**: `context.go()` for navigation
- **State Management**: Riverpod
- **Deep Linking**: Supported via GoRouter configuration

## Back Stack Behavior
- GoRouter manages the navigation stack automatically
- Bottom navigation tabs maintain their own navigation stacks
- Modal screens use `Navigator.pop()` for dismissal
- All inter-module navigation uses `context.go()` for proper stack management
