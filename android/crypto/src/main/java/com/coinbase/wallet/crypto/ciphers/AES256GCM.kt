package com.coinbase.wallet.crypto.ciphers

import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import kotlin.concurrent.withLock

/**
 * Utility used to encrypt/decrypt using AES-256 GCM
 */
class AES256GCM {
    companion object {
        private const val AUTH_TAG_SIZE = 128
        private const val TRANSFORMATION = "AES/GCM/NoPadding"

        /**
         * Encrypt data using using AES-256 GCM
         *
         * @param data Data to encrypt
         * @param key Secret used to encrypt the data
         * @param iv Initialization vector. Acts as a salt
         *
         * @return A pair of encrypted data and authTag
         */
        fun encrypt(data: ByteArray, key: ByteArray, iv: ByteArray): Pair<ByteArray, ByteArray> = CipherLock.withLock {
            val cipher = Cipher.getInstance(TRANSFORMATION)
            val paramSpec = GCMParameterSpec(AUTH_TAG_SIZE, iv)
            val keySpec = SecretKeySpec(key, "AES")

            cipher.init(Cipher.ENCRYPT_MODE, keySpec, paramSpec)
            val cipherBytes = cipher.doFinal(data)
            val ciphertextEndIndex = cipherBytes.size - (AUTH_TAG_SIZE / Byte.SIZE_BITS)
            val encryptedBytes = cipherBytes.copyOfRange(0, ciphertextEndIndex)
            val authTagBytes = cipherBytes.copyOfRange(ciphertextEndIndex, cipherBytes.size)

            return Pair(encryptedBytes, authTagBytes)
        }

        /**
         * Encrypt data with AES-256 GCM using using Android KeyStore secret key
         *
         * @param data Data to encrypt
         * @param secretKey Secret key from Android KeyStore
         *
         * @return A triple of iv, authTag, and encrypted data
         * @throws `EncryptionException.invalidAES256GCMData` if unable to encrypt data
         */
        fun encrypt(
            data: ByteArray,
            secretKey: SecretKey
        ): Triple<ByteArray, ByteArray, ByteArray> = CipherLock.withLock {
            val cipher = Cipher.getInstance(TRANSFORMATION)

            cipher.init(Cipher.ENCRYPT_MODE, secretKey)
            val cipherBytes = cipher.doFinal(data)
            val cipherEndIndex = cipherBytes.size - (AUTH_TAG_SIZE / Byte.SIZE_BITS)
            val encryptedBytes = cipherBytes.copyOfRange(0, cipherEndIndex)
            val authTagBytes = cipherBytes.copyOfRange(cipherEndIndex, cipherBytes.size)

            return Triple(cipher.iv, authTagBytes, encryptedBytes)
        }

        /**
         * Decrypt data using using AES-256 GCM
         *
         * @param data Data to decrypt
         * @param key Secret used to encrypt the data
         * @param iv Initialization vector. Acts as a salt
         * @param authTag authentication tag. Used to verify the integrity of the data
         *
         * @return The decrypted data
         * @throws`EncryptionError.invalidAES256GCMData` if unable to decrypt data
         */
        fun decrypt(
            data: ByteArray,
            key: ByteArray,
            iv: ByteArray,
            authTag: ByteArray
        ): ByteArray = CipherLock.withLock {
            val cipher = Cipher.getInstance(TRANSFORMATION)
            val paramSpec = GCMParameterSpec(AUTH_TAG_SIZE, iv)
            val keySpec = SecretKeySpec(key, "AES")
            val encryptedData = data + authTag

            cipher.init(Cipher.DECRYPT_MODE, keySpec, paramSpec)

            return cipher.doFinal(encryptedData)
        }

        /**
         * Decrypt data with AES-256 GCM using using Android KeyStore secret key
         *
         * @param data Data to decrypt
         * @param secretKey Secret key from Android KeyStore
         * @param iv Initialization vector. Acts as a salt
         * @param authTag authentication tag. Used to verify the integrity of the data
         *
         * @return A triple of iv, authTag, and encrypted data
         */
        fun decrypt(
            data: ByteArray,
            secretKey: SecretKey,
            iv: ByteArray,
            authTag: ByteArray
        ): ByteArray = CipherLock.withLock {
            val cipher = Cipher.getInstance(TRANSFORMATION)
            val paramSpec = GCMParameterSpec(AUTH_TAG_SIZE, iv)
            val encryptedData = data + authTag

            cipher.init(Cipher.DECRYPT_MODE, secretKey, paramSpec)
            return cipher.doFinal(encryptedData)
        }
    }
}
