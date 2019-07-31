package com.coinbase.wallet.crypto.extensions


/**
 * Convert ByteArray to hex encoded string
 */
fun ByteArray.toHexString(): String {
    val result = StringBuffer()
    for (byt in this) {
        val hex = Integer.toString((byt and 0xff) + 0x100, 16).substring(1)
        result.append(hex)
    }

    return result.toString()
}

private infix fun Byte.and(value: Int) = toInt() and value
