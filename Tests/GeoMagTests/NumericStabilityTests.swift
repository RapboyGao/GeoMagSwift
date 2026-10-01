import Foundation
import Testing

@testable import GeoMagSwift

@Test("极值输入结果应为有限值")
func testExtremeInputsAreFinite() throws {
    let model = SHCModel.wmm2025
    guard let minEpoch = model.epochs.min(), let maxEpoch = model.epochs.max() else {
        #expect(Bool(false), "Model epochs should not be empty")
        return
    }
    let midEpoch = (minEpoch + maxEpoch) / 2.0

    let latitudes = [-89.999, -60.0, 0.0, 60.0, 89.999]
    let longitudes = [-180.0, -179.999, 0.0, 179.999, 180.0]
    let altitudes = [-0.1, 0.0, 100.0]  // km

    func expectFinite(_ value: Double, _ label: String) {
        #expect(value.isFinite, "\(label) should be finite")
    }

    for lat in latitudes {
        for lon in longitudes {
            for alt in altitudes {
                let result = try model.calculate(latitude: lat, longitude: lon, altitude: alt, year: midEpoch)

                expectFinite(result.mainField.north, "north")
                expectFinite(result.mainField.east, "east")
                expectFinite(result.mainField.down, "down")
                expectFinite(result.mainField.horizontalIntensity, "horizontalIntensity")
                expectFinite(result.mainField.totalIntensity, "totalIntensity")
                #expect(result.mainField.horizontalIntensity >= 0.0)
                #expect(result.mainField.totalIntensity >= 0.0)
                expectFinite(result.mainField.declination.degrees, "declination")
                expectFinite(result.mainField.inclination.degrees, "inclination")

                expectFinite(result.secularVariation.north, "sv.north")
                expectFinite(result.secularVariation.east, "sv.east")
                expectFinite(result.secularVariation.down, "sv.down")
                expectFinite(result.secularVariation.horizontalIntensity, "sv.horizontalIntensity")
                expectFinite(result.secularVariation.totalIntensity, "sv.totalIntensity")
                expectFinite(result.secularVariation.declination.degrees, "sv.declination")
                expectFinite(result.secularVariation.inclination.degrees, "sv.inclination")
            }
        }
    }
}
