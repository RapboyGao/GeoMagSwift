import Foundation

public extension SHCModel {
    /// 内置地磁模型选项。
    ///
    /// Built-in geomagnetic model options.
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

        /// 模型标识符。
        ///
        /// Model identifier.
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

        /// 对应的球谐模型。访问时才加载对应 JSON 资源。
        ///
        /// The spherical model represented by this option. The matching JSON
        /// resource is loaded only when this property is accessed.
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
