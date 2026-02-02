import Foundation

/// 地磁场解结构体，包含主磁场和长期变化的完整信息
///
/// Magnetic field solution structure, containing complete information about the main magnetic field and secular variation
///
/// 该结构体表示地磁场计算的完整结果，包含两个主要部分：主磁场（MagneticFieldResult）和长期变化（MagneticFieldSecularVariation）。
/// 主磁场部分提供了特定位置和时间的地磁场各分量的当前值，而长期变化部分提供了这些分量随时间的变化率。
/// 这种结构设计使得用户可以同时获取地磁场的当前状态和未来变化趋势的信息。
///
/// This structure represents the complete result of a magnetic field calculation, including two main parts:
/// the main magnetic field (MagneticFieldResult) and the secular variation (MagneticFieldSecularVariation).
/// The main field part provides the current values of various magnetic field components at a specific location and time,
/// while the secular variation part provides the rates of change of these components over time.
/// This structure design allows users to simultaneously obtain information about both the current state of the magnetic field
/// and its future change trends.
public struct MagneticFieldSolution: Sendable, Hashable, Codable {
    /// 主磁场结果
    /// 包含特定位置和时间的地磁场各分量的当前值，如北向、东向、垂直向下分量，以及派生的水平强度、总强度、磁偏角和磁倾角。
    ///
    /// Main magnetic field result
    /// Contains the current values of various magnetic field components at a specific location and time,
    /// such as north, east, and down components, as well as derived quantities like horizontal intensity,
    /// total intensity, declination, and inclination.
    public let mainField: MagneticFieldResult

    /// 地磁场长期变化
    /// 包含地磁场各分量的年变化率，如北向、东向、垂直向下分量的变化率，以及派生的水平强度、总强度、磁偏角和磁倾角的变化率。
    ///
    /// Magnetic field secular variation
    /// Contains the annual rates of change of various magnetic field components,
    /// such as rates for north, east, and down components, as well as derived quantities like
    /// horizontal intensity, total intensity, declination, and inclination rates.
    public let secularVariation: MagneticFieldSecularVariation

    /// 使用已有主磁场和长期变化结果初始化
    ///
    /// Initialize with existing main field and secular variation results
    public init(
        mainField: MagneticFieldResult,
        secularVariation: MagneticFieldSecularVariation
    ) {
        self.mainField = mainField
        self.secularVariation = secularVariation
    }

    /// 根据经纬度、海拔和日期计算并初始化地磁场解
    ///
    /// Calculate and initialize magnetic field solution with latitude, longitude, altitude and date
    ///
    /// - Parameters:
    ///   - latitude: 纬度（度）
    ///     Latitude (degrees)
    ///   - longitude: 经度（度）
    ///     Longitude (degrees)
    ///   - altitude: 海拔高度（公里）
    ///     Altitude (km)
    ///   - date: 日期，默认为当前日期
    ///     Date, default is current date
    ///   - model: 指定模型；为 nil 时自动选择最合适模型
    ///     Specific model; if nil, automatically selects the best available model
    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double,
        date: Date = Date(),
        model: SHCModel? = nil
    ) throws {
        let selectedModel: SHCModel
        if let model {
            selectedModel = model
        } else {
            selectedModel = try SHCModel.bestModel(for: date)
        }
        self = try selectedModel.calculate(
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            year: date
        )
    }
}

extension MagneticFieldSolution: CustomStringConvertible {
    public var description: String {
        func format(_ value: Double) -> String {
            String(format: "%.2f", locale: Locale.current, value)
        }

        let line1 = "\(I18n.north): \(format(mainField.north)) \(I18n.unitNT)"
        let line2 = "\(I18n.east): \(format(mainField.east)) \(I18n.unitNT)"
        let line3 = "\(I18n.down): \(format(mainField.down)) \(I18n.unitNT)"
        let line4 = "\(I18n.horizontalIntensity): \(format(mainField.horizontalIntensity)) \(I18n.unitNT)"
        let line5 = "\(I18n.totalIntensity): \(format(mainField.totalIntensity)) \(I18n.unitNT)"
        let line6 = "\(I18n.declination): \(format(mainField.declination.degrees)) \(I18n.unitDegree)"
        let line7 = "\(I18n.inclination): \(format(mainField.inclination.degrees)) \(I18n.unitDegree)"

        let svLine1 = "\(I18n.north): \(format(secularVariation.north)) \(I18n.unitNTPerYear)"
        let svLine2 = "\(I18n.east): \(format(secularVariation.east)) \(I18n.unitNTPerYear)"
        let svLine3 = "\(I18n.down): \(format(secularVariation.down)) \(I18n.unitNTPerYear)"
        let svLine4 = "\(I18n.horizontalIntensity): \(format(secularVariation.horizontalIntensity)) \(I18n.unitNTPerYear)"
        let svLine5 = "\(I18n.totalIntensity): \(format(secularVariation.totalIntensity)) \(I18n.unitNTPerYear)"
        let svLine6 = "\(I18n.declination): \(format(secularVariation.declination.arcMinutes)) \(I18n.unitArcMinPerYear)"
        let svLine7 = "\(I18n.inclination): \(format(secularVariation.inclination.arcMinutes)) \(I18n.unitArcMinPerYear)"

        return [
            "\(I18n.magneticFieldSolutionTitle)",
            "\(I18n.mainFieldTitle):",
            line1, line2, line3, line4, line5, line6, line7,
            "\(I18n.secularVariationTitle):",
            svLine1, svLine2, svLine3, svLine4, svLine5, svLine6, svLine7,
        ].joined(separator: "\n")
    }
}
