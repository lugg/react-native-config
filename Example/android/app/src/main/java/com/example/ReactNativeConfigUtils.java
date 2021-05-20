package com.example;

import android.util.Base64;

public class ReactNativeConfigUtils {
    public static String decode(String encodedString, String key) {
        byte[] decodedBytes = Base64.decode(encodedString, Base64.DEFAULT);
        byte[] keyBytes = key.getBytes();

        int len = decodedBytes.length;
        int keyBytesLen = keyBytes.length;

        byte[] resultBytes = new byte[len];

        for (int i = 0; i < decodedBytes.length; i++) {
            resultBytes[i] = (byte) (decodedBytes[i] ^ keyBytes[i % keyBytesLen]);
        }

        return new String(resultBytes);
    }
}
