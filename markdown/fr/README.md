# GeoMagSwift

![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

🌍 **Une puissante bibliothèque Swift pour calculer le champ magnétique terrestre à l'aide de modèles standards internationaux comme IGRF et WMM**.

📘 **DocC Documentation**: https://rapboygao.github.io/GeoMagSwift/documentation/geomagswift/

## 🌐 Langue

- [English](../../README.md)
- [中文](../zh/README.md)
- [日本語](../ja/README.md)
- [Deutsch](../de/README.md)
- [Français](README.md)
- [Español](../es/README.md)

## 📋 Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Modèles](#modèles)
- [Référence API](#référence-api)
- [Exemples](#exemples)
- [Tests](#tests)
- [Licence](#licence)

## ✨ Fonctionnalités

- 🎯 **Calculs haute précision** : Utilise les derniers modèles standards internationaux
- 🌍 **Couverture mondiale** : Calculs précis pour n'importe quel endroit sur Terre
- 📅 **Évolution temporelle** : Prend en charge les calculs pour le passé, le présent et le futur
- 📱 **Multiplateforme** : Fonctionne sur macOS, iOS, watchOS et tvOS
- 🚀 **Performance rapide** : Optimisé pour la vitesse et l'efficacité
- 📚 **Sortie complète** : Fournit toutes les composantes du champ magnétique
- 🔄 **Plusieurs modèles** : Inclut les séries de modèles IGRF et WMM
- 🎨 **Facile à utiliser** : API simple et intuitive

## 🛠 Installation

### Swift Package Manager

Ajoutez GeoMagSwift à votre projet à l'aide de Swift Package Manager :

1. Dans Xcode, sélectionnez **Fichier > Ajouter des dépendances de package...**
2. Entrez l'URL du dépôt : `https://github.com/RapboyGao/GeoMagSwift.git`
3. Choisissez la version que vous souhaitez utiliser
4. Cliquez sur **Ajouter le package**

### Package.swift

Alternativement, ajoutez-le directement à votre fichier `Package.swift` :

```swift
dependencies: [
    .package(url: "https://github.com/RapboyGao/GeoMagSwift.git", from: "1.0.0")
]
```

## 🚀 Utilisation

### Utilisation de base

```swift
import CoreLocation
import GeoMagSwift

// Créer un emplacement (Pékin, Chine)
let location = CLLocation(latitude: 40.0, longitude: 116.0, altitude: 0)

// Obtenir la date actuelle
let date = Date()

// Calculer le champ magnétique à l'aide du modèle IGRF14
let result = try SHCModel.igrf14.calculate(location, date: date)

// Auto-select best model for this date
let autoResult = try SHCModel.calculate(
    latitude: location.coordinate.latitude,
    longitude: location.coordinate.longitude,
    altitude: location.altitude / 1000.0,
    date: date
)

// Accéder aux composantes du champ magnétique
print("Déclinaison : \(result.mainField.declination)°")
print("Inclinaison : \(result.mainField.inclination)°")
print("Intensité totale : \(result.mainField.totalIntensity) nT")
print("Intensité horizontale : \(result.mainField.horizontalIntensity) nT")
print("Composante nord : \(result.mainField.north) nT")
print("Composante est : \(result.mainField.east) nT")
print("Composante verticale : \(result.mainField.down) nT")

// Accéder à la variation séculaire (taux de changement)
print("Changement de déclinaison : \(result.secularVariation.declination) arcminutes/année")
```

### Utilisation de différents modèles

```swift
// Utiliser le modèle WMM2025
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)
let wmmhrResult = try SHCModel.wmmhr2025.calculate(location, date: date)

// Utiliser d'anciens modèles IGRF
let igrf13Result = try SHCModel.igrf13.calculate(location, date: date)
let igrf12Result = try SHCModel.igrf12.calculate(location, date: date)
```

## 📊 Modèles

GeoMagSwift inclut les modèles de champ magnétique suivants :

### IGRF (International Geomagnetic Reference Field)
- **IGRF-14** : Modèle pour 1900.0 - 2030.0
- **IGRF-13** : Modèle pour 1900.0 - 2025.0
- **IGRF-12** : Modèle pour 1900.0 - 2020.0
- **IGRF-11** : Modèle pour 1900.0 - 2015.0
- **IGRF-10** : Modèle pour 1900.0 - 2005.0

### WMM (World Magnetic Model)
- **WMMHR2025**: High-resolution model for 2025.0 - 2030.0
- **WMM2025** : Modèle pour 2025.0 - 2030.0
- **WMM2020** : Modèle pour 2020.0 - 2025.0
- **WMM2015** : Modèle pour 2015.0 - 2020.0
- **WMM2010** : Modèle pour 2010.0 - 2015.0

## 📚 Référence API

### MagneticFieldResult

La méthode `calculate()` renvoie un objet `MagneticFieldSolution` contenant :

- **mainField** : `MagneticFieldResult` avec les composantes :
  - `north` : Composante nord (nT)
  - `east` : Composante est (nT)
  - `down` : Composante verticale (nT)
  - `horizontalIntensity` : Intensité horizontale (nT)
  - `totalIntensity` : Intensité totale (nT)
  - `declination` : Déclinaison (degrés)
  - `inclination` : Inclinaison (degrés)

- **secularVariation** : `MagneticFieldSecularVariation` avec les taux de changement :
  - `north` : Taux de changement de la composante nord (nT/année)
  - `east` : Taux de changement de la composante est (nT/année)
  - `down` : Taux de changement de la composante verticale (nT/année)
  - `horizontalIntensity` : Taux de changement de l'intensité horizontale (nT/année)
  - `totalIntensity` : Taux de changement de l'intensité totale (nT/année)
  - `declination` : Taux de changement de la déclinaison (arcminutes/année)
  - `inclination` : Taux de changement de l'inclinaison (arcminutes/année)

### SHCModel

La structure `SHCModel` fournit un accès à tous les modèles de champ magnétique disponibles :

- `igrf14` : Modèle IGRF-14
- `igrf13` : Modèle IGRF-13
- `igrf12` : Modèle IGRF-12
- `igrf11` : Modèle IGRF-11
- `igrf10` : Modèle IGRF-10
- `wmmhr2025` : Modèle WMMHR2025
- `wmm2025` : Modèle WMM2025
- `wmm2020` : Modèle WMM2020
- `wmm2015` : Modèle WMM2015
- `wmm2010` : Modèle WMM2010


### Convenience APIs

- `SHCModel.bestModel(for: Date)` and `SHCModel.bestModel(for: Double)` auto-select the best available model for a date/year.
- `SHCModel.calculate(latitude:longitude:altitude:date:)` calculates directly with automatic model selection.
- `MagneticFieldSolution(latitude:longitude:altitude:date:model:)` can be initialized directly from coordinates; set `model: nil` (default) for auto-selection, or pass a specific model.

```swift
let result = try SHCModel.calculate(
    latitude: 40.0, longitude: 116.0, altitude: 0.0, date: Date()
)

let result2 = try MagneticFieldSolution(
    latitude: 40.0, longitude: 116.0, altitude: 0.0, date: Date(), model: nil
)
```

## 💡 Exemples

### Calculer la déclinaison magnétique pour la navigation

```swift
import CoreLocation
import GeoMagSwift

func getMagneticDeclination(for location: CLLocation, at date: Date) -> Double {
    let result = try SHCModel.igrf14.calculate(location, date: date)
    return result.mainField.declination
}

// Utilisation
let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
let date = Date()
let declination = getMagneticDeclination(for: location, at: date)
print("Déclinaison magnétique à San Francisco : \(declination)°")
```

### Comparer des modèles

```swift
import CoreLocation
import GeoMagSwift

let location = CLLocation(latitude: 0, longitude: 0) // Équateur
let date = Date()

let igrfResult = try SHCModel.igrf14.calculate(location, date: date)
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

print("Déclinaison IGRF-14 : \(igrfResult.mainField.declination)°")
print("Déclinaison WMM2025 : \(wmmResult.mainField.declination)°")
print("Différence : \(abs(igrfResult.mainField.declination - wmmResult.mainField.declination))°")
```

## 🧪 Tests

GeoMagSwift inclut des tests complets pour garantir la précision :

- **Tests de comparaison** : Vérifie que les résultats correspondent aux calculs officiels de la NOAA
- **Tests unitaires** : Teste les composants individuels et les cas limites
- **Tests de performance** : Garantit des temps de calcul rapides

Pour exécuter les tests :

```bash
swift test
```

## 📄 Licence

GeoMagSwift est disponible sous licence MIT. Consultez le fichier [LICENSE](../../LICENSE) pour plus d'informations.

---

**Fait avec ❤️ pour les sciences de la Terre et la navigation**

