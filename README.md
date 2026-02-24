# Expense Tracker

A complete offline Flutter mobile application for tracking and analyzing expenses with local storage using Hive database.

## Features

- **Complete Offline Functionality**: Works without internet connection
- **Local Data Storage**: Uses Hive database for persistent storage
- **Expense Management**: Add, edit, and delete expenses
- **Categories**: Predefined categories (Food, Transport, Bills, Shopping, Health, Others)
- **Statistics**: Visual charts showing spending patterns
- **Material 3 Design**: Modern UI with light/dark theme support
- **Philippine Peso Currency**: Properly formatted currency display

## Technical Implementation

### Architecture
- Clean architecture with organized folder structure
- Separation of concerns (models, services, screens, widgets, utils)
- Reactive UI using ValueListenableBuilder
- Material 3 design principles

### Key Dependencies
- `hive` & `hive_flutter`: Local database storage
- `path_provider`: File system access
- `uuid`: Unique ID generation
- `intl`: Internationalization and currency formatting
- `fl_chart`: Data visualization charts

### Project Structure
```
lib/
├── models/           # Data models (Expense)
├── services/         # Business logic (HiveService)
├── screens/          # UI screens (Home, AddExpense, Statistics)
├── widgets/          # Reusable components (ExpenseItem)
├── utils/            # Utilities (categories, currency formatter)
└── themes/           # App themes (light/dark)
```

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Hive Adapter**
   ```bash
   dart run build_runner build
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Usage

1. **Add Expenses**: Tap the + button to add new expenses with title, amount, category, date, and optional notes
2. **View Expenses**: See all expenses in a list with current month total
3. **Edit/Delete**: Tap on any expense to edit or delete it
4. **Statistics**: View spending analytics with pie charts and bar charts

## Data Persistence

All expenses are stored locally using Hive database:
- Database file: `expenses` box
- Automatic persistence across app restarts
- No internet connection required

## Testing Scenarios

- Add multiple expenses
- Data persistence after app restart
- Delete and update operations
- Chart accuracy verification
- Offline functionality
- Theme switching

## Build Production APK

```bash
flutter build apk --release
```

## Notes

- This is a fully offline application
- No cloud sync, login systems, or online features
- Suitable for portfolio demonstration
- Production-ready with clean, maintainable code
