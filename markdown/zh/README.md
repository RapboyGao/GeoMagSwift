# GeoMagSwift

![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

🌍 **一个强大的 Swift 库，用于使用 IGRF 和 WMM 等国际标准模型计算地球磁场**。

📘 **DocC Documentation**: https://rapboygao.github.io/GeoMagSwift/documentation/geomagswift/

## 🌐 语言

- [English](../../README.md)
- [中文](README.md)
- [日本語](../ja/README.md)
- [Deutsch](../de/README.md)
- [Français](../fr/README.md)
- [Español](../es/README.md)

## 📋 目录

- [特性](#特性)
- [安装](#安装)
- [使用](#使用)
- [模型](#模型)
- [API 参考](#api-参考)
- [示例](#示例)
- [测试](#测试)
- [许可证](#许可证)

## ✨ 特性

- 🎯 **高精度计算**: 使用最新的国际标准模型
- 🌍 **全球覆盖**: 对地球上任何位置的准确计算
- 📅 **时间演变**: 支持过去、现在和未来日期的计算
- 📱 **跨平台**: 适用于 macOS、iOS、watchOS 和 tvOS
- 🚀 **快速性能**: 针对速度和效率进行了优化
- 📚 **全面输出**: 提供所有磁场分量
- 🔄 **多种模型**: 包括 IGRF 和 WMM 系列模型
- 🎨 **易于使用**: 简单、直观的 API

## 🛠 安装

### Swift Package Manager

使用 Swift Package Manager 将 GeoMagSwift 添加到您的项目中：

1. 在 Xcode 中，选择 **文件 > 添加包依赖...**
2. 输入仓库 URL：`https://github.com/RapboyGao/GeoMagSwift.git`
3. 选择您要使用的版本
4. 点击 **添加包**

### Package.swift

或者，直接将其添加到您的 `Package.swift` 文件中：

```swift
dependencies: [
    .package(url: "https://github.com/RapboyGao/GeoMagSwift.git", from: "1.0.0")
]
```

## 🚀 使用

### 基本用法

```swift
import CoreLocation
import GeoMagSwift

// 创建一个位置（中国北京）
let location = CLLocation(latitude: 40.0, longitude: 116.0, altitude: 0)

// 获取当前日期
let date = Date()

// 使用 IGRF14 模型计算磁场
let result = try SHCModel.igrf14.calculate(location, date: date)

// Auto-select best model for this date
let autoResult = try SHCModel.calculate(
    latitude: location.coordinate.latitude,
    longitude: location.coordinate.longitude,
    altitude: location.altitude / 1000.0,
    date: date
)

// 访问磁场分量
print("磁偏角: \(result.mainField.declination)°")
print("磁倾角: \(result.mainField.inclination)°")
print("总强度: \(result.mainField.totalIntensity) nT")
print("水平强度: \(result.mainField.horizontalIntensity) nT")
print("北向分量: \(result.mainField.north) nT")
print("东向分量: \(result.mainField.east) nT")
print("垂直分量: \(result.mainField.down) nT")

// 访问长期变化（变化率）
print("磁偏角变化率: \(result.secularVariation.declination) 角分/年")
```

### 使用不同模型

```swift
// 使用 WMM2025 模型
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)
let wmmhrResult = try SHCModel.wmmhr2025.calculate(location, date: date)

// 使用旧版 IGRF 模型
let igrf13Result = try SHCModel.igrf13.calculate(location, date: date)
let igrf12Result = try SHCModel.igrf12.calculate(location, date: date)
```

### SwiftUI 地图选点

`GeomagneticMapView` 提供 iOS/iPadOS 16+ 地图，可通过长按选择位置并自动计算磁场信息。视图内置模型、日期和海拔控件，同时支持 Mac Catalyst 16+。

```swift
import GeoMagSwift
import SwiftUI

@available(iOS 16.0, macCatalyst 16.0, *)
struct ContentView: View {
    var body: some View {
        GeomagneticMapView()
    }
}
```

该视图内部使用 `MKMapView` 以兼容 iOS 16，不会申请用户定位权限。长按地图即可选择位置。

核心类型 `SHCModel.BuiltInModel` 可在所有支持的平台使用，访问其 `model` 属性时才会加载对应的 JSON 资源。`wmmhr2025` 不参与自动选模，只有显式选择时才会加载。

## 📊 模型

GeoMagSwift 包含以下磁场模型：

### IGRF（国际地磁参考场）
- **IGRF-14**: Latest model (1900.0 - 2030.0)
- **IGRF-13**: Model for 1900.0 - 2025.0
- **IGRF-12**: Model for 1900.0 - 2020.0
- **IGRF-11**: Model for 1900.0 - 2015.0
- **IGRF-10**: Model for 1900.0 - 2005.0

### WMM（世界磁场模型）
- **WMMHR2025**: High-resolution model for 2025.0 - 2030.0
- **WMM2025**: Model for 2025.0 - 2030.0
- **WMM2020**: Model for 2020.0 - 2025.0
- **WMM2015**: Model for 2015.0 - 2020.0
- **WMM2010**: Model for 2010.0 - 2015.0

## 📚 API 参考

### MagneticFieldResult

`calculate()` 方法返回一个 `MagneticFieldSolution` 对象，包含：

- **mainField**: `MagneticFieldResult` 包含以下分量：
  - `north`: 北向分量（nT）
  - `east`: 东向分量（nT）
  - `down`: 垂直分量（nT）
  - `horizontalIntensity`: 水平强度（nT）
  - `totalIntensity`: 总强度（nT）
  - `declination`: 磁偏角（度）
  - `inclination`: 磁倾角（度）

- **secularVariation**: `MagneticFieldSecularVariation` 包含变化率：
  - `north`: 北向分量变化率（nT/年）
  - `east`: 东向分量变化率（nT/年）
  - `down`: 垂直分量变化率（nT/年）
  - `horizontalIntensity`: 水平强度变化率（nT/年）
  - `totalIntensity`: 总强度变化率（nT/年）
  - `declination`: 磁偏角变化率（角分/年）
  - `inclination`: 磁倾角变化率（角分/年）

### SHCModel

`SHCModel` 结构体提供对所有可用磁场模型的访问：

- `igrf14`: IGRF-14 模型
- `igrf13`: IGRF-13 模型
- `igrf12`: IGRF-12 模型
- `igrf11`: IGRF-11 模型
- `igrf10`: IGRF-10 模型
- `wmmhr2025`: WMMHR2025 模型
- `wmm2025`: WMM2025 模型
- `wmm2020`: WMM2020 模型
- `wmm2015`: WMM2015 模型
- `wmm2010`: WMM2010 模型


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

## 💡 示例

### 计算导航用磁偏角

```swift
import CoreLocation
import GeoMagSwift

func getMagneticDeclination(for location: CLLocation, at date: Date) -> Double {
    let result = try SHCModel.igrf14.calculate(location, date: date)
    return result.mainField.declination
}

// 使用
let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // 旧金山
let date = Date()
let declination = getMagneticDeclination(for: location, at: date)
print("旧金山的磁偏角: \(declination)°")
```

### 比较模型

```swift
import CoreLocation
import GeoMagSwift

let location = CLLocation(latitude: 0, longitude: 0) // 赤道
let date = Date()

let igrfResult = try SHCModel.igrf14.calculate(location, date: date)
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

print("IGRF-14 磁偏角: \(igrfResult.mainField.declination)°")
print("WMM2025 磁偏角: \(wmmResult.mainField.declination)°")
print("差异: \(abs(igrfResult.mainField.declination - wmmResult.mainField.declination))°")
```

## 🧪 测试

GeoMagSwift 包含全面的测试以确保准确性：

- **比较测试**: 验证结果与官方 NOAA 计算匹配
- **单元测试**: 测试各个组件和边缘情况
- **性能测试**: 确保快速计算时间

要运行测试：

```bash
swift test
```

## 📄 许可证

GeoMagSwift 在 MIT 许可证下可用。有关更多信息，请参阅 [LICENSE](../../LICENSE) 文件。

---

**用 ❤️ 为地球科学和导航而制作**
