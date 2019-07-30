// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension NSRange {
    public func range(on string: NSString) -> Range<String.Index>? {
        let substring = string.substring(with: self)
        return (string as String).range(of: substring)
    }

    public func range(on string: String) throws -> Range<String.Index>? {
        guard let substring = string.substring(nsRange: self) else { throw StringError.indexOutOfBounds }
        return (string).range(of: substring)
    }
}
