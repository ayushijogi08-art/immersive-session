# ArvyaX Ambient Session App

## Architecture
This project follows **Clean Architecture** principles to ensure separation of concerns:
- **Data Layer:** Handles local JSON parsing and Hive persistence for journal history.
- **Domain/Models:** Pure data classes (Ambience, JournalEntry).
- **Presentation Layer:** Organized by feature (Home, Player, Journal).

## State Management
I chose **Riverpod** for state management because:
1. It is compile-safe and avoids the "ProviderNotFoundException".
2. It allows for easy separation of logic from the UI using `StateNotifierProvider`.
3. The `SessionController` manages the global audio state, allowing the Mini-Player and Full Player to stay perfectly in sync.

## Packages Used
- `flutter_riverpod`: For predictable state management.
- `just_audio`: Chosen for its robust support for looping ambient tracks and precise seeking.
- `hive`: A lightweight, NoSQL database chosen for high-performance local persistence of journal entries.
- `intl`: For formatting session dates in the history view.

## Trade-offs & Future Improvements
Given the 8-hour timebox:
- **Audio Assets:** I used local placeholders. In a production app, these would be streamed from a CDN to reduce APK size.
- **Error Handling:** Basic error builders are implemented for assets; a more robust system using "Either" types from the Dartz package would be used in a larger project.
- **Testing:** Unit tests for the SessionController logic would be the next priority.

## Technical Choices
- **just_audio**: Used for high-fidelity audio looping and seamless seek functionality.
- **Hive**: Chosen for persistence due to its high performance and NoSQL flexibility for journal entries.

## Future Improvements
Given more time, I would implement:
- Unit tests for the SessionController.
- App lifecycle handling to pause audio when the app backgrounded.
- Streamed audio assets to minimize the initial APK size.
