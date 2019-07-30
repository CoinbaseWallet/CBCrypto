// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import CryptoSwift

/// Utility used to encrypt/decrypt using AES-256 GCM
public struct AES256GCM {
    // MARK: - Encryption

    /// Encrypt data using using AES-256 GCM. This function should be used when generating a PBKDF2 key is needed.
    ///
    /// - Parameters:
    ///     - data: Data to encrypt
    ///     - passphrase: Secret used to encrypt the data
    ///     - salt: The salt used to generate the encyption key
    ///     - iterations: The number of iterations used to generate the encryption key
    ///     - initializationVector: Initialization vector. Acts as a salt
    ///     - authenticationTag: authentication tag. Used to verify the integrity of the data
    ///
    /// - Returns: The encrypted data
    /// - Throws: An `EncryptionError.invalidAES256GCMData` if unable to encrypt data
    public static func encrypt(
        data: Data,
        passphrase: Data,
        salt: Data,
        iterations: UInt32,
        initializationVector: Data
    ) throws -> (encryptedData: Data, authenticationTag: Data) {
        let key = PBKDF2.deriveKey(forPassword: passphrase, withSalt: Data(salt), iterations: iterations)

        return try encrypt(data: data, key: key, initializationVector: initializationVector)
    }

    /// Encrypt data using using AES-256 GCM
    ///
    /// - Parameters:
    ///     - data: Data to encrypt
    ///     - key: Secret used to encrypt the data
    ///     - initializationVector: Initialization vector. Acts as a salt
    ///
    /// - Returns: The encrypted data
    /// - Throws: An `EncryptionError.invalidAES256GCMData` if unable to encrypt data
    public static func encrypt(
        data: Data,
        key: Data,
        initializationVector: Data
    ) throws -> (encryptedData: Data, authenticationTag: Data) {
        let gcm = GCM(iv: [UInt8](initializationVector), mode: .detached)
        let aes = try CryptoSwift.AES(key: [UInt8](key), blockMode: gcm, padding: .noPadding)
        let encryptedValue = try aes.encrypt([UInt8](data))

        guard let authenticationTag = gcm.authenticationTag else {
            throw EncryptionError.unableToGenerateAuthenticationTag
        }

        return (encryptedData: Data(encryptedValue), authenticationTag: Data(authenticationTag))
    }

    // MARK: - Decryption

    /// Decrypt data using using AES-256 GCM. This function should be used when generating a PBKDF2 key is needed.
    ///
    /// - Parameters:
    ///     - data: Data to decrypt
    ///     - passphrase: Secret used to encrypt the data
    ///     - salt: The salt used to generate the encyption key
    ///     - iterations: The number of iterations used to generate the encryption keyO
    ///     - initializationVector: Initialization vector. Acts as a salt
    ///     - authenticationTag: authentication tag. Used to verify the integrity of the data
    ///
    /// - Returns: The decrypted data
    /// - Throws: An `EncryptionError.invalidAES256GCMData` if unable to decrypt data
    public static func decrypt(
        data: Data,
        passphrase: Data,
        salt: Data,
        iterations: UInt32,
        initializationVector: Data,
        authenticationTag: Data
    ) throws -> Data {
        let key = PBKDF2.deriveKey(forPassword: passphrase, withSalt: Data(salt), iterations: iterations)

        return try decrypt(
            data: data,
            key: key,
            initializationVector: initializationVector,
            authenticationTag: authenticationTag
        )
    }

    /// Decrypt data using using AES-256 GCM
    ///
    /// - Parameters:
    ///     - data: Data to decrypt
    ///     - key: Secret used to encrypt the data
    ///     - initializationVector: Initialization vector. Acts as a salt
    ///     - authenticationTag: authentication tag. Used to verify the integrity of the data
    ///
    /// - Returns: The decrypted data
    /// - Throws: An `EncryptionError.invalidAES256GCMData` if unable to decrypt data
    public static func decrypt(
        data: Data,
        key: Data,
        initializationVector: Data,
        authenticationTag: Data
    ) throws -> Data {
        let gcm = GCM(iv: [UInt8](initializationVector), authenticationTag: [UInt8](authenticationTag), mode: .detached)
        let aes = try CryptoSwift.AES(key: [UInt8](key), blockMode: gcm, padding: .noPadding)
        let decryptedValue: [UInt8] = try aes.decrypt([UInt8](data))

        return Data(decryptedValue)
    }
}
