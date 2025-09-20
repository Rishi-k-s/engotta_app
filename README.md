# Engotta (എങ്ങോട്ടാ) - Smart Navigation Companion

![License](https://img.shields.io/github/license/Rishi-k-s/engotta_app)
![Flutter Version](https://img.shields.io/badge/flutter-^3.8.1-blue)

## What is Engotta?

"എങ്ങോട്ടാ" (Engotta) - Malayalam for "Where to?" - is an innovative open hardware navigation solution designed specifically for two-wheeler riders. Born out of the frustration of constantly stopping to check maps and missing turns, Engotta provides a seamless navigation experience through a handlebar-mounted display.

## Features

### Companion App
- 🎯 Real-time location tracking
- 🗺️ Intelligent route planning
- 📍 Location search with smart suggestions
- 💾 Recent locations caching
- 📱 User-friendly interface
- 🔄 Current location detection
- 🏃 Performance optimized with debouncing

### Hardware Component (Coming Soon)
- 📺 Handlebar-mounted display
- 🧭 Turn-by-turn navigation
- 🛠️ Custom PCB design
- 🖨️ 3D printed mounting case
- 🔋 Weather-resistant design
- 📡 Bluetooth connectivity

## App Screenshots
[Coming Soon]

## Getting Started

### Prerequisites
- Flutter SDK ^3.8.1
- Android Studio / VS Code
- Google Maps API Key

### Installation

1. Clone the repository
```bash
git clone https://github.com/Rishi-k-s/engotta_app.git
```

2. Navigate to project directory
```bash
cd engotta_app
```

3. Install dependencies
```bash
flutter pub get
```

4. Add your Google Maps API key
   - Create `lib/config/api_keys.dart`
   - Add your API key:
```dart
class ApiKeys {
  static const String googlePlacesApi = 'YOUR_API_KEY';
}
```

5. Run the app
```bash
flutter run
```

## Hardware Component

The hardware component is currently under development. It will include:
- Custom PCB design files
- 3D printable case models
- Assembly instructions
- Component list
- Wiring diagrams

[Coming Soon]

## Contributing

We welcome contributions! Whether it's:
- 🐛 Bug fixes
- ✨ New features
- 📚 Documentation improvements
- 🎨 UI/UX enhancements

Please read our [Contributing Guidelines](CONTRIBUTING.md) before making a pull request.

## Roadmap

- [x] Initial app development
- [x] Location services integration
- [x] Search functionality
- [x] Location caching
- [ ] Hardware prototype
- [ ] Custom PCB design
- [ ] 3D printed case
- [ ] Bluetooth connectivity
- [ ] Turn-by-turn navigation
- [ ] Weather resistance testing

## Tech Stack

### App
- Flutter
- Google Maps API
- Geolocator
- SharedPreferences
- HTTP

### Hardware (Planned)
- Custom PCB
- ESP32
- LED Display
- 3D Printed Components

## About the Project

Engotta was born from a simple yet common problem - the need to check maps repeatedly while riding. As a rider myself, I found it frustrating and potentially dangerous to keep stopping to check directions. This project aims to solve this problem with a simple, effective, and affordable solution.

The name "എങ്ങോട്ടാ" (Engotta) comes from Malayalam, meaning "Where to?" - a common question we ask fellow riders. It perfectly encapsulates the purpose of this project - helping riders reach their destination safely and efficiently.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Rishi K S - [@YourTwitter](https://twitter.com/YourTwitter)

Project Link: [https://github.com/Rishi-k-s/engotta_app](https://github.com/Rishi-k-s/engotta_app)

---

<p align="center">Made with ❤️ for the riding community</p>
