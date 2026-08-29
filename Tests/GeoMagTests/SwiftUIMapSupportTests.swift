#if canImport(SwiftUI) && canImport(MapKit) && canImport(UIKit) && (os(iOS) || targetEnvironment(macCatalyst))

import Foundation
import MapKit
import Testing

@testable import GeoMagSwift

@available(iOS 16.0, macCatalyst 16.0, *)
@Test("SwiftUI 地图模型选项完整")
func testBuiltInModelOptionsAreComplete() {
    let expectedNames = [
        "igrf10", "igrf11", "igrf12", "igrf13", "igrf14",
        "wmm2010", "wmm2015", "wmm2020", "wmm2025", "wmmhr2025",
    ]

    #expect(SHCModel.BuiltInModel.allCases.map(\.rawValue) == expectedNames)
    for option in SHCModel.BuiltInModel.allCases {
        #expect(!option.model.fileName.isEmpty)
        #expect(!option.displayName.isEmpty)
    }
}

@available(iOS 16.0, macCatalyst 16.0, *)
@Test("SwiftUI 地图日期会限制在模型有效期")
func testMapDateClampingUsesModelValidityRange() {
    let model = SHCModel.wmm2025
    let lower = GeomagneticMapSupport.date(forDecimalYear: model.validFrom)
    let upper = GeomagneticMapSupport.date(forDecimalYear: model.validTo)

    // Dates outside the model range must be clamped to its nearest boundary.
    // 超出模型范围的日期必须被限制到最近的有效期边界。
    #expect(GeomagneticMapSupport.clampedDate(lower.addingTimeInterval(-1), to: model) == lower)
    #expect(GeomagneticMapSupport.clampedDate(upper.addingTimeInterval(1), to: model) == upper)
    #expect(GeomagneticMapSupport.clampedDate(lower, to: model) == lower)
}

@available(iOS 16.0, macCatalyst 16.0, *)
@Test("SwiftUI 地图支持全部 UnitLength 单位")
func testAllMapAltitudeUnitsConvertToKilometers() {
    for unit in GeomagneticMapAltitudeUnit.allCases {
        let kilometers = Measurement(value: 1, unit: unit.unit).converted(to: .kilometers).value
        #expect(kilometers.isFinite)
        #expect(kilometers > 0)
    }

    #expect(GeomagneticMapAltitudeUnit(unit: .feet) == .feet)
}

#endif
