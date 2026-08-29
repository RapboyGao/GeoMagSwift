import Foundation

public extension SHCModel {
    /// 世界地磁模型 (WMM2020) 模型
    ///
    /// World Magnetic Model (WMM2020) model
    ///
    /// 该模型是由美国国家环境信息中心 (NCEI) 和英国地质调查局 (BGS) 联合发布的全球地磁场模型，
    /// 用于导航、定向和其他需要地磁场信息的应用。WMM 模型是一个球谐系数模型，
    /// 每五年更新一次，提供地磁场的当前状态和未来五年的预测。
    ///
    /// This model is a global magnetic field model jointly published by the National Centers for
    /// Environmental Information (NCEI) and the British Geological Survey (BGS). It is used for
    /// navigation, orientation, and other applications requiring magnetic field information.
    /// The WMM model is a spherical harmonic coefficient model that is updated every five years,
    /// providing the current state of the magnetic field and a five-year prediction.
    ///
    /// 模型文件: WMM.COF
    /// Model file: WMM.COF
    ///
    /// 有效 epoch: 2020 - 2025
    /// Valid epochs: 2020 - 2025
    static let wmm2020: SHCModel = SHCModel.requiredResource("wmm2020")
}
