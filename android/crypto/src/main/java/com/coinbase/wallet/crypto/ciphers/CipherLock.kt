package com.coinbase.wallet.crypto.ciphers

import java.util.concurrent.locks.ReentrantLock

/**
 * A lock for crypto module to use to synchronize crypto operations
 */
internal object CipherLock : ReentrantLock()
