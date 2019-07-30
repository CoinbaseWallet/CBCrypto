// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import CBCore
import os.log

let kAES256GCMIVSize = 12
let kAES256GCMAuthTagSize = 16

extension String {
    /// Encrypt string using AES256 algorithm for given secret and iv
    ///
    ///     - Secret: Secret used to encrypt the data
    ///
    /// - Returns: The encrypted data
    /// - Throws: `WalletLinkError.unableToEncryptData` if unable to encrypt data
    public func encryptUsingAES256GCM(secret: String) throws -> String {
        guard
            let secretData = secret.asHexEncodedData,
            let dataToEncrypt = self.data(using: .utf8),
            let iv = Data.randomBytes(kAES256GCMIVSize),
            let (encryptedData, authTag) = try? AES256GCM.encrypt(
                data: dataToEncrypt,
                key: secretData,
                initializationVector: iv
            )
        else {
            throw EncryptionError.unableToEncryptData
        }

        var mutableData = Data()
        mutableData.append(iv)
        mutableData.append(authTag)
        mutableData.append(encryptedData)

        return mutableData.toHexString()
    }

    /// Decrypt string with AES256 GCM using provided secret
    public func decryptUsingAES256GCM(secret: String) throws -> Data {
        guard
            let data = self.asHexEncodedData,
            let secretData = secret.asHexEncodedData,
            data.count > (kAES256GCMAuthTagSize + kAES256GCMIVSize)
        else {
            throw EncryptionError.unableToDecryptData
        }

        let iv = data.subdata(in: 0 ..< kAES256GCMIVSize)
        let authTag = data.subdata(in: kAES256GCMIVSize ..< kAES256GCMAuthTagSize + kAES256GCMIVSize)
        let dataToDecrypt = data.subdata(in: kAES256GCMAuthTagSize + kAES256GCMIVSize ..< data.count)

        guard
            let decryptedData = try? AES256GCM.decrypt(
                data: dataToDecrypt,
                key: secretData,
                initializationVector: iv,
                authenticationTag: authTag
            )
        else {
            throw EncryptionError.unableToDecryptData
        }

        return decryptedData
    }
}
