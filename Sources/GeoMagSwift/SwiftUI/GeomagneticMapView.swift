#if canImport(SwiftUI) && canImport(MapKit) && canImport(UIKit) && (os(iOS) || targetEnvironment(macCatalyst))

import CoreLocation
import Foundation
import MapKit
import SwiftUI

/// 内置地磁模型选项，供 SwiftUI 地图视图使用。
///
/// Built-in geomagnetic model options used by the SwiftUI map view.
@available(iOS 16.0, macCatalyst 16.0, *)
public extension SHCModel {
    enum BuiltInModel: String, CaseIterable, Identifiable, Sendable {
        case igrf10
        case igrf11
        case igrf12
        case igrf13
        case igrf14
        case wmm2010
        case wmm2015
        case wmm2020
        case wmm2025
        case wmmhr2025

        public var id: String { rawValue }

        /// 显示名称。
        ///
        /// Human-readable model name.
        public var displayName: String {
            switch self {
            case .igrf10: return "IGRF-10"
            case .igrf11: return "IGRF-11"
            case .igrf12: return "IGRF-12"
            case .igrf13: return "IGRF-13"
            case .igrf14: return "IGRF-14"
            case .wmm2010: return "WMM-2010"
            case .wmm2015: return "WMM-2015"
            case .wmm2020: return "WMM-2020"
            case .wmm2025: return "WMM-2025"
            case .wmmhr2025: return "WMMHR-2025"
            }
        }

        /// 对应的球谐模型。
        ///
        /// The spherical harmonic model represented by this option.
        public var model: SHCModel {
            switch self {
            case .igrf10: return .igrf10
            case .igrf11: return .igrf11
            case .igrf12: return .igrf12
            case .igrf13: return .igrf13
            case .igrf14: return .igrf14
            case .wmm2010: return .wmm2010
            case .wmm2015: return .wmm2015
            case .wmm2020: return .wmm2020
            case .wmm2025: return .wmm2025
            case .wmmhr2025: return .wmmhr2025
            }
        }
    }
}

/// Foundation UnitLength 的完整选择列表。
///
/// Complete selection list for Foundation UnitLength.
@available(iOS 16.0, macCatalyst 16.0, *)
internal enum GeomagneticMapAltitudeUnit: String, CaseIterable, Identifiable, Sendable {
    case megameters
    case kilometers
    case hectometers
    case decameters
    case meters
    case decimeters
    case centimeters
    case millimeters
    case micrometers
    case nanometers
    case picometers
    case inches
    case feet
    case yards
    case miles
    case scandinavianMiles
    case lightyears
    case nauticalMiles
    case fathoms
    case furlongs
    case astronomicalUnits
    case parsecs

    var id: String { rawValue }

    var unit: UnitLength {
        switch self {
        case .megameters: return .megameters
        case .kilometers: return .kilometers
        case .hectometers: return .hectometers
        case .decameters: return .decameters
        case .meters: return .meters
        case .decimeters: return .decimeters
        case .centimeters: return .centimeters
        case .millimeters: return .millimeters
        case .micrometers: return .micrometers
        case .nanometers: return .nanometers
        case .picometers: return .picometers
        case .inches: return .inches
        case .feet: return .feet
        case .yards: return .yards
        case .miles: return .miles
        case .scandinavianMiles: return .scandinavianMiles
        case .lightyears: return .lightyears
        case .nauticalMiles: return .nauticalMiles
        case .fathoms: return .fathoms
        case .furlongs: return .furlongs
        case .astronomicalUnits: return .astronomicalUnits
        case .parsecs: return .parsecs
        }
    }

    var displayName: String {
        MeasurementFormatter().string(from: Measurement(value: 1, unit: unit))
    }

    init?(unit: UnitLength) {
        guard let match = Self.allCases.first(where: { $0.unit.symbol == unit.symbol }) else {
            return nil
        }
        self = match
    }
}

/// 日期和单位转换辅助工具。
///
/// Helpers for date and measurement conversion.
@available(iOS 16.0, macCatalyst 16.0, *)
internal enum GeomagneticMapSupport {
    private static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    /// 将十进制年份转换为 UTC 日期。
    ///
    /// Convert a decimal year to a UTC date.
    static func date(forDecimalYear decimalYear: Double) -> Date {
        guard decimalYear.isFinite else { return .distantPast }
        guard decimalYear >= 1.0, decimalYear <= 9998.0 else {
            return decimalYear < 1.0 ? .distantPast : .distantFuture
        }

        let year = Int(decimalYear.rounded(.down))
        let fraction = decimalYear - Double(year)
        let calendar = utcCalendar
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? .distantPast
        let nextStart = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) ?? start
        return start.addingTimeInterval(nextStart.timeIntervalSince(start) * fraction)
    }

    /// 将日期限制在模型有效期内。
    ///
    /// Clamp a date to the validity range of a model.
    static func clampedDate(_ date: Date, to model: SHCModel) -> Date {
        let lower = Self.date(forDecimalYear: model.validFrom)
        let upper = Self.date(forDecimalYear: model.validTo)
        guard date.timeIntervalSinceReferenceDate.isFinite else { return lower }
        return min(max(date, lower), upper)
    }
}

