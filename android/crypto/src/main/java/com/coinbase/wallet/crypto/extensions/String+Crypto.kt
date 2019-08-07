package com.coinbase.wallet.crypto.extensions

import com.coinbase.wallet.core.extensions.asHexEncodedData
import com.coinbase.wallet.core.extensions.strip0x
import com.coinbase.wallet.core.extensions.toPrefixedHexString
import com.coinbase.wallet.core.util.ByteArrays
import com.coinbase.wallet.crypto.ciphers.AES256GCM
import com.coinbase.wallet.crypto.exceptions.EncryptionException
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

private const val kAES256GCMIVSize = 12
private const val kAES256GCMAuthTagSize = 16

/**
 * Encrypt string using AES256GCM algorithm for given secret and iv
 *
 *  @param secret Secret used to encrypt the data
 *  @param iv Initialization vector. Acts as a salt
 *
 * @return The encrypted data
 * @throws `WalletLinkError.unableToEncryptData` if unable to encrypt data
 */
@Throws(EncryptionException.UnableToEncryptData::class)
fun String.encryptUsingAES256GCM(secret: ByteArray, iv: ByteArray): String {
    try {
        val dataToEncrypt = toByteArray()
        val result = AES256GCM.encrypt(dataToEncrypt, secret, iv)
        val combinedByteArray = iv + result.second + result.first

        return combinedByteArray.toPrefixedHexString().strip0x()
    } catch (err: IllegalAccessException) {
        throw EncryptionException.UnableToEncryptData
    }
}

/**
 * Helper function to allow String `secret`. See function above for details
 */
@Throws(EncryptionException.UnableToEncryptData::class)
fun String.encryptUsingAES256GCM(secret: String, iv: ByteArray): String {
    val secretData = secret.asHexEncodedData() ?: throw EncryptionException.UnableToEncryptData
    return encryptUsingAES256GCM(secretData, iv)
}

/**
 * Helper function to generate a random IV. See function above for details
 */
@Throws(EncryptionException.UnableToEncryptData::class)
fun String.encryptUsingAES256GCM(secret: String): String {
    return encryptUsingAES256GCM(secret, ByteArrays.randomBytes(kAES256GCMIVSize))
}

/**
 * Decrypt string with AES256 GCM using provided secret
 */
@Throws(EncryptionException.UnableToDecryptData::class)
fun String.decryptUsingAES256GCM(secret: String): ByteArray {
    val encryptedData = asHexEncodedData() ?: throw EncryptionException.UnableToDecryptData
    val secretData = secret.asHexEncodedData() ?: throw EncryptionException.UnableToDecryptData

    if (encryptedData.size < (kAES256GCMAuthTagSize + kAES256GCMIVSize)) {
        throw EncryptionException.UnableToDecryptData
    }

    try {
        val ivEndIndex = kAES256GCMIVSize
        val authTagEndIndex = ivEndIndex + kAES256GCMAuthTagSize
        val iv = encryptedData.copyOfRange(0, ivEndIndex)
        val authTag = encryptedData.copyOfRange(ivEndIndex, authTagEndIndex)
        val dataToDecrypt = encryptedData.copyOfRange(authTagEndIndex, encryptedData.size)

        return AES256GCM.decrypt(data = dataToDecrypt, key = secretData, iv = iv, authTag = authTag)
    } catch (err: Exception) {
        throw EncryptionException.UnableToDecryptData
    }
}

/**
 * Hash the string using sha256
 *
 * @throws `NoSuchAlgorithmException` when unable to sha256
 */
@Throws(NoSuchAlgorithmException::class)
fun String.sha256(): String {
    val md = MessageDigest.getInstance("SHA-256")
    md.update(this.toByteArray())
    return md.digest().toHexString()
}
