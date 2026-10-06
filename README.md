<p align="center">
  <img src="https://raw.githubusercontent.com/khanhdocnope/Friction-X/main/assets/banner.png" alt="Friction-X Banner" width="100%" onerror="this.style.display='none'"/>
</p>

<h1 align="center">⚡ Friction-X</h1>

<p align="center">
  <strong>Next-Gen Anti-Procrastination & Behavioral Friction Engine</strong>
</p>

<p align="center">
  <em>Drain the impulsive dopamine out of digital distractions instead of triggering psychological rebellion.</em>
</p>

<p align="center">
  <a href="https://github.com/khanhdocnope/Friction-X/actions"><img src="https://img.shields.io/github/actions/workflow/status/khanhdocnope/Friction-X/build_apk.yml?branch=main&style=for-the-badge&logo=github-actions&logoColor=white&label=CI%20Build" alt="CI Status"/></a>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Windows-6366F1?style=for-the-badge&logo=flutter&logoColor=white" alt="Platforms"/>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-10B981?style=for-the-badge" alt="License"/></a>
  <img src="https://img.shields.io/badge/Version-1.0.0-EC4899?style=for-the-badge" alt="Version"/>
</p>

---

## 🧠 The Core Philosophy: Friction & Degradation > Hard Blocking

Traditional blockers (Freedom, Cold Turkey, Pomodoro timers) fail for individuals with severe executive dysfunction because the brain quickly recognizes binary blocking as an obstacle to be bypassed or disabled. 

**Friction-X** is built on behavioral psychology principles:
> **Yielding to a distraction must become physically and mentally exhausting.**

By imposing cognitive cooldowns and sensory degradation, Friction-X dissolves the impulsive dopamine urge *before* you can engage with the distracting loop.

---

## 🚀 Killer Features

### 1. 🟣 The "Micro-Friction" Gate
Whenever a monitored app (YouTube, TikTok, Reddit, etc.) is opened, Friction-X intercepts the launch. 
- You must manually type out a randomly generated **50-word philosophical reflection** verbatim.
- **Strict Anti-Cheat**: Zero copy-paste allowed (clipboard velocity detection + disabled context menus).
- **Punitive Typo Reset**: Any typo immediately wipes the active word with red haptic feedback.
- By the time the reflection is completed, impulsive craving drops to baseline.

### 2. 🟡 Sensory Degradation (Dopamine Drain Mode)
Instead of closing the app, Friction-X can degrade the sensory reward:
- **Instant Grayscale**: Converts the entire display strictly to black & white via hardware color matrices.
- **Scroll Resistance (Lag Injection)**: Throttles touch gestures and mouse wheel ticks, causing intentional stutter and micro-hangs during scrolling.
- *Doom-scrolling becomes physically unappealing and visually boring.*

### 3. 🔴 The Firewall (Hard Block Mode)
- Instantly forces windows into background or redirects the OS back to the Home Screen with a stark Cyber-Shield warning whenever a restricted app is launched during focus sessions.

### 4. 🌸 The "Later" Contract (Hostage Mode)
- Postponing a scheduled task triggers a commitment contract.
- At the agreed time, the device enters full-screen **Hostage Mode**.
- The only way to unlock is to physically scan a verified **QR Code placed at your workstation**.

---

## 🛠️ Architecture & Tech Stack

```
Friction-X
├── Flutter (Dart)          # Unified Cross-Platform Cyberpunk UI & Reactive State Engine
├── Android Native (Kotlin) # AccessibilityService, Window Overlay Canvas, Gesture Dispatcher
├── Windows Native (C++/Win32) # SetWinEventHook, Magnification API (Grayscale), WH_MOUSE_LL Hook
└── GitHub Actions CI/CD    # Automated Multi-Platform Artifact Builder (APK & Portable EXE)
```

---

## 📦 Download & Installation

You don't need Flutter or Android Studio installed. GitHub builds and packages the latest releases automatically on every update.

### 📱 Android (`.apk`)
1. Go to the [**GitHub Actions Tab**](https://github.com/khanhdocnope/Friction-X/actions).
2. Click on the latest green workflow run (`Build Friction-X`).
3. Scroll down to **Artifacts** and download **`Friction-X-Android-APK`**.
4. Extract the `.zip` and install `app-release.apk` on your device.
5. Grant **Accessibility Service** & **Display over other apps** permissions when prompted.

### 💻 Windows Desktop (`.exe`)
1. In the same [**GitHub Actions Workflow Run**](https://github.com/khanhdocnope/Friction-X/actions), download **`Friction-X-Windows-EXE`**.
2. Extract the `.zip` to any folder and run `friction_x.exe`.

---

## 💻 Local Development Setup

```bash
# Clone repository
git clone https://github.com/khanhdocnope/Friction-X.git
cd Friction-X

# Get Flutter dependencies
flutter pub get

# Run on Desktop (Windows)
flutter run -d windows

# Run on Android Device / Emulator
flutter run -d android
```

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ⚡ by <a href="https://github.com/khanhdocnope">khanhdocnope</a>
</p>
