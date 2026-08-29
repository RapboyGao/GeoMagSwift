import Foundation

public extension SHCModel {
    /// 高分辨率世界地磁模型 (WMMHR2025) 模型
    ///
    /// High-Resolution World Magnetic Model (WMMHR2025) model
    ///
    /// 该模型是世界地磁模型 (WMM) 的高分辨率版本，由美国国家环境信息中心 (NCEI) 和英国地质调查局 (BGS) 联合发布，
    /// 提供了更高空间分辨率的地磁场信息。WMMHR 模型是一个球谐系数模型，
    /// 每五年更新一次，提供地磁场的当前状态和未来五年的预测。
    ///
    /// This model is a high-resolution version of the World Magnetic Model (WMM), jointly published by
    /// the National Centers for Environmental Information (NCEI) and the British Geological Survey (BGS).
    /// It provides higher spatial resolution magnetic field information. The WMMHR model is a
    /// spherical harmonic coefficient model that is updated every five years, providing the current
    /// state of the magnetic field and a five-year prediction.
    ///
    /// 模型文件: WMMHR.COF
    /// Model file: WMMHR.COF
    ///
    /// 有效 epoch: 2025 - 2030
    /// Valid epochs: 2025 - 2030
    static let wmmhr2025: SHCModel = SHCModel.requiredResource("wmmhr2025")
}
