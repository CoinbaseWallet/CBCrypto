// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation
import os.log

extension Data {
    /// Encrypt data using AES256 algorithm for given secret and iv
    ///
    ///     - Secret: Secret used to encrypt the data
    ///
    /// - Returns: The encrypted data
    /// - Throws: `EncryptionError.unableToEncryptData` if unable to encrypt data
    public func encryptUsingAES256GCM(secret: String) throws -> Data {
        guard
            let secretData = secret.asHexEncodedData,
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
            let secretData = secret.asHexEncodedData,
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
}
