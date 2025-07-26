# Hogwarts Campus Connect App

## ⚡️ Overview
Hogwarts Campus Connect is a magical mobile application designed to enhance the experience of students, faculty, and alumni within the wizarding world of Hogwarts. This app centralizes key information and functionalities, from academic resources to event announcements, and allows different roles (Student, Faculty, Alumni, Admin) to interact with specific features. The entire app is lovingly themed with the enchanting aesthetics of the Harry Potter universe.

## ✨ Features

### 🧙‍♂️ User Authentication & Role Management
* **Secure Login & Signup:** Students, Faculty, Alumni, and Admin can securely create accounts and log in using their Owl Post Address (email) and Secret Incantation (password). The app ensures role-based access to specific features.
* **Role-Based Access Control:**
    * **Students:** Can view academic resources, campus events, goals, alumni network, faculty information, and student guidance.
    * **Faculty:** Has all student permissions, plus the ability to create and manage their own faculty profile, and add/edit/delete new Daily Prophet event prophecies.
    * **Alumni:** Has all student permissions, plus the ability to manage their own alumni profile.
    * **Admin (Ministry Official):** Has full administrative control, including the ability to manage any user profile (Alumni, Faculty) and any Daily Prophet event prophecy.

### 📜 My Wizard Profile (User Profile Management)
* **Personalized Profile:** Each user can view and update their personal wizard profile, including their Wizard Name, About My Magical Journey (bio), Hogwarts House/Specialization, and Hogwarts Enrollment Year (batch).
* **Profile Picture:** Users can engrave (upload) their profile scroll (picture) using their device's photo library or camera, with Cloudinary handling the magical storage.
* **Role-Specific Fields:**
    * **Alumni:** Can add their Graduation Year, Current Occupation, and Achievements/Contributions.
    * **Faculty:** Can add their Department, Role, Years at Hogwarts, and Contact Email.
* **Social Link:** Users can add a Daily Prophet Link (LinkedIn/Social) to their profile.

### 📚 Hogwarts Library & Scrolls (Academic Resources)
* **Categorized Resources:** Access academic materials categorized into:
    * **Daily Prophet:** Important announcements from the Headmaster's Office or Ministry.
    * **Curriculum Scrolls:** View syllabus and course guidelines.
    * **Spell Notes:** Access notes for various magical disciplines.
    * **Class Timetable:** View class schedules.
* **Dynamic Filtering:** Filter resources by Magical Discipline (course) and Hogwarts Year (semester).
* **Downloadable Scrolls:** Download or view external magical scrolls (PDFs, images) directly from the app.

### 📰 The Daily Prophet (Campus Events)
* **Prophecy Listings:** View upcoming magical gatherings and prophecies (events) in an engaging flip-card format.
* **Search & Filter:** Search for prophecies by title and filter by date.
* **Detailed Prophecy View:** Tap on a card to see full prophecy details, including description, date, time, location in Hogwarts, announcer, and Owl Post contact.
* **Faculty/Admin Management:**
    * **Adding Prophecies:** Faculty and Admin users see a "+" button to announce new prophecies.
    * **Editing Prophecies:** Faculty can edit their own prophecies; Admin can edit any prophecy.
    * **Banish Prophecies:** Faculty can banish (delete) their own prophecies; Admin can banish any prophecy.

### 🗺️ Marauder's Map Tasks (Goals & Task Manager)
* **Personal Missions:** Users can add, track, and manage their personal magical missions and tasks.
* **Status Tracking:** Assign statuses like "Awaiting Spell" (pending), "Casting in Progress" (in\_progress), "Spell Cast!" (completed), and "Overdue Incantation" (overdue).
* **Search & Filter:** Search tasks by title or description, and filter by status.
* **Swipe to Banish:** Easily banish (delete) completed or abandoned tasks with a swipe.

### 🧙‍♀️ Hogwarts Professors (Faculty Information)
* **Professor Directory:** View a list of all registered Hogwarts Professors.
* **Search Faculty:** Quickly find professors by name, department, or role using the search bar.
* **Faculty Self-Service:**
    * Faculty users, upon their first visit to this section, will be prompted to "Add My Professor Profile" via the FAB.
    * If they already have a profile, the FAB changes to " My Professor Profile," allowing them to update their details.
    * Admin users can add any professor profile and edit any existing profile.
* **Profile Details:** View detailed profiles including their magical department, role, years at Hogwarts, bio, contact email, and profile portrait.

### 🎩 Sorting Hat's Wisdom (Student Guidance)
* **Wizarding Career Paths:** Explore different magical career roadmaps (e.g., Auror, Magizoologist, Potions Master).
* **Timeline View:** See a step-by-step timeline for each career path, including foundational studies and advanced specializations.
* **Enchanted Scrolls & Portals:** Access useful external websites and resources relevant to wizarding careers.

