// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation
import os.log

private let hexadecimalArray: [UInt8] = Array("0123456789abcdef".utf8)
private let kAES256GCMIVSize = 12
private let kAES256GCMAuthTagSize = 16

extension Data {
    /// Generate random `Data` based on given length
    ///
    /// - Parameter:
    ///     - numberOfBytes: Size of random `Data` object to generate
    ///
    /// - Returns: Randomized bytes with given size encapsulated in a `Data` object
    public static func randomBytes(_ numberOfBytes: Int) -> Data? {
        var randomBytes = [UInt8](repeating: 0, count: numberOfBytes)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        if status != errSecSuccess { return nil }

        return Data(randomBytes)
    }

    /// Encrypt data using AES256 algorithm for given secret and iv
    ///
    ///     - Secret: Secret used to encrypt the data
    ///
    /// - Returns: The encrypted data
    /// - Throws: `EncryptionError.unableToEncryptData` if unable to encrypt data
    public func encryptUsingAES256GCM(secret: String) throws -> Data {
        guard
            let secretData = secret.asHexEncodedData(),
            let iv = Data.randomBytes(kAES256GCMIVSize),
            let (encryptedData, authTag) = try? AES256GCM.encrypt(
                data: self,
                key: secretData,
                initializationVector: iv
            )
        else { throw EncryptionError.unableToEncryptData }

        var mutableData = Data()
        mutableData.append(iv)
        mutableData.append(authTag)
        mutableData.append(encryptedData)

        return mutableData
    }

    /// Decrypt data with AES256 GCM using provided secret
    public func decryptUsingAES256GCM(secret: String) throws -> Data {
        guard
            let secretData = secret.asHexEncodedData(),
            count > (kAES256GCMAuthTagSize + kAES256GCMIVSize)
        else { throw EncryptionError.unableToDecryptData }

        let iv = subdata(in: 0 ..< kAES256GCMIVSize)
        let authTag = subdata(in: kAES256GCMIVSize ..< kAES256GCMAuthTagSize + kAES256GCMIVSize)
        let dataToDecrypt = subdata(in: kAES256GCMAuthTagSize + kAES256GCMIVSize ..< count)

        guard
            let decryptedData = try? AES256GCM.decrypt(
                data: dataToDecrypt,
                key: secretData,
                initializationVector: iv,
                authenticationTag: authTag
            )
        else { throw EncryptionError.unableToDecryptData }

        return decryptedData
    }

    /// Get a subset data from the current data using the given range
    ///
    /// - Parameter range: Range of sub data
    ///
    /// - Returns: Sub-data
    public func subdata(in range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }
}
