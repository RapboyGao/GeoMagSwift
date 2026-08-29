import Foundation

public extension SHCModel {
    /// 国际地磁参考场 (IGRF) 模型
    ///
    /// International Geomagnetic Reference Field (IGRF) model
    ///
    /// 该模型是由国际地磁学与高空大气物理学协会 (IAGA) 发布的全球地磁场参考模型，
    /// 用于描述地球磁场的空间分布和时间变化。IGRF 模型是一个球谐系数模型，
    /// 包含了地磁场的基本结构和长期变化。
    ///
    /// This model is a global reference model of the Earth's magnetic field published by the
    /// International Association of Geomagnetism and Aeronomy (IAGA). It is used to describe
    /// the spatial distribution and temporal variation of the Earth's magnetic field.
    /// The IGRF model is a spherical harmonic coefficient model that includes the
    /// basic structure and secular variation of the magnetic field.
    ///
    /// 模型文件: igrf13coeffs.txt
    /// Model file: igrf13coeffs.txt
    ///
    /// 有效 epoch: 1900.0–2025.0 (共 26 个)
    /// Valid epochs: 1900.0–2025.0 (26 total)
    static let igrf13: SHCModel = SHCModel.requiredResource("igrf13")
}