/// 可长按选点并显示地磁场信息的 SwiftUI 地图视图。
///
/// A SwiftUI map view that supports long-press location selection and displays
/// geomagnetic field information.
@available(iOS 16.0, macCatalyst 16.0, *)
@MainActor
public struct GeomagneticMapView: View {
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var mapRegion: MKCoordinateRegion
    @State private var selectedModel: SHCModel.BuiltInModel
    @State private var selectedDate: Date
    @State private var altitudeValue: Double
    @State private var altitudeUnit: GeomagneticMapAltitudeUnit
    @State private var solution: MagneticFieldSolution?
    @State private var calculationError: String?

    /// 初始化地图视图。
    ///
    /// Initialize the map view.
    ///
    /// - Parameters:
    ///   - initialCoordinate: 初始坐标；为空时显示世界地图和选点提示。
    ///     Initial coordinate; when nil, show a world map and selection prompt.
    ///   - initialModel: 初始内置模型，默认为 WMM2025。
    ///     Initial built-in model, defaulting to WMM2025.
    ///   - initialDate: 初始日期；超出模型有效期时会自动修正。
    ///     Initial date; automatically clamped to the model validity range.
    ///   - initialAltitude: 初始海拔，默认使用英尺。
    ///     Initial altitude, using feet by default.
    public init(
        initialCoordinate: CLLocationCoordinate2D? = nil,
        initialModel: SHCModel.BuiltInModel = .wmm2025,
        initialDate: Date = .now,
        initialAltitude: Measurement<UnitLength> = Measurement(value: 0, unit: .feet)
    ) {
        let coordinate = initialCoordinate.flatMap {
            CLLocationCoordinate2DIsValid($0) ? $0 : nil
        }
        let model = initialModel.model
        let unit = GeomagneticMapAltitudeUnit(unit: initialAltitude.unit) ?? .feet
        let altitude = initialAltitude.converted(to: unit.unit).value
        let region: MKCoordinateRegion
        if let coordinate {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 45, longitudeDelta: 45))
        } else {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 140, longitudeDelta: 300))
        }

        _selectedCoordinate = State(initialValue: coordinate)
        _mapRegion = State(initialValue: region)
        _selectedModel = State(initialValue: initialModel)
        _selectedDate = State(initialValue: GeomagneticMapSupport.clampedDate(initialDate, to: model))
        _altitudeValue = State(initialValue: altitude)
        _altitudeUnit = State(initialValue: unit)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(I18n.mapTitle)
                    .font(.title2.bold())

                LongPressMapView(
                    selectedCoordinate: $selectedCoordinate,
                    initialRegion: mapRegion
                )
                .frame(minHeight: 280, idealHeight: 360)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottom) {
                    if selectedCoordinate == nil {
                        Text(I18n.mapLongPressInstruction)
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.regularMaterial, in: Capsule())
                            .padding(12)
                    }
                }

                parameterControls
                resultContent
            }
            .padding()
        }
        .onAppear {
            normalizeDateAndCalculate()
        }
        .onChange(of: selectedCoordinateKey) { _ in
            calculate()
        }
        .onChange(of: selectedModel) { newModel in
            selectedDate = GeomagneticMapSupport.clampedDate(selectedDate, to: newModel.model)
            calculate()
        }
        .onChange(of: selectedDate) { _ in
            calculate()
        }
        .onChange(of: altitudeValue) { _ in
            calculate()
        }
    }

    /// 模型、日期和海拔控制项。
    ///
    /// Model, date, and altitude controls.
    private var parameterControls: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Picker(I18n.mapModel, selection: $selectedModel) {
                    ForEach(SHCModel.BuiltInModel.allCases) { model in
                        Text(model.displayName).tag(model)
                    }
                }

                DatePicker(
                    I18n.mapDate,
                    selection: $selectedDate,
                    in: modelDateRange,
                    displayedComponents: .date
                )

                HStack {
                    Text(I18n.mapAltitude)
                    TextField(I18n.mapAltitude, value: $altitudeValue, format: .number)
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                    Picker("", selection: altitudeUnitBinding) {
                        ForEach(GeomagneticMapAltitudeUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }
        }
    }

    private var modelDateRange: ClosedRange<Date> {
        let model = selectedModel.model
        let lower = GeomagneticMapSupport.date(forDecimalYear: model.validFrom)
        let upper = GeomagneticMapSupport.date(forDecimalYear: model.validTo)
        return lower...upper
    }

    private var selectedCoordinateKey: String {
        guard let selectedCoordinate else { return "none" }
        return "\(selectedCoordinate.latitude),\(selectedCoordinate.longitude)"
    }

    /// 在切换单位时保持实际海拔高度不变。
    ///
    /// Preserve the physical altitude when the display unit changes.
    private var altitudeUnitBinding: Binding<GeomagneticMapAltitudeUnit> {
        Binding(
            get: { altitudeUnit },
            set: { newUnit in
                altitudeValue =
                    Measurement(value: altitudeValue, unit: altitudeUnit.unit)
                    .converted(to: newUnit.unit).value
                altitudeUnit = newUnit
                calculate()
            }
        )
    }

    /// 结果、提示或错误区域。
    ///
    /// Result, prompt, or error area.
    @ViewBuilder
    private var resultContent: some View {
        if let solution {
            solutionView(solution)
        } else if let calculationError {
            GroupBox(I18n.mapCalculationError) {
                Text(calculationError)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            GroupBox(I18n.mapSelectedLocation) {
                Text(I18n.mapLongPressInstruction)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// 显示选中坐标和地磁场结果。
    ///
    /// Display the selected coordinate and geomagnetic field result.
    private func solutionView(_ solution: MagneticFieldSolution) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let selectedCoordinate {
                GroupBox(I18n.mapSelectedLocation) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(I18n.mapLatitude): \(format(selectedCoordinate.latitude, decimals: 5))°")
                        Text("\(I18n.mapLongitude): \(format(selectedCoordinate.longitude, decimals: 5))°")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            GroupBox(I18n.mapMainField) {
                metricGrid([
                    (I18n.declination, format(solution.mainField.declination.degrees), I18n.unitDegree),
                    (I18n.inclination, format(solution.mainField.inclination.degrees), I18n.unitDegree),
                    (I18n.totalIntensity, format(solution.mainField.totalIntensity), I18n.unitNT),
                    (I18n.horizontalIntensity, format(solution.mainField.horizontalIntensity), I18n.unitNT),
                    (I18n.north, format(solution.mainField.north), I18n.unitNT),
                    (I18n.east, format(solution.mainField.east), I18n.unitNT),
                    (I18n.down, format(solution.mainField.down), I18n.unitNT),
                ])
            }

            GroupBox(I18n.mapSecularVariation) {
                metricGrid([
                    (
                        I18n.declination, format(solution.secularVariation.declination.arcMinutes),
                        I18n.unitArcMinPerYear
                    ),
                    (
                        I18n.inclination, format(solution.secularVariation.inclination.arcMinutes),
                        I18n.unitArcMinPerYear
                    ),
                    (I18n.totalIntensity, format(solution.secularVariation.totalIntensity), I18n.unitNTPerYear),
                    (
                        I18n.horizontalIntensity, format(solution.secularVariation.horizontalIntensity),
                        I18n.unitNTPerYear
                    ),
                    (I18n.north, format(solution.secularVariation.north), I18n.unitNTPerYear),
                    (I18n.east, format(solution.secularVariation.east), I18n.unitNTPerYear),
                    (I18n.down, format(solution.secularVariation.down), I18n.unitNTPerYear),
                ])
            }
        }
    }

    private func metricGrid(_ metrics: [(String, String, String)]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                VStack(alignment: .leading, spacing: 2) {
                    Text(metric.0)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(metric.1) \(metric.2)")
                        .font(.body.monospacedDigit())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// 自动修正日期并根据初始坐标计算结果。
    ///
    /// Normalize the date and calculate an initial result when a coordinate exists.
    private func normalizeDateAndCalculate() {
        selectedDate = GeomagneticMapSupport.clampedDate(selectedDate, to: selectedModel.model)
        calculate()
    }

    /// 使用当前选点和参数计算磁场，错误仅显示在结果区域。
    ///
    /// Calculate the magnetic field using the current selection and parameters;
    /// errors are shown in the result area instead of causing a crash.
    private func calculate() {
        guard let selectedCoordinate else {
            solution = nil
            calculationError = nil
            return
        }

        let altitudeKilometers = Measurement(value: altitudeValue, unit: altitudeUnit.unit)
            .converted(to: .kilometers).value
        guard altitudeValue.isFinite, altitudeKilometers.isFinite else {
            solution = nil
            calculationError = "Altitude must be a finite value."
            return
        }

        do {
            solution = try selectedModel.model.calculate(
                latitude: selectedCoordinate.latitude,
                longitude: selectedCoordinate.longitude,
                altitude: altitudeKilometers,
                year: DateUtils.decimalYear(from: selectedDate)
            )
            calculationError = nil
        } catch {
            solution = nil
            calculationError = message(for: error)
        }
    }

    private func message(for error: Error) -> String {
        switch error {
        case let error as SHCModel.SHCModelError:
            switch error {
            case .yearOutOfRange(_, let range):
                return
                    "Date must be between \(format(range.lowerBound, decimals: 2)) and \(format(range.upperBound, decimals: 2))."
            case .noModelForYear(let year):
                return "No model is available for year \(format(year, decimals: 2))."
            case .invalidEpochs:
                return "The selected model has invalid epochs."
            }
        case let error as SHCModel.ValidationError:
            switch error {
            case .invalidInput(let parameter):
                return "Invalid input: \(parameter)."
            case .invalidNmax(let value, let maximum):
                return "Invalid model degree \(value); maximum is \(maximum)."
            case .invalidCoefficientIndex(let n, let m):
                return "Invalid coefficient index (n=\(n), m=\(m))."
            case .invalidCoefficientValues(let n, let m):
                return "Invalid coefficient values (n=\(n), m=\(m))."
            case .invalidValidityRange:
                return "The selected model has an invalid validity range."
            }
        default:
            return String(describing: error)
        }
    }

    private func format(_ value: Double, decimals: Int = 2) -> String {
        guard value.isFinite else { return "—" }
        return String(format: "%.\(decimals)f", locale: Locale.current, value)
    }
}

/// iOS 16 地图桥接层，通过长按手势产生经纬度。
///
/// iOS 16 map bridge that produces coordinates from a long-press gesture.
@available(iOS 16.0, macCatalyst 16.0, *)
@MainActor
private struct LongPressMapView: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    let initialRegion: MKCoordinateRegion

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedCoordinate: $selectedCoordinate)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView

        if selectedCoordinate == nil {
            mapView.setVisibleMapRect(MKMapRect.world, animated: false)
        } else {
            mapView.setRegion(initialRegion, animated: false)
        }

        let recognizer = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        recognizer.minimumPressDuration = 0.6
        recognizer.cancelsTouchesInView = true
        mapView.addGestureRecognizer(recognizer)
        updateAnnotation(on: mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        updateAnnotation(on: mapView)
    }

    private func updateAnnotation(on mapView: MKMapView) {
        let currentAnnotation = mapView.annotations.compactMap { $0 as? MKPointAnnotation }.first
        guard let selectedCoordinate else {
            if let currentAnnotation {
                mapView.removeAnnotation(currentAnnotation)
            }
            return
        }

        if let currentAnnotation,
            abs(currentAnnotation.coordinate.latitude - selectedCoordinate.latitude) < 1.0e-12,
            abs(currentAnnotation.coordinate.longitude - selectedCoordinate.longitude) < 1.0e-12
        {
            return
        }

        if let currentAnnotation {
            mapView.removeAnnotation(currentAnnotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate
        mapView.addAnnotation(annotation)
    }

    @MainActor
    final class Coordinator: NSObject, MKMapViewDelegate {
        let selectedCoordinate: Binding<CLLocationCoordinate2D?>
        weak var mapView: MKMapView?

        init(selectedCoordinate: Binding<CLLocationCoordinate2D?>) {
            self.selectedCoordinate = selectedCoordinate
        }

        /// 将长按屏幕点转换为合法经纬度。
        ///
        /// Convert the long-press screen point into a valid coordinate.
        @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            guard recognizer.state == .began, let mapView else { return }
            let point = recognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            guard CLLocationCoordinate2DIsValid(coordinate),
                coordinate.latitude.isFinite,
                coordinate.longitude.isFinite
            else {
                return
            }
            selectedCoordinate.wrappedValue = coordinate
        }
    }
}

@available(iOS 16.0, macCatalyst 16.0, *)
#Preview("Geomagnetic Map / 地磁场地图") {
    // Preview with Beijing selected so the result card is visible in Canvas.
    // 预览默认选中北京，方便在 Canvas 中直接看到结果卡片。
    GeomagneticMapView(
        initialCoordinate: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        initialModel: .wmm2025,
        initialAltitude: Measurement(value: 43, unit: .feet)
    )
}

#endif
