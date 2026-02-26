# Task Management App

A production-ready Flutter application focused on clean architecture, dynamic state management, API integration mocking, and responsive Material 3 UI.

## Features Completed
- **Authentication**: Login & Registration UI with mocked APIs and secure token storage (`flutter_secure_storage`).
- **Task Management CRUD**: Create, Read, Update, Delete functionality integrated with a mocked backend and paginated responses.
- **Infinite Scrolling & Pull-to-refresh**: Implemented in the `HomeScreen` for real-world list experiences.
- **Clean Architecture Structure**: Features are segregated into `core`, `data`, `logic`, and `presentation` layers.
- **State Management**: Robust BLoC pattern for Authentication and Task CRUD flows, paired with a Cubit for dynamic Light/Dark mode toggling.
- **Dependency Injection**: Controlled instantiation via `get_it`.
- **Local Caching**: App uses `SharedPreferences` to cache the first page of tasks for offline reading capability.
- **Network Client**: Centralized `DioClient` with interceptors handling simulated headers and error mapping.

## Setup Instructions
1. Ensure you have Flutter SDK installed correctly.
2. Clone this repository and navigate to the root directory `task_mang`.
3. Run `flutter pub get` to install all required dependencies (Dio, Bloc, GetIt, etc.).
4. Run the app via `flutter run` on an emulator or a connected device.

## Architecture and State Management Choices
- **Architecture**: The app utilizes a "Clean Architecture" inspired modular layer (Data -> Logic -> Presentation). This ensures scalable testability and decoupled implementation where UI doesn't worry about data fetching logic, and data layers don't worry about how to display errors.
- **State Management**: Used **`flutter_bloc`** because of its strict separation of Events and States, making complex flows like Pagination, Refresh indicators, and asynchronous UI updates predictable and simple to debug. I specifically used a `Bloc` for Authentication and Tasks due to multiple distinct events triggering complex async states. A lightweight `Cubit` was chosen for the Theme toggling due to its straightforward emit logic without needing complex events.
- **Dependency Injection**: Used **`get_it`** as a service locator out of the widget tree to instantiate repositories, network clients, and blocs seamlessly across layers, promoting a clean, decoupled dependency tree.

## Where is the API?
The API interactions currently hit a mock backend internally defined within `AuthRepository` and `TaskRepository` to prove UI responsiveness, pagination, and error-handling without needing an external live endpoint. When you have a real URL, simply update `lib/core/constants/api_constants.dart` and swap out the simulated `Future.delayed` mocks inside the Repositories for real `dioClient` requests.

## Deliverables
- Project Code (this directory).
- **APK**: Located in `build/app/outputs/flutter-apk/app-release.apk`
