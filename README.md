# GeoMagSwift

![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

🌍 **A powerful Swift library for calculating Earth's magnetic field** using international standard models like IGRF and WMM.

📘 **DocC Documentation**: https://rapboygao.github.io/GeoMagSwift/documentation/geomagswift/

## 🌐 Language

- [English](README.md)
- [中文](markdown/zh/README.md)
- [日本語](markdown/ja/README.md)
- [Deutsch](markdown/de/README.md)
- [Français](markdown/fr/README.md)
- [Español](markdown/es/README.md)

## 📋 Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Models](#models)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Testing](#testing)
- [License](#license)

## ✨ Features

- 🎯 **High Precision Calculations**: Uses latest international standard models
- 🌍 **Global Coverage**: Accurate calculations for any location on Earth
- 📅 **Time Evolution**: Supports calculations for past, present, and future dates
- 📱 **Cross-Platform**: Works on macOS, iOS, watchOS, and tvOS
- 🚀 **Fast Performance**: Optimized for speed and efficiency
- 📚 **Comprehensive Output**: Provides all magnetic field components
- 🔄 **Multiple Models**: Includes IGRF and WMM series models
- 🎨 **Easy to Use**: Simple, intuitive API

## 🛠 Installation

### Swift Package Manager

Add GeoMagSwift to your project using Swift Package Manager:

1. In Xcode, select **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/RapboyGao/GeoMagSwift.git`
3. Choose the version you want to use
4. Click **Add Package**

### Package.swift

Alternatively, add it directly to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/RapboyGao/GeoMagSwift.git", from: "1.0.0")
]
```

## 🚀 Usage

### Basic Usage

```swift
import CoreLocation
import GeoMagSwift

// Create a location (Beijing, China)
let location = CLLocation(latitude: 40.0, longitude: 116.0, altitude: 0)

// Get current date
let date = Date()

// Calculate magnetic field using IGRF14 model
let result = try SHCModel.igrf14.calculate(location, date: date)

// Access magnetic field components
print("Declination: \(result.mainField.declination)°")
print("Inclination: \(result.mainField.inclination)°")
print("Total Intensity: \(result.mainField.totalIntensity) nT")
print("Horizontal Intensity: \(result.mainField.horizontalIntensity) nT")
print("North Component: \(result.mainField.north) nT")
print("East Component: \(result.mainField.east) nT")
print("Down Component: \(result.mainField.down) nT")

// Access secular variation (rate of change)
print("Declination Change: \(result.secularVariation.declination) arcmin/year")
```

### Using Different Models

```swift
// Use WMM2025 model
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

// Use older IGRF models
let igrf13Result = try SHCModel.igrf13.calculate(location, date: date)
let igrf12Result = try SHCModel.igrf12.calculate(location, date: date)
```

## 📊 Models

GeoMagSwift includes the following magnetic field models:

### IGRF (International Geomagnetic Reference Field)
- **IGRF-14**: Latest model (2020.0 - 2025.0)
- **IGRF-13**: Model for 2015.0 - 2020.0
- **IGRF-12**: Model for 2010.0 - 2015.0
- **IGRF-11**: Model for 2005.0 - 2010.0
- **IGRF-10**: Model for 2000.0 - 2005.0

### WMM (World Magnetic Model)
- **WMM2025**: Latest model (2025.0 - 2030.0)
- **WMM2020**: Model for 2020.0 - 2025.0
- **WMM2015**: Model for 2015.0 - 2020.0
- **WMM2010**: Model for 2010.0 - 2015.0

## 📚 API Reference

### MagneticFieldResult

The `calculate()` method returns a `MagneticFieldSolution` object containing:

- **mainField**: `MagneticFieldResult` with components:
  - `north`: North component (nT)
  - `east`: East component (nT)
  - `down`: Down component (nT)
  - `horizontalIntensity`: Horizontal intensity (nT)
  - `totalIntensity`: Total intensity (nT)
  - `declination`: Declination (degrees)
  - `inclination`: Inclination (degrees)

- **secularVariation**: `MagneticFieldSecularVariation` with rates of change:
  - `north`: Rate of change of north component (nT/year)
  - `east`: Rate of change of east component (nT/year)
  - `down`: Rate of change of down component (nT/year)
  - `horizontalIntensity`: Rate of change of horizontal intensity (nT/year)
  - `totalIntensity`: Rate of change of total intensity (nT/year)
  - `declination`: Rate of change of declination (arcmin/year)
  - `inclination`: Rate of change of inclination (arcmin/year)

### SHCModel

The `SHCModel` enum provides access to all available magnetic field models:

- `igrf14`: IGRF-14 model
- `igrf13`: IGRF-13 model
- `igrf12`: IGRF-12 model
- `igrf11`: IGRF-11 model
- `igrf10`: IGRF-10 model
- `wmm2025`: WMM2025 model
- `wmm2020`: WMM2020 model
- `wmm2015`: WMM2015 model
- `wmm2010`: WMM2010 model

## 💡 Examples

### Calculate Magnetic Declination for Navigation

```swift
import CoreLocation
import GeoMagSwift

func getMagneticDeclination(for location: CLLocation, at date: Date) -> Double {
    let result = try SHCModel.igrf14.calculate(location, date: date)
    return result.mainField.declination
}

// Usage
let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
let date = Date()
let declination = getMagneticDeclination(for: location, at: date)
print("Magnetic declination in San Francisco: \(declination)°")
```

### Compare Models

```swift
import CoreLocation
import GeoMagSwift

let location = CLLocation(latitude: 0, longitude: 0) // Equator
let date = Date()

let igrfResult = try SHCModel.igrf14.calculate(location, date: date)
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

print("IGRF-14 Declination: \(igrfResult.mainField.declination)°")
print("WMM2025 Declination: \(wmmResult.mainField.declination)°")
print("Difference: \(abs(igrfResult.mainField.declination - wmmResult.mainField.declination))°")
```

## 🧪 Testing

GeoMagSwift includes comprehensive tests to ensure accuracy:

- **Comparison Tests**: Verifies results match official NOAA calculations
- **Unit Tests**: Tests individual components and edge cases
- **Performance Tests**: Ensures fast calculation times

To run the tests:

```bash
swift test
```

## 📄 License

GeoMagSwift is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

**Made with ❤️ for Earth Science and Navigation**

