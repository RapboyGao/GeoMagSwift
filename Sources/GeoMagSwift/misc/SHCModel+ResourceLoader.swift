import Foundation

/// SHCModel 资源加载扩展
///
/// SHCModel resource loading extension
public extension SHCModel {
    /// Errors that can occur while loading a bundled JSON model resource.
    /// 加载内置 JSON 地磁模型资源时可能发生的错误。
    enum ResourceError: Error, Sendable, Hashable {
        /// The resource name contains characters outside the model identifier format.
        /// 资源名称包含模型标识符格式之外的字符。
        case invalidResourceName(name: String)
        /// The requested resource does not exist in the module bundle.
        /// 请求的资源不存在于模块 Bundle 中。
        case resourceNotFound(name: String)
        /// The resource is larger than the supported limit.
        /// 资源大小超过允许的上限。
        case resourceTooLarge(name: String, byteCount: Int, maximum: Int)
        /// The resource could not be read from the module bundle.
        /// 无法从模块 Bundle 中读取资源。
        case resourceReadFailed(name: String, reason: String)
        /// The resource was read but could not be decoded as an SHCModel.
        /// 资源读取成功，但无法解码为 SHCModel。
        case resourceDecodeFailed(name: String, reason: String)
    }

    /// 从资源文件加载 SHCModel
    ///
    /// Load SHCModel from resource file
    ///
    /// - Parameter name: 资源文件名（不含扩展名）
    ///   Resource file name (without extension)
    /// - Returns: 加载的 SHCModel 对象
    ///   Loaded SHCModel object
    static func loadResource(_ name: String) throws -> SHCModel {
        // Restrict resource identifiers to prevent path traversal and unexpected bundle lookups.
        // 限制资源标识符格式，防止路径穿越和非预期的 Bundle 查找。
        let isValidName =
            !name.isEmpty
            && name.unicodeScalars.allSatisfy { scalar in
                (scalar.value >= 48 && scalar.value <= 57)
                    || (scalar.value >= 65 && scalar.value <= 90)
                    || (scalar.value >= 97 && scalar.value <= 122)
                    || scalar.value == 45
                    || scalar.value == 95
            }
        guard isValidName else {
            throw ResourceError.invalidResourceName(name: name)
        }

        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw ResourceError.resourceNotFound(name: name)
        }

        // Bound the amount of data that can be read before JSON decoding allocates model storage.
        // 在 JSON 解码分配模型存储前限制可读取的数据量。
        let maximumResourceSize = 16 * 1024 * 1024
        if let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
            let byteCount = resourceValues.fileSize,
            byteCount > maximumResourceSize
        {
            throw ResourceError.resourceTooLarge(
                name: name, byteCount: byteCount, maximum: maximumResourceSize)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ResourceError.resourceReadFailed(name: name, reason: String(reflecting: error))
        }

        do {
            return try JSONDecoder().decode(SHCModel.self, from: data)
        } catch {
            throw ResourceError.resourceDecodeFailed(name: name, reason: String(reflecting: error))
        }
    }

    /// 加载内置静态模型属性所必需的 Bundle 模型。
    ///
    /// Load a bundled model required by a built-in static model property.
    ///
    /// A missing or invalid built-in resource is a packaging error and cannot be
    /// recovered from while preserving the existing static-property API.
    /// 内置资源缺失或损坏属于打包错误；为了保留现有静态属性 API，无法在运行时恢复。
    static func requiredResource(_ name: String) -> SHCModel {
        do {
            return try loadResource(name)
        } catch {
            preconditionFailure("Unable to load required geomagnetic model '\(name)': \(error)")
        }
    }

    /// 编码键枚举
    ///
    /// Coding keys enum
    private enum CodingKeys: String, CodingKey {
        /// 文件名字段
        ///
        /// File name field
        case fileName
        /// 头部信息字段
        ///
        /// Headers field
        case headers
        /// 头部数字信息字段
        ///
        /// Header numbers field
        case headerNumbers
        /// 历元字段
        ///
        /// Epochs field
        case epochs
        /// 有效期开始字段
        ///
        /// Valid-from field
        case validFrom
        /// 有效期结束字段
        ///
        /// Valid-to field
        case validTo
        /// 系数字段
        ///
        /// Coefficients field
        case coefficients
    }

    /// 从解码器初始化
    ///
    /// Initialize from decoder
    ///
    /// - Parameter decoder: 解码器
    ///   Decoder
    /// - Throws: 解码错误
    ///   Decoding error
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fileName = try container.decode(String.self, forKey: .fileName)
        let headers = try container.decode([String].self, forKey: .headers)
        let headerNumbers = try container.decode([Double].self, forKey: .headerNumbers)
        let epochs = try container.decode([Double].self, forKey: .epochs)
        let validFrom = try container.decodeIfPresent(Double.self, forKey: .validFrom)
        let validTo = try container.decodeIfPresent(Double.self, forKey: .validTo)
        let coefficients = try container.decode([Coefficient].self, forKey: .coefficients)
        self.init(
            fileName: fileName,
            headers: headers,
            headerNumbers: headerNumbers,
            epochs: epochs,
            coefficients: coefficients,
            validFrom: validFrom,
            validTo: validTo
        )
    }

    /// 编码到编码器
    ///
    /// Encode to encoder
    ///
    /// - Parameter encoder: 编码器
    ///   Encoder
    /// - Throws: 编码错误
    ///   Encoding error
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(headers, forKey: .headers)
        try container.encode(headerNumbers, forKey: .headerNumbers)
        try container.encode(epochs, forKey: .epochs)
        try container.encode(validFrom, forKey: .validFrom)
        try container.encode(validTo, forKey: .validTo)
        try container.encode(coefficients, forKey: .coefficients)
    }
}
