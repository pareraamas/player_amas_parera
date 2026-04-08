# 🎥 Player Amas Parera
### *Premium HLS Video Player with Dynamic Ad Integration*

[![Flutter](https://img.shields.io/badge/Flutter-v3.10.8-blue.svg)](https://flutter.dev/)
[![GetX](https://img.shields.io/badge/Statemanagement-GetX-purple.svg)](https://pub.dev/packages/get)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-orange.svg)](https://flutter.dev/)

---

## 🌟 Overview
**Player Amas Parera** adalah aplikasi pemutar video modern berbasis Flutter yang dirancang untuk pengalaman streaming HLS (*HTTP Live Streaming*) yang mulus. Aplikasi ini mengintegrasikan mesin iklan dinamis yang memastikan monetisasi tetap berjalan tanpa mengabaikan estetika desain premium.

![App Icon](assets/icon.png)

---

## ✨ Key Features

### 📺 High-End Video Playback
- **HLS Support**: Mendukung streaming video adaptif (m3u8) dari provider terkemuka seperti Mux.
- **Buffer Management**: Indikator buffering cerdas untuk pengalaman menonton tanpa hambatan.
- **Custom Controls**: Kontrol video yang bersih dengan fitur *auto-hide* cerdas (4 detik).

### 📢 Smart Ad Engine
- **Timed Interruptions**: Iklan gambar muncul otomatis setiap **30 detik**.
- **Non-Skip Countdown**: Setiap iklan menampilkan *timer* hitung mundur **7 detik** sebelum video dilanjutkan kembali.
- **Randomized Ads**: Sistem secara acak memilih dari berbagai aset iklan premium.

### 🎨 Premium Aesthetics
- **Elite Dark Theme**: UI berbasis warna *deep charcoal* dan *royal purple* untuk kenyamanan mata.
- **Stateless Architecture**: Menggunakan GetX untuk performa maksimal dan kode yang bersih.
- **Glassmorphic Dialogs**: Informasi aplikasi tersaji dalam dialog transparan yang modern.

### 🔊 Advanced Control Systems
- **Precision Seeking**: Slider progres video yang responsif.
- **Volume Slider & Toggle**: Kontrol audio granular langsung dari layar pemutar.

---

## 🛠️ Technology Stack
- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [GetX](https://pub.dev/packages/get)
- **Video Engine:** [video_player](https://pub.dev/packages/video_player)
- **Icons:** [Cupertino Icons](https://pub.dev/packages/cupertino_icons) & [Material Icons](https://api.flutter.dev/flutter/material/Icons-class.html)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10.8 or newer)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation
1.  **Clone the repository**
    ```bash
    git clone https://github.com/pareraamas/player_amas_parera.git
    ```
2.  **Get dependencies**
    ```bash
    flutter pub get
    ```
3.  **Generate Launcher Icons** (Optional)
    ```bash
    dart run flutter_launcher_icons
    ```
4.  **Run the application**
    ```bash
    flutter run
    ```

---

## 📁 Project Structure
```text
lib/
├── app/
│   ├── modules/
│   │   └── home/
│   │       ├── bindings/     # Dependency injection
│   │       ├── controllers/  # Business logic & timers
│   │       ├── views/        # UI & Layout
│   │       └── dialog/       # Custom components
│   └── routes/               # Navigation configuration
└── main.dart                 # App Entry Point
```

---

## 📝 Configuration
Aplikasi ini sudah dikonfigurasi dengan:
- **Izin Internet**: Diaktifkan di `AndroidManifest.xml`.
- **HLS Streaming**: Menggunakan URL test dari `test-streams.mux.dev`.
- **Aset Iklan**: Terdaftar di `pubspec.yaml` dalam folder `assets/ads/`.

---

## 👨‍💻 Developer
**Amas Parera** - [GitHub](https://github.com/pareraamas)

---
*Developed with ❤️ using Flutter & GetX.*
