// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension FileManager {
    public func createDirectoryIfNeeded(
        at url: URL,
        withIntermediateDirectories: Bool = false,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(
                at: url,
                withIntermediateDirectories: withIntermediateDirectories,
                attributes: attributes
            )
        }
    }
}
