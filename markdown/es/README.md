# GeoMagSwift

![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

🌍 **Una potente biblioteca Swift para calcular el campo magnético terrestre utilizando modelos estándar internacionales como IGRF y WMM**.

📘 **DocC Documentation**: https://rapboygao.github.io/GeoMagSwift/documentation/geomagswift/

## 🌐 Idioma

- [English](../../README.md)
- [中文](../zh/README.md)
- [日本語](../ja/README.md)
- [Deutsch](../de/README.md)
- [Français](../fr/README.md)
- [Español](README.md)

## 📋 Tabla de contenido

- [Características](#características)
- [Instalación](#instalación)
- [Uso](#uso)
- [Modelos](#modelos)
- [Referencia API](#referencia-api)
- [Ejemplos](#ejemplos)
- [Pruebas](#pruebas)
- [Licencia](#licencia)

## ✨ Características

- 🎯 **Cálculos de alta precisión**: Utiliza los últimos modelos estándar internacionales
- 🌍 **Cobertura global**: Cálculos precisos para cualquier ubicación en la Tierra
- 📅 **Evolución temporal**: Soporta cálculos para pasado, presente y futuro
- 📱 **Multiplataforma**: Funciona en macOS, iOS, watchOS y tvOS
- 🚀 **Rendimiento rápido**: Optimizado para velocidad y eficiencia
- 📚 **Salida completa**: Proporciona todos los componentes del campo magnético
- 🔄 **Múltiples modelos**: Incluye series de modelos IGRF y WMM
- 🎨 **Fácil de usar**: API simple e intuitiva

## 🛠 Instalación

### Swift Package Manager

Agregue GeoMagSwift a su proyecto usando Swift Package Manager:

1. En Xcode, seleccione **Archivo > Agregar dependencias de paquete...**
2. Ingrese la URL del repositorio: `https://github.com/RapboyGao/GeoMagSwift.git`
3. Elija la versión que desea usar
4. Haga clic en **Agregar paquete**

### Package.swift

Alternativamente, agréguelo directamente a su archivo `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/RapboyGao/GeoMagSwift.git", from: "1.0.0")
]
```

## 🚀 Uso

### Uso básico

```swift
import CoreLocation
import GeoMagSwift

// Crear una ubicación (Pekín, China)
let location = CLLocation(latitude: 40.0, longitude: 116.0, altitude: 0)

// Obtener la fecha actual
let date = Date()

// Calcular el campo magnético usando el modelo IGRF14
let result = try SHCModel.igrf14.calculate(location, date: date)

// Auto-select best model for this date
let autoResult = try SHCModel.calculate(
    latitude: location.coordinate.latitude,
    longitude: location.coordinate.longitude,
    altitude: location.altitude / 1000.0,
    date: date
)

// Acceder a los componentes del campo magnético
print("Declinación: \(result.mainField.declination)°")
print("Inclinación: \(result.mainField.inclination)°")
print("Intensidad total: \(result.mainField.totalIntensity) nT")
print("Intensidad horizontal: \(result.mainField.horizontalIntensity) nT")
print("Componente norte: \(result.mainField.north) nT")
print("Componente este: \(result.mainField.east) nT")
print("Componente vertical: \(result.mainField.down) nT")

// Acceder a la variación secular (tasa de cambio)
print("Cambio de declinación: \(result.secularVariation.declination) minutos de arco/año")
```

### Usando diferentes modelos

```swift
// Usar el modelo WMM2025
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)
let wmmhrResult = try SHCModel.wmmhr2025.calculate(location, date: date)

// Usar modelos IGRF más antiguos
let igrf13Result = try SHCModel.igrf13.calculate(location, date: date)
let igrf12Result = try SHCModel.igrf12.calculate(location, date: date)
```

## 📊 Modelos

GeoMagSwift incluye los siguientes modelos de campo magnético:

### IGRF (Campo de Referencia Geomagnético Internacional)
- **IGRF-14**: Latest model (1900.0 - 2030.0)
- **IGRF-13**: Model for 1900.0 - 2025.0
- **IGRF-12**: Model for 1900.0 - 2020.0
- **IGRF-11**: Model for 1900.0 - 2015.0
- **IGRF-10**: Model for 1900.0 - 2005.0

### WMM (Modelo Magnético Mundial)
- **WMMHR2025**: High-resolution model for 2025.0 - 2030.0
- **WMM2025**: Model for 2025.0 - 2030.0
- **WMM2020**: Model for 2020.0 - 2025.0
- **WMM2015**: Model for 2015.0 - 2020.0
- **WMM2010**: Model for 2010.0 - 2015.0

## 📚 Referencia API

### MagneticFieldResult

El método `calculate()` devuelve un objeto `MagneticFieldSolution` que contiene:

- **mainField**: `MagneticFieldResult` con componentes:
  - `north`: Componente norte (nT)
  - `east`: Componente este (nT)
  - `down`: Componente vertical (nT)
  - `horizontalIntensity`: Intensidad horizontal (nT)
  - `totalIntensity`: Intensidad total (nT)
  - `declination`: Declinación (grados)
  - `inclination`: Inclinación (grados)

- **secularVariation**: `MagneticFieldSecularVariation` con tasas de cambio:
  - `north`: Tasa de cambio del componente norte (nT/año)
  - `east`: Tasa de cambio del componente este (nT/año)
  - `down`: Tasa de cambio del componente vertical (nT/año)
  - `horizontalIntensity`: Tasa de cambio de la intensidad horizontal (nT/año)
  - `totalIntensity`: Tasa de cambio de la intensidad total (nT/año)
  - `declination`: Tasa de cambio de la declinación (minutos de arco/año)
  - `inclination`: Tasa de cambio de la inclinación (minutos de arco/año)

### SHCModel

La estructura `SHCModel` proporciona acceso a todos los modelos de campo magnético disponibles:

- `igrf14`: Modelo IGRF-14
- `igrf13`: Modelo IGRF-13
- `igrf12`: Modelo IGRF-12
- `igrf11`: Modelo IGRF-11
- `igrf10`: Modelo IGRF-10
- `wmmhr2025`: Modelo WMMHR2025
- `wmm2025`: Modelo WMM2025
- `wmm2020`: Modelo WMM2020
- `wmm2015`: Modelo WMM2015
- `wmm2010`: Modelo WMM2010


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

## 💡 Ejemplos

### Calcular declinación magnética para navegación

```swift
import CoreLocation
import GeoMagSwift

func getMagneticDeclination(for location: CLLocation, at date: Date) -> Double {
    let result = try SHCModel.igrf14.calculate(location, date: date)
    return result.mainField.declination
}

// Uso
let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
let date = Date()
let declination = getMagneticDeclination(for: location, at: date)
print("Declinación magnética en San Francisco: \(declination)°")
```

### Comparar modelos

```swift
import CoreLocation
import GeoMagSwift

let location = CLLocation(latitude: 0, longitude: 0) // Ecuador
let date = Date()

let igrfResult = try SHCModel.igrf14.calculate(location, date: date)
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

print("Declinación IGRF-14: \(igrfResult.mainField.declination)°")
print("Declinación WMM2025: \(wmmResult.mainField.declination)°")
print("Diferencia: \(abs(igrfResult.mainField.declination - wmmResult.mainField.declination))°")
```

## 🧪 Pruebas

GeoMagSwift incluye pruebas comprehensivas para garantizar la precisión:

- **Pruebas de comparación**: Verifica que los resultados coincidan con los cálculos oficiales de la NOAA
- **Pruebas unitarias**: Prueba componentes individuales y casos límite
- **Pruebas de rendimiento**: Garantiza tiempos de cálculo rápidos

Para ejecutar las pruebas:

```bash
swift test
```

## 📄 Licencia

GeoMagSwift está disponible bajo la licencia MIT. Consulte el archivo [LICENSE](../../LICENSE) para obtener más información.

---

**Hecho con ❤️ para la ciencia de la Tierra y la navegación**

