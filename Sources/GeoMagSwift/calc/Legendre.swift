import Foundation

/// 勒让德多项式计算工具类
///
/// Legendre polynomial calculation utilities
internal enum Legendre {
    /// 用显式锁保护归一化因子缓存，确保并发首次计算安全。
    ///
    /// Protects normalization-factor caching with an explicit lock so concurrent
    /// first-time calculations remain race-free.
    /// Thread-safe storage for normalization factors.
    private final class NormalizationCache: @unchecked Sendable {
        private let lock = NSLock()
        private var values: [Int: [[Double]]] = [:]

        func value(for nmax: Int, makeValue: () -> [[Double]]) -> [[Double]] {
            // Hold the lock through creation to prevent duplicate writes and races.
            // 创建缓存值期间保持锁，避免重复写入和数据竞争。
            lock.lock()
            defer { lock.unlock() }

            if let cached = values[nmax] {
                return cached
            }

            let value = makeValue()
            values[nmax] = value
            return value
        }
    }

    /// 归一化因子缓存
    ///
    /// Normalization factors cache
    private static let normalizationCache = NormalizationCache()

    /// 计算施密特归一化的勒让德多项式及其导数
    ///
    /// Calculate Schmidt-normalized Legendre polynomials and their derivatives
    ///
    /// - Parameters:
    ///   - nmax: 最大阶数
    ///     Maximum order
    ///   - theta: 极角（弧度）
    ///     Polar angle (radians)
    /// - Returns:
    ///   包含勒让德多项式值和其导数的元组
    ///   Tuple containing Legendre polynomial values and their derivatives
    static func schmidtNormalized(nmax: Int, theta: SHCAngle, p: inout [[Double]], dp: inout [[Double]]) {
        let sinTheta = theta.sin
        let cosTheta = theta.cos
        let sinThetaSafe = abs(sinTheta) < 1.0e-10 ? (sinTheta >= 0 ? 1.0e-10 : -1.0e-10) : sinTheta

        p[0][0] = 1.0
        dp[0][0] = 0.0

        if nmax == 0 {
            return
        }

        let nDouble = (0...nmax).map { Double($0) }
        let mDouble = (0...nmax).map { Double($0) }

        for m in 1...nmax {
            let mVal = mDouble[m]
            p[m][m] = (2.0 * mVal - 1.0) * sinTheta * p[m - 1][m - 1]
        }

        for m in 0..<nmax {
            let mVal = mDouble[m]
            p[m + 1][m] = (2.0 * mVal + 1.0) * cosTheta * p[m][m]
        }

        if nmax >= 2 {
            for m in 0...nmax {
                if m + 2 > nmax { continue }
                for n in (m + 2)...nmax {
                    let nVal = nDouble[n]
                    let mVal = mDouble[m]
                    let numerator =
                        (2.0 * nVal - 1.0) * cosTheta * p[n - 1][m]
                        - (nVal + mVal - 1.0) * p[n - 2][m]
                    p[n][m] = numerator / (nVal - mVal)
                }
            }
        }

        for n in 1...nmax {
            for m in 0...n {
                let nVal = nDouble[n]
                let mVal = mDouble[m]
                let term = nVal * cosTheta * p[n][m]
                let prev = (n - 1 >= m) ? (nVal + mVal) * p[n - 1][m] : 0.0
                dp[n][m] = (term - prev) / sinThetaSafe
            }
        }

        let normalization = normalizationFactors(nmax: nmax)
        for n in 0...nmax {
            for m in 0...n {
                let factor = normalization[n][m]
                p[n][m] *= factor
                dp[n][m] *= factor
            }
        }

        return
    }

    /// 计算归一化因子
    ///
    /// Calculate normalization factors
    ///
    /// - Parameter nmax: 最大阶数
    ///     Maximum order
    /// - Returns:
    ///   归一化因子矩阵
    ///   Normalization factors matrix
    private static func normalizationFactors(nmax: Int) -> [[Double]] {
        normalizationCache.value(for: nmax) {
            let factorials = computeFactorials(upTo: 2 * nmax)
            var factors = Array(repeating: Array(repeating: 0.0, count: nmax + 1), count: nmax + 1)
            for n in 0...nmax {
                for m in 0...n {
                    factors[n][m] = schmidtNormalization(n: n, m: m, factorials: factorials)
                }
            }
            return factors
        }
    }

    /// 计算阶乘数组
    ///
    /// Calculate factorial array
    ///
    /// - Parameter max: 最大计算值
    ///     Maximum value
    /// - Returns:
    ///   阶乘值数组
    ///   Factorial values array
    private static func computeFactorials(upTo max: Int) -> [Double] {
        if max <= 1 {
            return [1.0]
        }
        var factorials = Array(repeating: 1.0, count: max + 1)
        if max >= 1 {
            for i in 1...max {
                factorials[i] = factorials[i - 1] * Double(i)
            }
        }
        return factorials
    }

    /// 计算施密特归一化因子
    ///
    /// Calculate Schmidt normalization factor
    ///
    /// - Parameters:
    ///   - n: 阶数
    ///     Order
    ///   - m: 次数
    ///     Degree
    ///   - factorials: 阶乘数组
    ///     Factorial array
    /// - Returns:
    ///   归一化因子
    ///   Normalization factor
    private static func schmidtNormalization(n: Int, m: Int, factorials: [Double]) -> Double {
        if n == 0 && m == 0 {
            return 1.0
        }
        let delta = (m == 0) ? 1.0 : 0.0
        let numerator = 2.0 - delta
        let ratio = factorials[n - m] / factorials[n + m]
        return sqrt(numerator * ratio)
    }
}
