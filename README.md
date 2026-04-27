# LinkedIn Auto Poster

A Flutter application that automates LinkedIn posting using AI for content generation and Google Apps Script for scheduling.

## Features

- **AI-Powered Content Generation**: Generate professional LinkedIn posts using Google Gemini AI
- **Multi-Post Scheduling**: Queue up to 10 posts with custom scheduled times
- **Horizontal Topic Selection**: Quick-select from pre-defined topics (AI, Flutter, Growth, etc.)
- **Custom Time Picker**: Schedule posts for specific dates and times
- **Batch Scheduling**: Send multiple posts to the backend at once
- **LinkedIn Integration**: Direct posting to LinkedIn via OAuth2

## Tech Stack

### Frontend
- Flutter 3.x (Web Support)
- Dart
- Key Packages: `http`, `flutter_dotenv`, `google_generative_ai`, `intl`

### Backend
- Google Apps Script (GAS)
- OAuth2 for LinkedIn authentication
- Google Sheets (optional, for logging)

### APIs
- Google Gemini API (Content Generation)
- LinkedIn API v2 (Posting)

## Project Structure

```
linkedin_auto_poster/
├── lib/
│   ├── core/              # Constants, theme, environment
│   ├── data/
│   │   ├── models/        # Data models
│   │   ├── repositories/  # API repositories
│   │   └── services/      # External services
│   └── presentation/
│       ├── screens/       # UI screens
│       └── widgets/       # Reusable widgets
├── backend/
│   ├── Code.gs            # Main Apps Script logic
│   └── appsscript.json    # Apps Script manifest
├── assets/
│   └── .env               # API keys and URLs
├── docs/
│   ├── SETUP_LINKEDIN_API.md
│   ├── DEPLOY_APPS_SCRIPT.md
│   └── PROMPTS.md
└── .agents/               # AI agent context
```

## Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd linkedin_auto_poster
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables

Create `assets/.env`:
```env
GEMINI_API_KEY=your_gemini_api_key
APPS_SCRIPT_URL=https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec
APPS_SCRIPT_SECRET=your_custom_secret
```

### 4. Setup LinkedIn API
Follow the guide in `docs/SETUP_LINKEDIN_API.md`

### 5. Deploy Backend
Follow the guide in `docs/DEPLOY_APPS_SCRIPT.md`

### 6. Run the App
```bash
flutter run -d chrome
```

## Usage

1. **Select a Topic**: Choose from pre-defined topics or enter a custom one
2. **Generate Content**: Click "Generate" to create AI-powered content
3. **Set Schedule**: Pick a date and time for the post
4. **Add to Queue**: Add the post to your queue (max 10 posts)
5. **Schedule All**: Send all queued posts to the backend for scheduling

## Documentation

- [LinkedIn API Setup](docs/SETUP_LINKEDIN_API.md)
- [Apps Script Deployment](docs/DEPLOY_APPS_SCRIPT.md)
- [AI Prompts Guide](docs/PROMPTS.md)

## License

This project is private and not intended for publication.
