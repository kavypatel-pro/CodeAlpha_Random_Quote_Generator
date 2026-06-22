# CodeAlpha Random Quote Generator

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Internship](https://img.shields.io/badge/Internship-CodeAlpha-red)](https://www.codealpha.tech/)

A feature-rich, modern Flutter application developed as part of the **CodeAlpha App Development Internship**. The application delivers inspirational and motivational quotes, leveraging local storage for persistence and offline usage, alongside an AI-powered personalized quote generator powered by the Anthropic Claude API.

---

## 📱 App Highlights & UI Preview

| Home Screen (Light/Dark) | Category Browsing | AI Personalized Quotes |
| --- | --- | --- |
| *[Screenshot Placeholder]* | *[Screenshot Placeholder]* | *[Screenshot Placeholder]* |

---

## ✨ Features

- **🎲 Random Quote Generator** - Dynamically fetches and displays quotes from local assets and APIs.
- **🔄 Instant Refresh** - Generate new quotes instantly with a single tap of the refresh button.
- **🔐 User Authentication** - Supports email/password authentication along with a **Guest Login** option for quick access.
- **🌗 Dark Mode & Light Mode** - Fluid theme transition adhering to system preferences with a custom toggle.
- **❤️ Favorite Quotes** - Save favorite quotes locally, with a dedicated tab to manage, view, or remove them.
- **🏷️ Category-based Browsing** - Browse quotes filtered by various genres (Inspirational, Success, Life, Wisdom, etc.).
- **🔍 Search Functionality** - Search for quotes by keywords or author names.
- **📤 Quote Sharing** - Share beautiful text versions of quotes to other applications on your device.
- **📴 Offline Support** - Read, browse, and search previously loaded quotes even without an active internet connection.
- **🤖 AI-Powered Personalized Quotes** - Generates tailored quotes based on user input or mood using the Anthropic API.
- **💎 Subscription Plans** - Basic, Silver, and Gold membership tiers unlocking premium features like unlimited AI quote generation.
- **🎨 Modern Material 3 UI** - A clean, sleek user interface featuring smooth transitions, micro-animations, and glassmorphism.

---

## 🛠️ Technologies & Libraries Used

The project is built using modern Flutter development practices and includes:

* **Flutter & Dart** - Core framework and language.
* **Provider** - Robust state management pattern for managing quotes, favorites, subscriptions, and settings.
* **SharedPreferences** - Local caching for offline support, favorites, user preferences, and theme status.
* **HTTP API Integration** - For fetching remote quote databases.
* **Anthropic API (Claude)** - Powers the custom AI quote generator.
* **flutter_dotenv** - Secure environment variables configuration for API keys.

---

## ⚙️ Installation & Setup

Follow these steps to set up and run the project locally on your machine.

### Prerequisites
1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22 or higher recommended).
2. Install [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter and Dart plugins.
3. Configure your emulator or connect a physical device with USB Debugging enabled.

### 🚀 Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/kavypatel-pro/CodeAlpha_Random_Quote_Generator.git
   cd CodeAlpha_Random_Quote_Generator
   ```

2. **Install Dependencies:**
   Fetch all required pub packages:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory of the project:
   ```bash
   touch .env
   ```
   Open the `.env` file and add your Anthropic Claude API Key:
   ```env
   ANTHROPIC_API_KEY=your_anthropic_api_key_here
   ```

4. **Verify Pubspec Configuration:**
   Ensure that the `.env` file and `assets` folder are registered in the `pubspec.yaml` file:
   ```yaml
   flutter:
     assets:
       - .env
       - assets/
       - assets/quotes.json
   ```

5. **Run the App:**
   Start the application on your connected device:
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```text
CodeAlpha_Random_Quote_Generator/
│
├── assets/             # JSON quote databases, images, and fonts
├── docs/               # Technical documents and design briefs
├── lib/
│   ├── models/         # Data models (Quote, User, Subscription)
│   ├── providers/      # Provider state managers
│   ├── screens/        # UI Screen files (Home, Favorites, AI generator, Auth)
│   ├── services/       # API and local database services
│   ├── widgets/        # Reusable UI component widgets
│   └── main.dart       # App entry point
├── screenshots/        # UI screenshots for documentation
└── test/               # Unit and widget tests
```

---

## ✍️ Author

**Kavy Patel**
- GitHub: [@kavypatel-pro](https://github.com/kavypatel-pro)
- Internship Role: Flutter App Development Intern (CodeAlpha)
