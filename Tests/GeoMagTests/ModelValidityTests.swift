import Foundation
import Testing

@testable import GeoMagSwift

@Test("超出模型有效期会抛错")
func testYearOutOfRangeThrows() throws {
    let model = SHCModel.wmm2025
    guard let minEpoch = model.epochs.min(), let maxEpoch = model.epochs.max() else {
        #expect(Bool(false), "Model epochs should not be empty")
        return
    }

    let latitude = 10.0
    let longitude = 20.0
    let altitude = 0.0

    do {
        _ = try model.calculate(latitude: latitude, longitude: longitude, altitude: altitude, year: minEpoch - 0.0001)
        #expect(Bool(false), "Expected out-of-range year to throw")
    } catch let error as SHCModel.SHCModelError {
        switch error {
        case .yearOutOfRange(let year, let range):
            #expect(year < range.lowerBound)
            #expect(range.lowerBound == minEpoch)
            #expect(range.upperBound == maxEpoch)
        case .noModelForYear:
            #expect(Bool(false), "Unexpected noModelForYear error")
        case .invalidEpochs:
            #expect(Bool(false), "Model epochs should be valid")
        }
    } catch {
        #expect(Bool(false), "Unexpected error: \(error)")
    }

    do {
        _ = try model.calculate(latitude: latitude, longitude: longitude, altitude: altitude, year: maxEpoch + 0.0001)
        #expect(Bool(false), "Expected out-of-range year to throw")
    } catch let error as SHCModel.SHCModelError {
        switch error {
        case .yearOutOfRange(let year, let range):
            #expect(year > range.upperBound)
            #expect(range.lowerBound == minEpoch)
            #expect(range.upperBound == maxEpoch)
        case .noModelForYear:
            #expect(Bool(false), "Unexpected noModelForYear error")
        case .invalidEpochs:
            #expect(Bool(false), "Model epochs should be valid")
        }
    } catch {
        #expect(Bool(false), "Unexpected error: \(error)")
    }
}

@Test("模型有效期边界可正常计算")
func testYearInRangeDoesNotThrow() throws {
    let model = SHCModel.wmm2025
    guard let minEpoch = model.epochs.min(), let maxEpoch = model.epochs.max() else {
        #expect(Bool(false), "Model epochs should not be empty")
        return
    }

    let latitude = 10.0
    let longitude = 20.0
    let altitude = 0.0

    _ = try model.calculate(latitude: latitude, longitude: longitude, altitude: altitude, year: minEpoch)
    _ = try model.calculate(latitude: latitude, longitude: longitude, altitude: altitude, year: maxEpoch)
}

@Test("自动模型选择不会默认使用 WMMHR2025")
func testBestModelDoesNotSelectWMMHRByDefault() throws {
    let model = try SHCModel.bestModel(for: 2025.0)

    // Automatic selection must not touch the high-resolution WMMHR resource.
    // 自动选择不能访问高分辨率 WMMHR 资源。
    #expect(!model.fileName.lowercased().contains("wmmhr"))
}

@Test("自动模型选择按年份返回标准模型")
func testBestModelUsesTheExpectedStandardModel() throws {
    let cases: [(year: Double, firstEpoch: Double)] = [
        (2010.0, 2010.0),
        (2015.0, 2015.0),
        (2020.0, 2020.0),
        (2025.0, 2025.0),
        (1900.0, 1900.0),
    ]

    for testCase in cases {
        let model = try SHCModel.bestModel(for: testCase.year)
        #expect(model.epochs.first == testCase.firstEpoch)
        #expect(!model.fileName.lowercased().contains("wmmhr"))
    }
}

@Test("显式加载 WMMHR2025 仍然可用")
func testExplicitWMMHRLoadingRemainsAvailable() throws {
    let model = SHCModel.BuiltInModel.wmmhr2025.model
    #expect(model.fileName.lowercased().contains("wmmhr"))
    #expect(model.nmax > SHCModel.wmm2025.nmax)
}

@Test("所有模型 JSON 资源均可解析")
func testAllModelResourcesDecode() throws {
    let modelNames = [
        "igrf10", "igrf11", "igrf12", "igrf13", "igrf14",
        "wmm2010", "wmm2015", "wmm2020", "wmm2025", "wmmhr2025",
    ]

    for name in modelNames {
        let model = try SHCModel.loadResource(name)
        #expect(!model.fileName.isEmpty)
        #expect(!model.epochs.isEmpty)
        #expect(model.epochs.count >= 2)
        #expect(!model.coefficients.isEmpty)
        #expect(model.nmax > 0)
        #expect(model.validFrom == model.epochs.first)
        #expect(model.validTo == model.epochs.last)

        for coefficient in model.coefficients {
            #expect(coefficient.n >= 1)
            #expect(coefficient.m >= 0)
            #expect(coefficient.m <= coefficient.n)
            #expect(coefficient.values.count >= 2)
        }
    }
}

@Test("缺失 JSON 资源会抛出明确错误")
func testMissingModelResourceThrows() {
    do {
        _ = try SHCModel.loadResource("does-not-exist")
        #expect(Bool(false), "Expected a missing resource error")
    } catch let error as SHCModel.ResourceError {
        guard case .resourceNotFound(let name) = error else {
            #expect(Bool(false), "Unexpected resource error: \(error)")
            return
        }
        #expect(name == "does-not-exist")
    } catch {
        #expect(Bool(false), "Unexpected error: \(error)")
    }
}

