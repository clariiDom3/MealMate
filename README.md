# 🥗 MealMate

**MealMate** is a Flutter-based mobile application that helps users plan their meals, track ingredients, analyze nutrition, and export shopping lists — all based on their dietary preferences.

---


## 🚀 Features

- 🗓 Select and schedule meals by day
- 🔍 Filter meals by dietary preferences (vegan, pescatarian, etc.)
- 🍳 Browse meals by category (Breakfast, Lunch, Dinner, Snacks)
- 📊 Analyze meal nutrition (calories, protein, fat, carbs)
- ❤️ Favorite meals for quick access
- 📤 Export a shopping list based on selected meals
- 🧠 Data stored locally with optional cloud sync (planned)

---

## 📁 Folder Structure

```bash
lib/
├── add/               # UI for adding meals
├── home/              # Main meal model and utilities
├── profile/           # User profile and preferences
├── shared/            # Shared widgets/components
├── main.dart          # App entry point
```

---

## ⚙️ Technologies Used
- Flutter
- Dart
- ScopedModel for state management
- HTTP package for fetching meals
- Path Provider and Share Plus for file export
- Local SQLite database (via MealDBWorker)

---

## 📦 Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/mealmate.git
cd mealmate
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```
---

## 🙋‍♀️ Author
Made with ❤️ by Clarissa Dominguez — the brain and heart behind MealMate.


[LinkedIn](https://www.linkedin.com/in/clarissa-dominguez/)

---

Want to try out a new Flutter project?

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
