import Foundation

public enum Defaults {
    public static let product: String = "oss"

    public static let maxAttempt: Int = 3
    public static let maxBackoff: TimeInterval = 20
    public static let baseDelay: TimeInterval = 0.3

    public static let backgroundSesseionIdentifier = "com.aliyun.oss.backgroundsession"

    // defaults for feature flags
    public static let featureFlags: FeatureFlag = [.correctClockSkew, .autoDetectMimeType, .enableCRC64CheckUpload, .enableCRC64CheckDownload]
}
