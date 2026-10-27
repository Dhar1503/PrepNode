# Roadmap to a Compilable and Runnable App

The PrepNode project currently has **431 analyzer errors**. These errors prevent the app from compiling and running. This plan outlines the systematic approach to resolving these errors and achieving a stable, runnable state.

## Core Strategy

We will resolve errors module-by-module, following dependency order. The most critical "Core" issues (like conflicting `Failure` definitions) will be handled first, as they impact multiple modules.

## Phase 1: Core & Foundation Fixes
**Goal:** Fix global conflicts and standard utilities.

- **Consolidate Failures:** Merge `lib/core/data/failures.dart` and `lib/core/utils/failures.dart` into a single source of truth. Most repositories currently suffer from "invalid override" errors because of this duplication.
- **Update API Constants:** Add missing endpoints (`login`, `register`, `mockTests`, etc.) to `lib/core/network/api_constants.dart` to fix "undefined getter" errors in remote data sources.
- **Fix Global Providers:** Resolve the type mismatch in `engagementRepositoryProvider` in `data_providers.dart`.

## Phase 2: Authentication Module
**Goal:** Fix the entry point of the app.

- **Update User Entity:** Add missing preparation fields (`examId`, `targetDate`, `dailyStudyHours`, `preparationLevel`) to match database schema.
- **Fix Data Sources:** Resolve `UsersCompanion` errors by ensuring correct imports and alignment with the Drift-generated code.
- **Dependency Injection:** Update `auth_providers.dart` to pass required parameters.

## Phase 3: Intelligence Modules (Cutoff & Insights)
**Goal:** Restore specialized analytics features.

- **Schema Update:** Add `UserAnalytics` and `StudySessions` tables to `database.dart`.
- **Data Parsing:** Fix type mismatches (e.g., `String` to `int`) in remote data sources.
- **DI & Repositories:** Replace missing mock implementations with real repository logic in providers.

## Phase 4: Mock Test & Assessment
**Goal:** Resolve the largest block of errors (~150).

- **Entity Alignment:** Update `MockTestAttempt` and related entities to include required constructor arguments like `accuracy` and `durationSeconds`.
- **Database Schema:** Align the Drift schema with the features being accessed in `mock_test_local_datasource.dart`.
- **Type Safety:** Fix numeric parsing from API responses.

## Phase 5: Knowledge Graph & Final Build
**Goal:** Clean up remaining feature errors and generate code.

- **Restore Missing Entities:** Re-create or correctly import `Exam`, `Subject`, and `Topic` entities in the Knowledge Graph module.
- **Build Runner:** Execute `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate Drift database code.

## Verification & Execution Plan

### 1. Sequential Execution
I will execute the fixes in the following order:
1.  **Core**
2.  **Auth**
3.  **Cutoff**
4.  **Insights**
5.  **Mock Test**
6.  **Knowledge Graph**

### 2. Verification
After each module is fixed, I will run `flutter analyze` for that specific module to ensure zero errors before proceeding.

### 3. Final Step: Run
Once the analyzer reports **0 errors**, I will attempt to run the app.

---

> [!IMPORTANT]
> Consolidation of `Failure` classes may require minor updates to catch blocks throughout the project, but it is necessary for architectural integrity.

> [!CAUTION]
> Updating the database schema (`database.dart`) requires a full `build_runner` execution. If you have any local data in a dev emulator, it may need to be reset.

---

**Do you approve this roadmap to proceed with the Core and Auth fixes?**
