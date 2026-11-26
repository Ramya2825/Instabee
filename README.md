# InstaBee – Social Media Application

**InstaBee** is a Flutter-based social media application that allows users to connect, share photos, interact with posts, and explore location-based features. The application uses Firebase for authentication and database management, Cloudinary for image uploads, biometric authentication for secure access, and map integration for nearby locations.

## 🚀 Features

### 🔐 Authentication
- User Registration and Login
- Firebase Authentication
- Biometric Authentication using Vonto Biometric
- Forgot Password
- Animated Splash Screen

### 🏠 Home & Posts
- View posts from different users
- Create posts with images and captions
- Like and Unlike posts
- Comment on posts
- Delete posts
- View post owner information

### 👥 Social Features
- Follow and Unfollow users
- View Followers and Following
- Explore other user profiles
- View user posts
- Display follower and following counts

### 👤 Profile Management
- View personal profile
- Edit name, username, and bio
- Update profile picture
- Display user posts

### 📍 Maps & Location Integration
- Map screen integration
- Nearby location functionality
- Location-related services
- Explore location-based features

### ✨ Animations
- Animated splash screen
- Fade animation
- Scale animation
- Smooth visual experience

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Database management |
| Cloudinary | Image upload and storage |
| Image Picker | Image selection |
| Vonto Biometric | Fingerprint authentication |
| Google Maps Flutter | Map integration |
| Geolocator / Location Services | Location functionality |
| Flutter AnimationController | UI animations |

## 🏗️ Project Architecture

The project is organized into separate folders for home pages, profile pages, login pages, services, and reusable widgets.

```text
Instabee/
│
├── assets/
│   └── icons/
│       ├── bookmark.svg
│       ├── home.svg
│       ├── like.svg
│       ├── like_fill.svg
│       ├── logo.png
│       ├── post.svg
│       ├── posts.svg
│       ├── reshare.svg
│       └── unbookmark.svg
│
├── lib/
│   │
│   ├── Allhomepages/
│   │   ├── homepage.dart
│   │   └── targetpage.dart
│   │
│   ├── Allprofilepages/
│   │   ├── drawer.dart
│   │   ├── editpage.dart
│   │   ├── profilepage.dart
│   │   └── qrpage.dart
│   │
│   ├── Logpages/
│   │   ├── loginpage.dart
│   │   └── register_page.dart
│   │
│   ├── services/
│   │   ├── biometric_service.dart
│   │   ├── cloudinary_service.dart
│   │   └── nearby_service.dart
│   │
│   ├── widgets/
│   │
│   ├── firebase_options.dart
│   ├── instabee.dart
│   ├── main.dart
│   ├── map_page.dart
│   ├── postpage.dart
│   └── splash.dart
│
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

### 📁 Folder Description

| Folder / File | Description |
|---|---|
| Allhomepages | Home feed and other users' profile pages |
| Allprofilepages | Profile, edit profile, drawer, and QR pages |
| Logpages | Login and registration screens |
| services | Biometric, Cloudinary, and nearby location services |
| widgets | Reusable UI components |
| assets/icons | Application icons and logo |
| map_page.dart | Map screen |
| splash.dart | Splash screen and animations |
| postpage.dart | Create and publish posts |
| instabee.dart | Main application navigation |
| main.dart | Application entry point |
| firebase_options.dart | Firebase configuration |

## 📍 Maps Integration

InstaBee includes map and nearby-location related functionality.

The map-related implementation is organized into:

- `map_page.dart` – Map screen.
- `nearby_service.dart` – Nearby location service.

Google Maps integration can be used to display maps and location markers. The exact functionality depends on the configured Maps API and location permissions.

## ✨ Animation Integration

The splash screen uses Flutter's animation system to create a smooth logo animation.

Implemented animation concepts include:

- `AnimationController`
- `FadeTransition`
- `ScaleTransition`

These animations improve the splash screen's appearance and provide a better user experience.

## 🔥 Firebase Integration

Firebase is used for backend functionality.

- Firebase Authentication for login and registration.
- Cloud Firestore for storing user and post information.
- Real-time data updates using Firestore streams.

## ☁️ Cloudinary Integration

Cloudinary is used for image upload and storage.

- Upload profile pictures.
- Upload post images.
- Retrieve image URLs for displaying images in the application.

## ⚙️ Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Ramya2825/Instabee.git
```

### 2. Navigate to the Project

```bash
cd REPOSITORY_NAME
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

1. Create a Firebase project.
2. Register your Android application.
3. Configure Firebase Authentication.
4. Enable Cloud Firestore.
5. Configure Firebase in your Flutter project.

### 5. Configure Cloudinary

1. Create a Cloudinary account.
2. Configure image upload settings.
3. Add the required configuration to the application.
4. Keep secret credentials out of public repositories.

### 6. Configure Google Maps

1. Create a project in Google Cloud Console.
2. Enable the required Maps SDK.
3. Generate a Google Maps API key.
4. Configure the API key in AndroidManifest.xml.
5. Configure location permissions if required.

### 7. Run the Application

```bash
flutter run
```

## 🔒 Security

- Firebase Authentication for user access.
- Firestore security rules for database protection.
- Restricted Google Maps API key.
- Avoid committing API keys and sensitive credentials to GitHub.

## 🎯 Project Objective

The objective of InstaBee is to develop an interactive social media application using Flutter and Firebase. The project focuses on social networking, image sharing, user authentication, profile management, location-based features, and an engaging user interface.

## 👩‍💻 Developed With

**Flutter | Dart | Firebase | Cloudinary | Google Maps**

*InstaBee – Connect, Share, and Explore.*
