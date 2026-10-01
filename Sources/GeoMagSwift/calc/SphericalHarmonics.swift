import Foundation

/// 球谐函数计算工具类
///
/// Spherical harmonics calculation utilities
internal enum SphericalHarmonics {

    /// 工作空间结构体
    ///
    /// Workspace structure
    struct Workspace {
        /// 余弦项数组
        ///
        /// Cosine terms array
        var cosMLon: [Double]
        /// 正弦项数组
        ///
        /// Sine terms array
        var sinMLon: [Double]
        /// 勒让德多项式值数组
        ///
        /// Legendre polynomial values array
        var p: [[Double]]
        /// 勒让德多项式导数值数组
        ///
        /// Legendre polynomial derivatives array
        var dp: [[Double]]
        /// 最大阶数
        ///
        /// Maximum order
        var nmax: Int

        /// 初始化工作空间
        ///
        /// Initialize workspace
        ///
        /// - Parameter nmax: 最大阶数
        ///   Maximum order
        init(nmax: Int) {
            self.nmax = nmax
            self.cosMLon = Array(repeating: 0.0, count: nmax + 1)
            self.sinMLon = Array(repeating: 0.0, count: nmax + 1)
            self.p = Array(repeating: Array(repeating: 0.0, count: nmax + 1), count: nmax + 1)
            self.dp = Array(repeating: Array(repeating: 0.0, count: nmax + 1), count: nmax + 1)
        }

        /// 确保工作空间容量
        ///
        /// Ensure workspace capacity
        ///
        /// - Parameter nmax: 最大阶数
        ///   Maximum order
        mutating func ensureCapacity(nmax: Int) {
            if nmax <= self.nmax { return }
            self.nmax = nmax
            self.cosMLon = Array(repeating: 0.0, count: nmax + 1)
            self.sinMLon = Array(repeating: 0.0, count: nmax + 1)
            self.p = Array(repeating: Array(repeating: 0.0, count: nmax + 1), count: nmax + 1)
            self.dp = Array(repeating: Array(repeating: 0.0, count: nmax + 1), count: nmax + 1)
        }
    }

    /// 参考半径（公里）
    ///
    /// Reference radius (km)
    static let referenceRadius = 6371.2

    /// 计算地磁场分量
    ///
    /// Calculate magnetic field components
    ///
    /// - Parameters:
    ///   - nmax: 最大阶数
    ///     Maximum order
    ///   - g: 高斯系数g
    ///     Gaussian coefficients g
    ///   - h: 高斯系数h
    ///     Gaussian coefficients h
    ///   - latitude: 纬度（度）
    ///     Latitude (degrees)
    ///   - longitude: 经度（度）
    ///     Longitude (degrees)
    ///   - altitude: 海拔高度（公里）
    ///     Altitude (km)
    ///   - workspace: 工作空间
    ///     Workspace
    /// - Returns:
    ///   北向、东向和垂直向下分量
    ///   North, east and down components
    static func fieldComponents(
        nmax: Int,
        g: [[Double]],
        h: [[Double]],
        latitude: Double,
        longitude: Double,
        altitude: Double,
        workspace: inout Workspace
    ) -> (north: Double, east: Double, down: Double) {
        let coords = Geodesy.geocentricCoordinates(latitude: latitude, longitude: longitude, altitude: altitude)
        let lonAngle = SHCAngle(degrees: longitude)

        let cosLon = lonAngle.cos
        let sinLon = lonAngle.sin

        workspace.ensureCapacity(nmax: nmax)
        workspace.cosMLon[0] = 1.0
        workspace.sinMLon[0] = 0.0
        if nmax >= 1 {
            workspace.cosMLon[1] = cosLon
            workspace.sinMLon[1] = sinLon
            if nmax > 1 {
                for m in 2...nmax {
                    workspace.cosMLon[m] = workspace.cosMLon[m - 1] * cosLon - workspace.sinMLon[m - 1] * sinLon
                    workspace.sinMLon[m] = workspace.sinMLon[m - 1] * cosLon + workspace.cosMLon[m - 1] * sinLon
                }
            }
        }

        let cosMLon = workspace.cosMLon
        let sinMLon = workspace.sinMLon

        Legendre.schmidtNormalized(
            nmax: nmax, theta: SHCAngle.radians(coords.theta), p: &workspace.p, dp: &workspace.dp)
        let p = workspace.p
        let dp = workspace.dp

        var br = 0.0
        var bt = 0.0
        var bp = 0.0

        let mDouble = (0...nmax).map { Double($0) }
        let nDouble = (0...nmax).map { Double($0) }
        let a = referenceRadius
        let r = coords.radius
        let ar = a / r
        var arn = ar * ar * ar
        for n in 1...nmax {
            let nVal = nDouble[n]
            for m in 0...n {
                let mVal = mDouble[m]
                let gnm = g[n][m]
                let hnm = h[n][m]
                let cosTerm = cosMLon[m]
                let sinTerm = sinMLon[m]
                let temp = gnm * cosTerm + hnm * sinTerm

                br += (nVal + 1.0) * arn * temp * p[n][m]
                bt += arn * temp * dp[n][m]

                if m > 0 {
                    let tempPhi = gnm * sinTerm - hnm * cosTerm
                    bp += arn * mVal * tempPhi * p[n][m]
                }
            }
            arn *= ar
        }

        br = -br
        bt = -bt
        let sinTheta = coords.sinTheta
        let sinThetaSafe = abs(sinTheta) < 1.0e-10 ? (sinTheta >= 0 ? 1.0e-10 : -1.0e-10) : sinTheta
        bp = bp / sinThetaSafe

        let x = -bt * coords.cosDelta - br * coords.sinDelta
        let z = -(bt * coords.sinDelta - br * coords.cosDelta)
        let y = bp

        return (north: x, east: y, down: z)
    }
}
