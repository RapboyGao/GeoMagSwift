# GeoMagSwift

![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

🌍 **IGRF や WMM などの国際標準モデルを使用して地球磁場を計算するための強力な Swift ライブラリ**。

📘 **DocC Documentation**: https://rapboygao.github.io/GeoMagSwift/documentation/geomagswift/

## 🌐 言語

- [English](../../README.md)
- [中文](../zh/README.md)
- [日本語](README.md)
- [Deutsch](../de/README.md)
- [Français](../fr/README.md)
- [Español](../es/README.md)

## 📋 目次

- [特徴](#特徴)
- [インストール](#インストール)
- [使用方法](#使用方法)
- [モデル](#モデル)
- [API リファレンス](#api-リファレンス)
- [例](#例)
- [テスト](#テスト)
- [ライセンス](#ライセンス)

## ✨ 特徴

- 🎯 **高精度計算**: 最新の国際標準モデルを使用
- 🌍 **全球カバレッジ**: 地球上のあらゆる場所で正確な計算
- 📅 **時間発展**: 過去、現在、未来の日付に対する計算をサポート
- 📱 **クロスプラットフォーム**: macOS、iOS、watchOS、tvOS で動作
- 🚀 **高速パフォーマンス**: 速度と効率性のために最適化
- 📚 **包括的な出力**: すべての磁場成分を提供
- 🔄 **複数のモデル**: IGRF と WMM シリーズのモデルを含む
- 🎨 **使いやすさ**: シンプルで直感的な API

## 🛠 インストール

### Swift Package Manager

Swift Package Manager を使用して GeoMagSwift をプロジェクトに追加します：

1. Xcode で、**ファイル > パッケージ依存関係を追加...** を選択します
2. リポジトリ URL を入力します：`https://github.com/RapboyGao/GeoMagSwift.git`
3. 使用するバージョンを選択します
4. **パッケージを追加** をクリックします

### Package.swift

あるいは、直接 `Package.swift` ファイルに追加します：

```swift
dependencies: [
    .package(url: "https://github.com/RapboyGao/GeoMagSwift.git", from: "1.0.0")
]
```

## 🚀 使用方法

### 基本的な使用方法

```swift
import CoreLocation
import GeoMagSwift

// 位置を作成（中国北京）
let location = CLLocation(latitude: 40.0, longitude: 116.0, altitude: 0)

// 現在の日付を取得
let date = Date()

// IGRF14 モデルを使用して磁場を計算
let result = try SHCModel.igrf14.calculate(location, date: date)

// Auto-select best model for this date
let autoResult = try SHCModel.calculate(
    latitude: location.coordinate.latitude,
    longitude: location.coordinate.longitude,
    altitude: location.altitude / 1000.0,
    date: date
)

// 磁場成分にアクセス
print("磁偏角: \(result.mainField.declination)°")
print("磁倾角: \(result.mainField.inclination)°")
print("全強度: \(result.mainField.totalIntensity) nT")
print("水平強度: \(result.mainField.horizontalIntensity) nT")
print("北向き成分: \(result.mainField.north) nT")
print("東向き成分: \(result.mainField.east) nT")
print("垂直成分: \(result.mainField.down) nT")

// 経年変化（変化率）にアクセス
print("磁偏角の変化率: \(result.secularVariation.declination) 弧分/年")
```

### 異なるモデルの使用

```swift
// WMM2025 モデルを使用
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)
let wmmhrResult = try SHCModel.wmmhr2025.calculate(location, date: date)

// 古い IGRF モデルを使用
let igrf13Result = try SHCModel.igrf13.calculate(location, date: date)
let igrf12Result = try SHCModel.igrf12.calculate(location, date: date)
```

## 📊 モデル

GeoMagSwift には以下の磁場モデルが含まれています：

### IGRF（国際地磁気参照場）
- **IGRF-14**: Latest model (1900.0 - 2030.0)
- **IGRF-13**: Model for 1900.0 - 2025.0
- **IGRF-12**: Model for 1900.0 - 2020.0
- **IGRF-11**: Model for 1900.0 - 2015.0
- **IGRF-10**: Model for 1900.0 - 2005.0

### WMM（世界磁気モデル）
- **WMMHR2025**: High-resolution model for 2025.0 - 2030.0
- **WMM2025**: Model for 2025.0 - 2030.0
- **WMM2020**: Model for 2020.0 - 2025.0
- **WMM2015**: Model for 2015.0 - 2020.0
- **WMM2010**: Model for 2010.0 - 2015.0

## 📚 API リファレンス

### MagneticFieldResult

`calculate()` メソッドは `MagneticFieldSolution` オブジェクトを返します。これには以下が含まれます：

- **mainField**: `MagneticFieldResult` は以下の成分を含みます：
  - `north`: 北向き成分（nT）
  - `east`: 東向き成分（nT）
  - `down`: 垂直成分（nT）
  - `horizontalIntensity`: 水平強度（nT）
  - `totalIntensity`: 全強度（nT）
  - `declination`: 磁偏角（度）
  - `inclination`: 磁倾角（度）

- **secularVariation**: `MagneticFieldSecularVariation` は変化率を含みます：
  - `north`: 北向き成分の変化率（nT/年）
  - `east`: 東向き成分の変化率（nT/年）
  - `down`: 垂直成分の変化率（nT/年）
  - `horizontalIntensity`: 水平強度の変化率（nT/年）
  - `totalIntensity`: 全強度の変化率（nT/年）
  - `declination`: 磁偏角の変化率（弧分/年）
  - `inclination`: 磁倾角の変化率（弧分/年）

### SHCModel

`SHCModel` 構造体は、利用可能なすべての磁場モデルへのアクセスを提供します：

- `igrf14`: IGRF-14 モデル
- `igrf13`: IGRF-13 モデル
- `igrf12`: IGRF-12 モデル
- `igrf11`: IGRF-11 モデル
- `igrf10`: IGRF-10 モデル
- `wmmhr2025`: WMMHR2025 モデル
- `wmm2025`: WMM2025 モデル
- `wmm2020`: WMM2020 モデル
- `wmm2015`: WMM2015 モデル
- `wmm2010`: WMM2010 モデル


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

## 💡 例

### ナビゲーション用の磁偏角計算

```swift
import CoreLocation
import GeoMagSwift

func getMagneticDeclination(for location: CLLocation, at date: Date) -> Double {
    let result = try SHCModel.igrf14.calculate(location, date: date)
    return result.mainField.declination
}

// 使用方法
let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // サンフランシスコ
let date = Date()
let declination = getMagneticDeclination(for: location, at: date)
print("サンフランシスコの磁偏角: \(declination)°")
```

### モデルの比較

```swift
import CoreLocation
import GeoMagSwift

let location = CLLocation(latitude: 0, longitude: 0) // 赤道
let date = Date()

let igrfResult = try SHCModel.igrf14.calculate(location, date: date)
let wmmResult = try SHCModel.wmm2025.calculate(location, date: date)

print("IGRF-14 磁偏角: \(igrfResult.mainField.declination)°")
print("WMM2025 磁偏角: \(wmmResult.mainField.declination)°")
print("差異: \(abs(igrfResult.mainField.declination - wmmResult.mainField.declination))°")
```

## 🧪 テスト

GeoMagSwift には、精度を確保するための包括的なテストが含まれています：

- **比較テスト**: 結果が公式の NOAA 計算と一致することを確認
- **単体テスト**: 個々のコンポーネントとエッジケースをテスト
- **パフォーマンステスト**: 高速な計算時間を確保

テストを実行するには：

```bash
swift test
```

## 📄 ライセンス

GeoMagSwift は MIT ライセンスの下で利用可能です。詳細については、[LICENSE](../../LICENSE) ファイルを参照してください。

---

**地球科学とナビゲーションのために ❤️ で作られました**

