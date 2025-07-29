# 🧬 LYFE – One Tap to Save a Life



## 📱 About LYFE

LYFE is an NFC-powered smart identity and emergency response app. It allows people to access your critical health and contact information instantly — even when you're unconscious or unreachable.

Designed for:
- 👶 Children
- 👵 Elderly
- 🧳 Solo Travelers
- 🚑 Accident Victims

With LYFE, a single tap on your NFC tag can share your public emergency profile — securely, instantly, and reliably.

---

## 🎯 Mission

> “In an emergency, seconds matter. LYFE ensures your life-saving data is never locked behind your phone.”

---

## 🚀 Key Features

- 🔐 **Login Options**
  - Email & Password
  - Google Sign-In
  - Phone OTP (via Firebase)

- 👤 **Profile Builder**
  - Name, blood group, allergies, emergency contacts, medication, and more

- 🌐 **Dynamic Public Profile**
  - Accessible via `/public/:uid`
  - Hosted on Firebase

- 📲 **One-Tap NFC Integration**
  - Write public profile URL to any NFC tag using the in-app FTA button

- 🆘 **Emergency Mode**
  - View emergency info without login by scanning NFC tag

- 🎨 **Gothic Noir UI**
  - Animated dashboard, floating action button, carousel tips, crimson-accented dark theme

---

## 🛠 Tech Stack

- **Flutter** (Web + Android)
- **Firebase** (Authentication, Firestore, Hosting)
- **GetX** (State Management)
- **flutter_nfc_kit** (NFC Read/Write)
- **Google Fonts** and **Animated Widgets**

---

## 📂 Folder Structure

lyfe_app/
├── lib/
│ ├── screens/ # UI screens (login, profile, public_view, NFC, etc.)
│ ├── controllers/ # GetX logic (auth, profile, NFC)
│ ├── models/ # User models
│ └── main.dart # Routing and app entry
├── assets/ # Fonts, icons, images
├── firebase/ # Firebase config
└── pubspec.yaml # Dependencies

yaml
Copy
Edit

---

## 🔄 Flow

1. User signs up / logs in
2. Fills emergency profile (name, blood group, contacts, etc.)
3. Hits "FTA" button → NFC tag is written with public profile URL
4. Anyone taps the tag → Public emergency profile opens instantly

---

## ✅ Development Status

| Feature             | Status       |
|---------------------|--------------|
| Firebase Auth       | ✅ Completed |
| Profile Builder     | ✅ Completed |
| Public Profile Page | ✅ Completed |
| NFC Tag Writing     | ✅ Completed |
| Emergency Bypass    | ✅ Completed |
| QR Code Integration | 🔄 In Progress |

---

## 🧪 Demo (Add when ready)

- Demo video: *[https://drive.google.com/file/d/1PRAeimf6N0OmTFpOGY8DfhRdfgkvqD-f/view?usp=sharing]*  
- Public profile preview: *https://lyfewearables-app.web.app/index.html?uid=pILhaUXkZxXkNakYSUQ48efktsh1*

---

## 📅 Submission Details

- **Challenge**: All India Developers Challenge (AIDC)
- **Organizer**: Samrat Ashok Technological Institute (SATI)
- **Year**: 2025
- **Team Lead**: S. BhagyaSree Vara Lakshmi
- **Team Member 1**: T. Shruthi
- **Team Member 2**: K. Nihal Shankar


---

## 📬 Contact

- 📧 Email: [nihalshankar004@gmail.com](mailto:nihalshankar004@gmail.com)  
- 💻 GitHub: [github.com/Nihal114/lyfe_app](https://github.com/Nihal114/lyfe_app)





---

## 🙏 Special Thanks

To the mentors, organizers, and jury of AIDC @ SATI  
for empowering students to solve real-world problems with technology.

---

> _“Build fast. Think clearly. Execute like it matters — because it does.”_
