# AskLab 🚀

A modern social media mobile application built with Flutter and Firebase. AskLab enables users to connect, share posts, and engage with a vibrant community through an intuitive and feature-rich platform.

## ✨ Features

- **User Authentication** - Secure login and registration with Firebase Authentication
- **Post Management** - Create, read, update, and delete posts with image support
- **User Profiles** - Customizable user profiles with edit functionality
- **Social Interactions** - Follow/unfollow users and view followers/following lists
- **Real-time Feed** - Browse posts from the community on your home feed
- **Search Functionality** - Discover users and content easily
- **Notifications** - Stay updated with in-app notifications
- **Image Handling** - Upload and share images with Cloudinary integration
- **Responsive UI** - Clean and modern interface with carousel support

## 🛠️ Tech Stack

- **Framework**: Flutter 3.6.1+
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Core
- **Image Processing**:
  - Image Picker
  - Cloudinary
- **UI Components**: Carousel Slider

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account and project setup

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/asklab.git
cd asklab
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your app (iOS/Android) to the Firebase project
3. Download and place the configuration files:
   - **Android**: Place `google-services.json` in `android/app/`
   - **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`
   - **macOS**: Place `GoogleService-Info.plist` in `macos/Runner/`

### 4. Configure Secrets

1. Navigate to `lib/config/`
2. Copy `secrets.dart.example` to `secrets.dart`
3. Add your API keys and configuration:

```dart
// Example configuration
class Secrets {
  static const String cloudinaryCloudName = 'your_cloud_name';
  static const String cloudinaryApiKey = 'your_api_key';
  static const String cloudinaryApiSecret = 'your_api_secret';
}
```

### 5. Run the App

```bash
flutter run
```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── config/
│   └── secrets.dart.example  # Configuration template
└── page/
    ├── AddPost.dart          # Create new posts
    ├── DetailPost.dart       # View post details
    ├── EditProfilePage.dart  # Edit user profile
    ├── FollowersFollowingPage.dart  # View followers/following
    ├── HomePage.dart         # Main feed
    ├── LoginPage.dart        # User login
    ├── NotificationPage.dart # Notifications
    ├── RegisterPage.dart     # User registration
    ├── SearchPage.dart       # Search functionality
    ├── UpdatePost.dart       # Edit posts
    └── UserProfilePage.dart  # User profile view
```

## 🔧 Configuration

### Firebase Rules

Ensure you set up proper Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules

Configure Firebase Storage rules for image uploads:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🎨 Screenshots

_(Add your app screenshots here)_

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

_(Add your information here)_

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Cloudinary for image management
- All contributors and supporters

## 📞 Support

For support, email your-email@example.com or create an issue in this repository.

---

Made with ❤️ using Flutter
