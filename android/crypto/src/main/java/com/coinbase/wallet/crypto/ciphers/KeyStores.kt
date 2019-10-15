package com.coinbase.wallet.crypto.ciphers

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.io.IOException
import java.security.KeyStore
import java.security.KeyStoreException
import java.security.NoSuchAlgorithmException
import java.security.UnrecoverableEntryException
import java.security.cert.CertificateException
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import kotlin.concurrent.withLock

object KeyStores {
    /**
     * Get a key spec for gcm block mode without requiring user authentication
     *
     * @param alias the alias of the key
     * @param isAuthenticated whether user authentication is required to access the key. If it is, a randomized iv
     * should be used.
     * @return a key spec for gcm block mode without user authentication
     */
    fun buildGCMKeySpec(alias: String, isAuthenticated: Boolean): KeyGenParameterSpec = KeyGenParameterSpec
        .Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
        .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
        .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
        .setUserAuthenticationRequired(isAuthenticated)
        .setRandomizedEncryptionRequired(isAuthenticated)
        .build()

    /**
     * Get AES secret key for the given keystore, alias and spec. This method will return the existing key, or
     * create a new key.
     *
     * @param keystore the keystore to check
     * @param alias the alias of the key to get
     * @param isAuthenticated whether the key requires user authentication to encrypt/decrypt
     * @return an AES [SecretKey]
     */
    @Throws(
        KeyStoreException::class,
        IOException::class,
        NoSuchAlgorithmException::class,
        CertificateException::class,
        UnrecoverableEntryException::class
    )
    fun getOrCreateAES256GCMSecretKey(keystore: String, alias: String, isAuthenticated: Boolean = false): SecretKey {
        return getOrCreateAESSecretKey(keystore, buildGCMKeySpec(alias, isAuthenticated))
    }

    /**
     * Get AES secret key for the given keystore, alias and spec. This method will return the existing key, or
     * create a new key.
     *
     * @param keystore the keystore to get the secret key from
     * @param spec the [KeyGenParameterSpec] spec to use to create the key if creation is needed.
     * @return an AES [SecretKey]
     */
    @Throws(
        KeyStoreException::class,
        IOException::class,
        NoSuchAlgorithmException::class,
        CertificateException::class,
        UnrecoverableEntryException::class
    )
    fun getOrCreateAESSecretKey(keystore: String, spec: KeyGenParameterSpec): SecretKey = CipherLock.withLock {
        // Attempt to fetch existing stored secret key from Android KeyStore
        val keyStore = KeyStore.getInstance(keystore)
        keyStore.load(null)
        val entry = keyStore.getEntry(spec.keystoreAlias, null) as? KeyStore.SecretKeyEntry
        val secretKey = entry?.secretKey

        if (secretKey != null) return secretKey

        // At this point, no secret key is stored so generate a new one.
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, keystore)
        keyGenerator.init(spec)

        return keyGenerator.generateKey()
    }

    /**
     * Check if the given keystore contains the alias
     *
     * @param keystore the keystore to check
     * @param alias the alias of the key to check if it exists
     * @return boolean indicating whether the alias exists in the given key store
     */
    fun contains(keystore: String, alias: String): Boolean = CipherLock.withLock {
        val keyStore = KeyStore.getInstance(keystore)
        keyStore.load(null)
        return keyStore.containsAlias(alias)
    }

    /**
     * Delete the given key alias from the keystore if it exists
     *
     * @param keystore the keystore to delete the alias from
     * @param alias the alias of the key to delete
     */
    fun delete(keystore: String, alias: String) = CipherLock.withLock {
        val keyStore = KeyStore.getInstance(keystore)
        keyStore.load(null)
        if (keyStore.containsAlias(alias)) keyStore.deleteEntry(alias)
    }
}
