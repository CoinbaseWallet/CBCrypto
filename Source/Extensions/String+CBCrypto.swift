// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import os.log

private let hexadecimalCharacters = "0123456789abcdef"

extension String {
    /// Strip out "0x" prefix if one exists. Otherwise, no-op
    func strip0x() -> String {
        return starts(with: "0x") ? String(self[index(startIndex, offsetBy: 2)...]) : self
    }

    /// Convert to hex Data if possible
    public func asHexEncodedData() -> Data? {
        let strippedLowerStr = strip0x().lowercased()
        let str = strippedLowerStr.count % 2 == 0 ? strippedLowerStr : "0" + strippedLowerStr

        let length = str.count / 2
        var bytes = [UInt8](repeating: 0, count: length)

        for i in 0 ..< length {
            let hexLeft = str[str.index(str.startIndex, offsetBy: i * 2)]
            let hexRight = str[str.index(str.startIndex, offsetBy: i * 2 + 1)]
            guard let idxLeft = hexadecimalCharacters.index(of: hexLeft) else {
                return nil
            }
            guard let idxRight = hexadecimalCharacters.index(of: hexRight) else {
                return nil
            }
            let valLeft = hexadecimalCharacters.distance(from: hexadecimalCharacters.startIndex, to: idxLeft)
            let valRight = hexadecimalCharacters.distance(from: hexadecimalCharacters.startIndex, to: idxRight)
            bytes[i] = UInt8(valLeft * 16 + valRight)
        }
        return Data(bytes: bytes)
    }
}
