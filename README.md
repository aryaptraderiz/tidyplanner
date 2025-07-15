# ⏰ TidyPlanner – Stay Focused, Stay Organized

![GitHub stars](https://img.shields.io/github/stars/aryaptraderiz/tidyplanner?style=social)
![GitHub forks](https://img.shields.io/github/forks/aryaptraderiz/tidyplanner?style=social)
![GitHub issues](https://img.shields.io/github/issues/aryaptraderiz/tidyplanner)
![License](https://img.shields.io/badge/license-MIT-green)
![Flutter](https://img.shields.io/badge/Flutter-3.8.0-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)

---

## 📌 Overview

**TidyPlanner** is a modern, minimalist **Student Planner & Reminder App** built with **Flutter** to help students and professionals stay organized and productive.

With features like **Google Sign-In**, **real-time sync with Firestore**, and **local notifications**, TidyPlanner ensures you never miss a deadline or forget an important task.

> _“Plan smarter, stay focused, and achieve your goals with TidyPlanner.”_

---

## ✨ Features

### ✅ **Task & Reminder Management**
- Add, edit, and delete tasks with due dates.
- Mark tasks as completed.

### ✅ **Interactive Calendar**
- View tasks visually using an integrated calendar (`table_calendar`).

### ✅ **Google Sign-In Authentication**
- Secure login via Google accounts (`google_sign_in`).

### ✅ **Real-time Sync**
- All tasks stored securely in **Firebase Firestore**.

### ✅ **Local Notifications**
- Smart reminders powered by `flutter_local_notifications`.

### ✅ **Modern UI & UX**
- Minimalist, student-friendly design with `Google Fonts` and **Lottie animations**.

### ✅ **Cross-Platform**
- Works on Android, Web, and potentially iOS.



---

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (>=3.8.0)
- **Backend**: [Firebase Firestore](https://firebase.google.com/docs/firestore)
- **Auth**: [Firebase Auth + Google Sign-In](https://firebase.google.com/docs/auth)
- **UI/UX**:
  - [Google Fonts](https://pub.dev/packages/google_fonts)
  - [Lottie Animations](https://pub.dev/packages/lottie)
  - [Table Calendar](https://pub.dev/packages/table_calendar)
- **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## 📂 Project Structure
lib/
├── main.dart # App entry point
├── models/ # Data models (Task, User)
├── screens/ # App screens (Home, Calendar, Login, etc.)
├── services/ # Firebase & Google Auth service logic
├── widgets/ # Reusable UI components
└── utils/ # Helper functions & constants


---

## 🚀 Getting Started

### 1️⃣ **Clone Repository**

```bash
git clone https://github.com/aryaptraderiz/tidyplanner.git
cd tidyplanner


2️⃣ Install Dependencies
bash
Salin
Edit
flutter pub get
3️⃣ Setup Firebase (Optional but Recommended)
Create a project in Firebase Console.

Add google-services.json in android/app/ for Android.

(Optional) Add GoogleService-Info.plist for iOS.

4️⃣ Run the App

On Android:
bash
Salin
Edit
flutter run
On Web:
bash
Salin
Edit
flutter run -d chrome
🔧 Configuration
Update your pubspec.yaml to add app icons & splash screens:

App Icon (via flutter_launcher_icons)
yaml
Salin
Edit
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: false
  image_path: "assets/icon/tidy.png"
Generate:

bash
Salin
Edit
flutter pub run flutter_launcher_icons:main


🤝 Contributing
Want to contribute? Follow these steps:

Fork the repo.

Create a new branch (git checkout -b feature/your-feature).

Commit your changes (git commit -m "Add new feature").

Push to branch (git push origin feature/your-feature).

Create a Pull Request.

📄 License
This project is licensed under the MIT License – feel free to use, modify, and distribute.

👨‍💻 Author
Arya Putra Aderiz
🔗 GitHub 

⭐ Support the Project
If you find this project useful, give it a star ⭐ on GitHub and share it with others!


🗺 Roadmap (Future Updates)
 Dark Mode support

 iOS support

 Task categories & tags

 Export/Import tasks as CSV or PDF

 Cross-device sync improvements
