# TrapScore

A Flutter application for managing trap shooting scores and leaderboards.

## Features

- **Authentication**: Email/Password registration and login.
- **Team Management**: Create and join teams.
- **Round Scoring**: Enter scores for singles, doubles, and handicap rounds.
- **Leaderboard**: Real-time leaderboard showing individual performance.
- **Real-time Updates**: Live updates for scores and team membership.

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Appwrite Account ([https://appwrite.io/](https://appwrite.io/))

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd create_pt
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Appwrite:
   - Create an account on [Appwrite](https://appwrite.io/)
   - Create a new project
   - Update `lib/constants.dart` with your Appwrite credentials:
     ```dart
     class AppwriteConstants {
       static const String endpoint =
           'https://fra.cloud.appwrite.io/v1'; // Your Appwrite endpoint
       static const String projectId =
           '69d3fd73001e99d0133c'; // Your Project ID
       static const String databaseId = '69d403a800137a099d8b'; // Your Database ID
     }
     ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Authentication

1. Launch the app and sign up with your email and password.
2. Log in with your credentials.

### Team Management

- **Create a Team**: Navigate to the "Teams" tab and tap "Create a Team".
- **Join a Team**: Navigate to the "Teams" tab and tap "Join a Team". Enter the team code provided by a team member.

### Scoring

1. Select the "Score" tab.
2. Choose the round type (Singles, Doubles, or Handicap).
3. Enter the scores for each station (1-25).
4. Tap "Submit" to save your scores.

### Leaderboard

1. Select the "Leaderboard" tab.
2. View your ranking based on hit percentage.
3. Switch between different round types to see various leaderboards.

## Project Structure

```
lib/
├── constants.dart          # Appwrite configuration
├── main.dart               # App entry point
├── router.dart             # Navigation routes
├── models/                 # Data models
│   ├── team.dart
│   ├── round.dart
│   └── score.dart
├── providers/              # Riverpod providers
│   ├── auth_provider.dart
│   ├── team_provider.dart
│   └── round_provider.dart
├── services/               # Appwrite service
│   └── appwrite_service.dart
├── screens/                # App screens
│   ├── auth/               # Authentication screens
│   ├── tabs/               # Tabbed navigation screens
│   └── team_gate_screen.dart # Team selection screen
└── widgets/                # Reusable widgets
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
