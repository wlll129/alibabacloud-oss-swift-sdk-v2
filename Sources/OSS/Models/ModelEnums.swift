import Foundation

public enum CannedAccessControlList: String {
    case `default`
    case `private`
    case publicRead = "public-read"
    case publicReadWrite = "public-read-write"
}

public enum StorageClass: String, Codable {
    case standard = "Standard"
    case IA
    case archive = "Archive"
    case coldArchive = "ColdArchive"
}

public enum MetadataDirective: String {
    case copy = "COPY"
    case replace = "REPLACE"
}

public enum TaggingDirective: String {
    case copy = "COPY"
    case replace = "REPLACE"
}

/// Specifies the restoration priority.
public enum Tier: String {
    /// The object is restored within one hour.
    case expedited = "Expedited"
    /// The object is restored within two to five hours.
    case standard = "Standard"
    /// The object is restored within five to twelve hours.
    /// Note: This type is not available for deep cold archiving
    case bulk = "Bulk"
}

public enum DataRedundancyType: String, Codable {
    /// Locally redundant storage (LRS) stores copies of each object across different devices in the same zone.
    /// This ensures data reliability and availability even if two storage devices are damaged at the same time.
    case LRS
    /// Zone-redundant storage (ZRS) uses the multi-zone mechanism to distribute user data across multiple zones in the same region.
    /// If one zone becomes unavailable, you can continue to access the data that is stored in other zones.
    case ZRS
}

/// specifies the encoding method to use
public enum EncodingType: String {
    case url
}
