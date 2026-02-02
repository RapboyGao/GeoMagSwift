# GeoMagSwift

![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

🌍 **Eine leistungsstarke Swift-Bibliothek zur Berechnung des Erdmagnetfelds mit internationalen Standardmodellen wie IGRF und WMM**.

📘 **DocC Documentation**: https://rapboygao.github.io/GeoMagSwift/documentation/geomagswift/

## 🌐 Sprache

- [English](../../README.md)
- [中文](../zh/README.md)
- [日本語](../ja/README.md)
- [Deutsch](README.md)
- [Français](../fr/README.md)
- [Español](../es/README.md)

## 📋 Inhaltsverzeichnis

- [Funktionen](#funktionen)
- [Installation](#installation)
- [Verwendung](#verwendung)
- [Modelle](#modelle)
- [API-Referenz](#api-referenz)
- [Beispiele](#beispiele)
- [Tests](#tests)
- [Lizenz](#lizenz)

## ✨ Funktionen

- 🎯 **Hochpräzisionsberechnungen**: Verwendet neueste internationale Standardmodelle
- 🌍 **Globale Abdeckung**: Genaue Berechnungen für jeden Ort auf der Erde
- 📅 **Zeitliche Entwicklung**: Unterstützt Berechnungen für Vergangenheit, Gegenwart und Zukunft
- 📱 **Cross-Platform**: Funktioniert auf macOS, iOS, watchOS und tvOS
- 🚀 **Schnelle Leistung**: Optimiert für Geschwindigkeit und Effizienz
- 📚 **Umfassende Ausgabe**: Bietet alle Magnetfeldkomponenten
- 🔄 **Mehrere Modelle**: Enthält IGRF- und WMM-Serienmodelle
- 🎨 **Einfach zu verwenden**: Einfache, intuitive API

## 🛠 Installation

### Swift Package Manager

Fügen Sie GeoMagSwift mit Swift Package Manager zu Ihrem Projekt hinzu:

1. Wählen Sie in Xcode **Datei > Paketabhängigkeiten hinzufügen...**
2. Geben Sie die Repository-URL ein: `https://github.com/RapboyGao/GeoMagSwift.git`
3. Wählen Sie die Version, die Sie verwenden möchten
4. Klicken Sie auf **Paket hinzufügen**

### Package.swift

Alternativ fügen Sie es direkt zu Ihrer `Package.swift`-Datei hinzu:

```swift
dependencies: [
    .package(url: "https://github.com/RapboyGao/GeoMagSwift.git", from: "1.0.0")
]
```

## 🚀 Verwendung

### Grundlegende Verwendung

```swift
import CoreLocation
import GeoMagSwift

// Erstelle einen Standort (Peking, China)
let location = CLLocation(latitude: 40.0, longitude: 116.0, altitude: 0)

// Hole das aktuelle Datum
let date = Date()

// Berechne das Magnetfeld mit dem IGRF14-Modell
let result = try SHCModel.igrf14.calculate(location, date: date)

// Zugriff auf die Magnetfeldkomponenten
print("Deklination: \(result.mainField.declination)°")
print("Inklination: \(result.mainField.inclination)°")
print("Gesamtschwere: \(result.mainField.totalIntensity) nT")
print("Horizontalschwere: \(result.mainField.horizontalIntensity) nT")
print("Nordkomponente: \(result.mainField.north) nT")
print("Ostkomponente: \(result.mainField.east) nT")
print("Vertikalkomponente: \(result.mainField.down) nT")

// Zugriff auf die säkulare Variation (Änderungsrate)
print("Deklinationsänderung: \(result.secularVariation.declination) Bogeminuten/Jahr")
```

### Verwendung verschiedener Modelle

```swift
// Verwenden des WMM2025-Modells
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

// Verwenden älterer IGRF-Modelle
let igrf13Result = try SHCModel.igrf13.calculate(location, date: date)
let igrf12Result = try SHCModel.igrf12.calculate(location, date: date)
```

## 📊 Modelle

GeoMagSwift enthält die folgenden Magnetfeldmodelle:

### IGRF (International Geomagnetic Reference Field)
- **IGRF-14**: Neuestes Modell (2020.0 - 2025.0)
- **IGRF-13**: Modell für 2015.0 - 2020.0
- **IGRF-12**: Modell für 2010.0 - 2015.0
- **IGRF-11**: Modell für 2005.0 - 2010.0
- **IGRF-10**: Modell für 2000.0 - 2005.0

### WMM (World Magnetic Model)
- **WMM2025**: Neuestes Modell (2025.0 - 2030.0)
- **WMM2020**: Modell für 2020.0 - 2025.0
- **WMM2015**: Modell für 2015.0 - 2020.0
- **WMM2010**: Modell für 2010.0 - 2015.0

## 📚 API-Referenz

### MagneticFieldResult

Die `calculate()`-Methode gibt ein `MagneticFieldSolution`-Objekt zurück, das Folgendes enthält:

- **mainField**: `MagneticFieldResult` mit Komponenten:
  - `north`: Nordkomponente (nT)
  - `east`: Ostkomponente (nT)
  - `down`: Vertikalkomponente (nT)
  - `horizontalIntensity`: Horizontalschwere (nT)
  - `totalIntensity`: Gesamtschwere (nT)
  - `declination`: Deklination (Grad)
  - `inclination`: Inklination (Grad)

- **secularVariation**: `MagneticFieldSecularVariation` mit Änderungsraten:
  - `north`: Änderungsrate der Nordkomponente (nT/Jahr)
  - `east`: Änderungsrate der Ostkomponente (nT/Jahr)
  - `down`: Änderungsrate der Vertikalkomponente (nT/Jahr)
  - `horizontalIntensity`: Änderungsrate der Horizontalschwere (nT/Jahr)
  - `totalIntensity`: Änderungsrate der Gesamtschwere (nT/Jahr)
  - `declination`: Änderungsrate der Deklination (Bogeminuten/Jahr)
  - `inclination`: Änderungsrate der Inklination (Bogeminuten/Jahr)

### SHCModel

Die `SHCModel`-Enumeration bietet Zugriff auf alle verfügbaren Magnetfeldmodelle:

- `igrf14`: IGRF-14-Modell
- `igrf13`: IGRF-13-Modell
- `igrf12`: IGRF-12-Modell
- `igrf11`: IGRF-11-Modell
- `igrf10`: IGRF-10-Modell
- `wmm2025`: WMM2025-Modell
- `wmm2020`: WMM2020-Modell
- `wmm2015`: WMM2015-Modell
- `wmm2010`: WMM2010-Modell

## 💡 Beispiele

### Magnetische Deklination für Navigation berechnen

```swift
import CoreLocation
import GeoMagSwift

func getMagneticDeclination(for location: CLLocation, at date: Date) -> Double {
    let result = try SHCModel.igrf14.calculate(location, date: date)
    return result.mainField.declination
}

// Verwendung
let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
let date = Date()
let declination = getMagneticDeclination(for: location, at: date)
print("Magnetische Deklination in San Francisco: \(declination)°")
```

### Modelle vergleichen

```swift
import CoreLocation
import GeoMagSwift

let location = CLLocation(latitude: 0, longitude: 0) // Äquator
let date = Date()

let igrfResult = try SHCModel.igrf14.calculate(location, date: date)
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

print("IGRF-14 Deklination: \(igrfResult.mainField.declination)°")
print("WMM2025 Deklination: \(wmmResult.mainField.declination)°")
print("Differenz: \(abs(igrfResult.mainField.declination - wmmResult.mainField.declination))°")
```

## 🧪 Tests

GeoMagSwift enthält umfassende Tests zur Sicherstellung der Genauigkeit:

- **Vergleichstests**: Verifiziert, dass die Ergebnisse mit offiziellen NOAA-Berechnungen übereinstimmen
- **Einheitentests**: Testet einzelne Komponenten und Randfälle
- **Leistungstests**: Stellt schnelle Berechnungszeiten sicher

Um die Tests auszuführen:

```bash
swift test
```

## 📄 Lizenz

GeoMagSwift steht unter der MIT-Lizenz zur Verfügung. Weitere Informationen finden Sie in der [LICENSE](../../LICENSE)-Datei.

---

**Mit ❤️ für Erdwissenschaften und Navigation erstellt**