## ⚙️ Technical Details

### Development Stack
* **Framework:** Flutter (for cross-platform mobile development)
* **Backend:** Google Firebase
    * **Firestore:** NoSQL Cloud Database for storing user profiles, events, academic resources, faculty, alumni, and goals data.
    * **Authentication:** For user signup, login, and role management.
* **Image Storage:** Cloudinary (for efficient storage and delivery of profile pictures and event images).
* **Routing:** Flutter's Navigator 1.0 with named routes and `onGenerateRoute` for dynamic arguments.
* **State Management:** `setState` (for local widget state) and `StreamBuilder`/`FutureBuilder` (for real-time data from Firestore).

### Important Considerations
* **Firebase Project Setup:** This app requires a Firebase project configured with Firestore and Authentication (Email/Password).
* **Firestore Security Rules:** Proper Firestore security rules are crucial for data access control. The provided rules ensure users can only access their own sensitive data, while allowing role-based creation/editing of public-facing content.
* **Cloudinary Configuration:** A Cloudinary account with an "Unsigned" upload preset is necessary for image uploads (specifically `flutter_profile_pics` as used in `cloudinary_service.dart`).
* **`pubspec.yaml`:** All required dependencies (firebase\_core, firebase\_auth, cloud\_firestore, url\_launcher, intl, cupertino\_icons, image\_picker, firebase\_storage, flip\_card, provider, google\_sign\_in, http).
* **Native Platform Setup:**
    * **Android (`AndroidManifest.xml`):** Requires `INTERNET`, `CAMERA`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` permissions and a `<queries>` block for `url_launcher` compatibility on Android 11+.
    * **iOS (`Info.plist`):** Requires `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` entries for `image_picker` to function.

## 🚀 Getting Started

1.  **Project Setup:**
    * Create a new Flutter project: `flutter create hogwarts_campus_connect`
    * coded from scratch
2.  **Set up Firebase:**
    * Create a new Firebase project.
    * Set up Firestore Database, Firebase Authentication (Enable Email/Password and Google Sign-In).
    * Copy your `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) into the `android/app` and `ios/Runner` directories respectively.
    * **Deploy Firestore Security Rules:** Use the latest rules provided in the project documentation/discussions to ensure proper access control.
    * **Deploy Firebase Storage Rules (if using Firebase Storage):** Though Cloudinary is primary for profiles, if Firebase Storage is a fallback, ensure its rules are set up.
3.  **Set up Cloudinary:**
    * Create a Cloudinary account.
    * Go to **Settings > Upload**.
    * Create an **"Unsigned" upload preset** (e.g., `flutter_profile_pics`).
    * Update `lib/services/cloudinary_service.dart` with your actual `cloudName` and `uploadPreset`.
4.  **Update `pubspec.yaml`:**
    * Ensure all `assets:` and `fonts:` sections are uncommented and correctly indented, pointing to your image and font files.
    * Run `flutter pub get` in your terminal.
5.  **Configure Native Platforms:**
    * **Android:** Update `android/app/src/main/AndroidManifest.xml` with all necessary permissions and `<queries>` block as discussed. Also `android:requestLegacyExternalStorage="true"` in `<application>` tag.
    * **iOS:** Update `ios/Runner/Info.plist` with privacy descriptions.
6.  **Run the App:**
    ```bash
    flutter clean #Clean previous builds
    flutter pub get # Fetches dependencies and assets
    flutter run #Builds and runs the application
    ```

## 🐞 Troubleshooting
* **"RenderFlex overflowed by X pixels":** Adjust `SizedBox` heights, `Padding`, or use `Expanded` and `Flexible` widgets within `Row`/`Column` to give content more room.
* **"Could not find a generator for route...":** Check `main.dart`'s `routes` and `onGenerateRoute` for correct route names and arguments.
* **"Unable to locate asset entry in pubspec.yaml":** Verify `pubspec.yaml` indentation, asset folder paths, and run `flutter pub get`.
* **"Could not launch https...":** Ensure `AndroidManifest.xml` (for Android 11+) has the correct `<queries>` block for URL schemes.
* **Profile Picture/Image Picker Issues:** Check `AndroidManifest.xml` (for Android media permissions), `Info.plist` (for iOS privacy descriptions), and your Cloudinary settings (cloud name, upload preset mode).
* **Data Not Showing/Saving:** Double-check your Firestore Security Rules and ensure field names in your model classes (`Event`, `Alumni`, `Faculty`, `Goal`) exactly match the field names in your Firestore documents.
---
**Accio App!** 🪄