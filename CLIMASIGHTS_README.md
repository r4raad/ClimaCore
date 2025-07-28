# ClimaSights - Climate Education & Disaster Tracking App

A comprehensive Flutter application focused on climate education, disaster tracking, and AI-powered environmental assistance.

## Features

### 🌍 Resilience Module
- **Real-time Disaster Tracking**: Fetches live disaster and climate news from NewsAPI and GNews
- **Disaster Event Cards**: Beautiful UI displaying disaster information with type, location, casualties, and damage
- **Search & Filter**: Search through disaster events by type, location, or keywords
- **Detailed Event Views**: Modal bottom sheets with comprehensive disaster information
- **Pull-to-refresh**: Real-time updates of disaster events

### 📚 Quiz Module
- **Climate Education Quizzes**: Comprehensive quizzes on climate change, sustainability, and environmental science
- **Progress Tracking**: Save and resume quiz progress
- **Quality Content**: Curated questions with explanations and educational value
- **Firebase Integration**: Cloud-based quiz management and progress storage
- **Convenient Quiz Management**: Easy-to-use system for adding new quizzes

### 🤖 ClimaAI Module
- **AI-Powered Chat**: Climate-focused AI assistant using local models (Ollama)
- **Local Model Integration**: Supports Llama2, Mistral, and other local models
- **Climate Expertise**: Specialized knowledge in climate science and environmental topics
- **Voice Input**: Speech-to-text capabilities for hands-free interaction
- **Conversation History**: Save and manage chat conversations

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### 2. Dependencies Installation
```bash
flutter pub get
```

### 3. Firebase Configuration
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app to the project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 4. API Keys Configuration
Create a `.env` file in the root directory:
```env
NEWS_API_KEY=your_news_api_key_here
GNEWS_API_KEY=your_gnews_api_key_here
```

### 5. AI Model Setup (Optional)
For local AI functionality:

#### Option A: Ollama (Recommended)
1. Install Ollama from [ollama.ai](https://ollama.ai/)
2. Pull a climate-focused model:
```bash
ollama pull llama2:7b
# or
ollama pull mistral:7b
```

#### Option B: Cloud AI (Fallback)
The app includes fallback responses when local models are unavailable.

### 6. News API Setup
1. Get API keys from:
   - [NewsAPI](https://newsapi.org/) (free tier available)
   - [GNews](https://gnews.io/) (free tier available)
2. Update the API keys in `lib/services/news_service.dart`

## Quiz Management

### Adding New Quizzes
You can add quizzes in two ways:

#### Method 1: Firebase Console
1. Go to your Firebase Console
2. Navigate to Firestore Database
3. Create a `quizzes` collection
4. Add quiz documents with the following structure:
```json
{
  "id": "unique-quiz-id",
  "title": "Quiz Title",
  "description": "Quiz description",
  "author": "Author name",
  "category": "Climate Science",
  "questionCount": 10,
  "timeLimit": 300,
  "points": 50,
  "rating": 4.5,
  "imageUrl": "assets/images/quiz/quiz_image.png",
  "videoUrl": "https://youtube.com/watch?v=example",
  "questions": [...],
  "createdAt": "timestamp",
  "isActive": true
}
```

#### Method 2: JSON Import
1. Use the sample structure in `assets/data/sample_quizzes.json`
2. Add your quiz data to the JSON file
3. Import via the app's admin interface (to be implemented)

### Quiz Structure
Each quiz contains:
- **Basic Info**: Title, description, author, category
- **Settings**: Question count, time limit, points, rating
- **Media**: Image and video URLs
- **Questions**: Array of question objects with answers and explanations

## AI Configuration

### Local Model Optimization
The app supports model optimization for climate conversations:

1. **Unsloth Integration** (Optional):
   - Install Unsloth for model fine-tuning
   - Use climate-specific datasets for better responses

2. **Ollama Models**:
   - Llama2: Good general performance
   - Mistral: Better reasoning capabilities
   - Custom fine-tuned models for climate expertise

### Climate-Focused Prompts
The AI is configured with specialized prompts for:
- Climate science explanations
- Environmental impact assessment
- Sustainable solutions
- Carbon footprint calculations
- Renewable energy information

## Architecture

### Models
- `DisasterEvent`: Disaster news and events
- `Quiz`, `QuizQuestion`, `QuizAnswer`: Quiz system
- `AIMessage`, `AIConversation`: AI chat functionality

### Services
- `NewsService`: Real-time disaster news fetching
- `QuizService`: Quiz management and progress tracking
- `AIService`: AI chat with local/cloud models

### Widgets
- `ResilienceTab`: Disaster tracking interface
- `QuizTab`: Quiz selection and progress
- `AIChatScreen`: AI conversation interface
- Various UI components for cards, bubbles, etc.

## Customization

### UI Theming
- Primary color: `#4CAF50` (Green)
- Secondary color: `#2E7D32` (Dark Green)
- Font: Questrial (Google Fonts)

### Adding New Disaster Types
1. Update `_disasterTypeMapping` in `NewsService`
2. Add corresponding icons in `DisasterEventCard`
3. Update color schemes for new types

### Extending AI Capabilities
1. Modify system prompts in `AIService`
2. Add new climate topics to suggestions
3. Implement additional AI features

## Troubleshooting

### Common Issues

1. **News API Errors**:
   - Check API key configuration
   - Verify internet connection
   - Check API rate limits

2. **AI Model Not Working**:
   - Ensure Ollama is running: `ollama serve`
   - Check model availability: `ollama list`
   - Verify localhost:11434 is accessible

3. **Firebase Issues**:
   - Verify Firebase configuration files
   - Check Firestore rules
   - Ensure proper authentication setup

### Performance Optimization
- Use cached network images for disaster photos
- Implement pagination for large datasets
- Optimize AI model loading times

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the Firebase documentation

---

**Note**: This app is designed for educational purposes and climate awareness. Always verify information from official sources for critical decisions. 