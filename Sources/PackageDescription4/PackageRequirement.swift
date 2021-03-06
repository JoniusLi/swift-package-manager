/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2018 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

extension Package.Dependency.Requirement: Encodable {

    /// Returns a requirement for the given exact version.
    ///
    /// Specifying exact version requirements are usually not recommended, as
    /// they can cause conflicts in your package dependency graph when a package
    /// is depended on by multiple other packages.
    ///
    /// Example:
    ///
    ///   .exact("1.2.3")
    ///
    /// - Parameters:
    ///      - version: The exact version to be specified.
    public static func exact(_ version: Version) -> Package.Dependency.Requirement {
      #if PACKAGE_DESCRIPTION_4
        return .exactItem(version)
      #else
        return ._exactItem(version)
      #endif
    }

    /// Returns a requirement for a source control revision. This is usually
    /// specified with the hash of a commit.
    ///
    /// Note that packages which use commit-based dependency requirements
    /// cannot be depended-upon by packages which use version-based dependency
    /// requirements; you should remove commit-based dependency requirements
    /// before publishing a version of your package.
    ///
    /// Example:
    ///
    ///   .revision("e74b07278b926c9ec6f9643455ea00d1ce04a021")
    ///
    /// - Parameters:
    ///     - ref: The Git revision, usually a hash of the commit.
    public static func revision(_ ref: String) -> Package.Dependency.Requirement {
      #if PACKAGE_DESCRIPTION_4
        return .revisionItem(ref)
      #else
        return ._revisionItem(ref)
      #endif
    }

    /// Returns a requirement for a source control branch.
    ///
    /// Note that packages which use branch-based dependency requirements
    /// cannot be depended-upon by packages which use version-based dependency
    /// requirements; you should remove branch-based dependency requirements
    /// before publishing a version of your package.
    ///
    /// Example:
    ///
    ///    .branch("develop")
    ///
    /// - Parameters:
    ///     - name: The name of the branch.
    public static func branch(_ name: String) -> Package.Dependency.Requirement {
      #if PACKAGE_DESCRIPTION_4
        return .branchItem(name)
      #else
        return ._branchItem(name)
      #endif
    }

    /// Returns a requirement for a version range, starting at the given minimum
    /// version and going up to the next major version.
    ///
    /// - Parameters:
    ///     - version: The minimum version for the version range.
    public static func upToNextMajor(from version: Version) -> Package.Dependency.Requirement {
      #if PACKAGE_DESCRIPTION_4
        return .rangeItem(version..<Version(version.major + 1, 0, 0))
      #else
        return ._rangeItem(version..<Version(version.major + 1, 0, 0))
      #endif
    }

    /// Returns a requirement for a version range, starting at the given minimum
    /// version and going up to the next minor version.
    ///
    /// - Parameters:
    ///     - version: The minimum version for the version range.
    public static func upToNextMinor(from version: Version) -> Package.Dependency.Requirement {
      #if PACKAGE_DESCRIPTION_4
        return .rangeItem(version..<Version(version.major, version.minor + 1, 0))
      #else
        return ._rangeItem(version..<Version(version.major, version.minor + 1, 0))
      #endif
    }

    private enum CodingKeys: CodingKey {
        case type
        case lowerBound
        case upperBound
        case identifier
    }

    private enum Kind: String, Codable {
        case range
        case exact
        case branch
        case revision
        case localPackage
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
      #if PACKAGE_DESCRIPTION_4
        switch self {
        case .rangeItem(let range):
            try container.encode(Kind.range, forKey: .type)
            try container.encode(range.lowerBound, forKey: .lowerBound)
            try container.encode(range.upperBound, forKey: .upperBound)
        case .exactItem(let version):
            try container.encode(Kind.exact, forKey: .type)
            try container.encode(version, forKey: .identifier)
        case .branchItem(let identifier):
            try container.encode(Kind.branch, forKey: .type)
            try container.encode(identifier, forKey: .identifier)
        case .revisionItem(let identifier):
            try container.encode(Kind.revision, forKey: .type)
            try container.encode(identifier, forKey: .identifier)
        case .localPackageItem:
            try container.encode(Kind.localPackage, forKey: .type)
        }
      #else
        switch self {
        case ._rangeItem(let range):
            try container.encode(Kind.range, forKey: .type)
            try container.encode(range.lowerBound, forKey: .lowerBound)
            try container.encode(range.upperBound, forKey: .upperBound)
        case ._exactItem(let version):
            try container.encode(Kind.exact, forKey: .type)
            try container.encode(version, forKey: .identifier)
        case ._branchItem(let identifier):
            try container.encode(Kind.branch, forKey: .type)
            try container.encode(identifier, forKey: .identifier)
        case ._revisionItem(let identifier):
            try container.encode(Kind.revision, forKey: .type)
            try container.encode(identifier, forKey: .identifier)
        case ._localPackageItem:
            try container.encode(Kind.localPackage, forKey: .type)
        }
      #endif
    }
}
