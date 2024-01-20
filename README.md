## InstaPix

### Overview
Welcome to InstaPix, a Flutter project that brings the essence of Instagram to your mobile device. InstaPix is a social media app that allows users to follow each other and share their posts. The project utilizes Firebase Storage for storing images and Firebase Firestore as a NoSQL database for efficient data management.

### Features
User Authentication: InstaPix ensures the security of user data through Firebase Authentication, allowing users to sign up, log in, and securely manage their accounts.
Profile Management: Users can set up their profiles, including profile pictures and bio information. The profile page displays the user's posts and followers.
Follow System: InstaPix implements a follow system, allowing users to follow and unfollow each other. The follower count is displayed on the user's profile.
Post Sharing: Users can share images and captions as posts, which are stored in Firebase Storage. The posts are associated with the user's profile and are visible to their followers.
Feed: The main feed displays posts from the users that the logged-in user follows. Users can like and comment on posts.

## Setup
#### Follow these steps to set up and run InstaPix locally:

Clone the InstaPix repository to your local machine:

git clone https://github.com/kushalramakanth/InstaPix

#### Navigate to the project directory:
cd instapix

#### Install dependencies:
flutter pub get

#### Set up Firebase:
Create a Firebase project on the Firebase Console.
Enable Firebase Authentication and Firestore in the project settings.
Download the google-services.json file for Android and GoogleService-Info.plist file for iOS from the Firebase Console and place them in the respective platform folders (android/app for Android, ios/Runner for iOS).

#### Run the app:
flutter run

#### Firebase Configuration
Make sure to update the Firebase configuration in the project:
Open the lib/services/firebase_service.dart file.
Replace the placeholder values with your Firebase project's configuration.
dart
Copy code
const Map<String, dynamic> firebaseConfig = {
  'apiKey': 'YOUR_API_KEY',
  'authDomain': 'YOUR_AUTH_DOMAIN',
  'projectId': 'YOUR_PROJECT_ID',
  'storageBucket': 'YOUR_STORAGE_BUCKET',
  'messagingSenderId': 'YOUR_MESSAGING_SENDER_ID',
  'appId': 'YOUR_APP_ID',
};


## Contribution
We welcome contributions to make InstaPix even better. If you have any ideas, bug fixes, or improvements, feel free to open an issue or submit a pull request.