@Test("非法 JSON 资源名会被拒绝")
// Invalid resource identifiers must be rejected before bundle lookup.
// 非法资源标识符必须在 Bundle 查找前被拒绝。
func testInvalidModelResourceNameThrows() {
    do {
        _ = try SHCModel.loadResource("../wmm2025")
        #expect(Bool(false), "Expected an invalid resource name error")
    } catch let error as SHCModel.ResourceError {
        guard case .invalidResourceName(let name) = error else {
            #expect(Bool(false), "Unexpected resource error: \(error)")
            return
        }
        #expect(name == "../wmm2025")
    } catch {
        #expect(Bool(false), "Unexpected error: \(error)")
    }
}

@Test("异常模型输入会抛出校验错误")
// Malformed model data and numerical inputs must throw instead of reaching unsafe indexing.
// 损坏的模型数据和数值输入必须抛错，不能继续执行不安全的数组访问。
func testInvalidModelInputsThrowValidationErrors() {
    let validEpochs = [2020.0, 2025.0]
    let validValues = [1.0, 2.0]

    let invalidIndexModel = SHCModel(
        fileName: "invalid-index",
        headers: [],
        headerNumbers: [],
        epochs: validEpochs,
        coefficients: [SHCModel.Coefficient(n: 1, m: 2, kind: .g, values: validValues)]
    )
    expectValidationError(.invalidCoefficientIndex(n: 1, m: 2)) {
        _ = try invalidIndexModel.calculate(
            latitude: 0.0, longitude: 0.0, altitude: 0.0, year: 2020.0)
    }

    let oversizedModel = SHCModel(
        fileName: "oversized",
        headers: [],
        headerNumbers: [],
        epochs: validEpochs,
        coefficients: [SHCModel.Coefficient(n: Int.max, m: 0, kind: .g, values: validValues)]
    )
    expectValidationError(.invalidNmax(value: Int.max, maximum: 720)) {
        _ = try oversizedModel.calculate(
            latitude: 0.0, longitude: 0.0, altitude: 0.0, year: 2020.0)
    }

    let invalidValuesModel = SHCModel(
        fileName: "invalid-values",
        headers: [],
        headerNumbers: [],
        epochs: validEpochs,
        coefficients: [SHCModel.Coefficient(n: 1, m: 0, kind: .g, values: [Double.nan, 2.0])]
    )
    expectValidationError(.invalidCoefficientValues(n: 1, m: 0)) {
        _ = try invalidValuesModel.calculate(
            latitude: 0.0, longitude: 0.0, altitude: 0.0, year: 2020.0)
    }

    let emptyModel = SHCModel(
        fileName: "empty",
        headers: [],
        headerNumbers: [],
        epochs: [],
        coefficients: []
    )
    expectValidationError(.invalidNmax(value: 0, maximum: 720)) {
        _ = try emptyModel.calculate(
            latitude: 0.0, longitude: 0.0, altitude: 0.0, year: 2020.0)
    }

    let unorderedEpochModel = SHCModel(
        fileName: "unordered-epochs",
        headers: [],
        headerNumbers: [],
        epochs: [2025.0, 2020.0],
        coefficients: [SHCModel.Coefficient(n: 1, m: 0, kind: .g, values: validValues)]
    )
    expectValidationError(.invalidValidityRange) {
        _ = try unorderedEpochModel.calculate(
            latitude: 0.0, longitude: 0.0, altitude: 0.0, year: 2020.0)
    }

    let zeroFieldModel = SHCModel(
        fileName: "zero-field",
        headers: [],
        headerNumbers: [],
        epochs: validEpochs,
        coefficients: [SHCModel.Coefficient(n: 1, m: 0, kind: .g, values: [0.0, 0.0])]
    )
    expectValidationError(.invalidOutput(parameter: "mainField")) {
        _ = try zeroFieldModel.calculate(
            latitude: 0.0, longitude: 0.0, altitude: 0.0, year: 2020.0)
    }

    expectValidationError(.invalidInput(parameter: "latitude")) {
        _ = try SHCModel.wmm2025.calculate(
            latitude: .nan, longitude: 0.0, altitude: 0.0, year: 2025.0)
    }
    expectValidationError(.invalidInput(parameter: "altitude")) {
        _ = try SHCModel.wmm2025.calculate(
            latitude: 0.0, longitude: 0.0, altitude: -10_000.0, year: 2025.0)
    }
    expectValidationError(.invalidInput(parameter: "year")) {
        _ = try SHCModel.wmm2025.calculate(
            latitude: 0.0, longitude: 0.0, altitude: 0.0, year: .infinity)
    }
}

private func expectValidationError(
    _ expected: SHCModel.ValidationError,
    operation: () throws -> Void
) {
    // Assert that invalid inputs produce the intended typed validation error.
    // 确认非法输入产生预期的可识别校验错误类型。
    do {
        try operation()
        #expect(Bool(false), "Expected validation error: \(expected)")
    } catch let error as SHCModel.ValidationError {
        #expect(error == expected)
    } catch {
        #expect(Bool(false), "Unexpected error: \(error)")
    }
}
