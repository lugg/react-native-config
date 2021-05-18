package com.lugg.ReactNativeConfig;

import android.content.Context;
import android.content.res.Resources;
import android.util.Log;
import android.util.Base64;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

import java.lang.ClassNotFoundException;
import java.lang.IllegalAccessException;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class ReactNativeConfigModule extends ReactContextBaseJavaModule {
  public ReactNativeConfigModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "ReactNativeConfigModule";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();

    try {
      Context context = getReactApplicationContext();
      int resId = context.getResources().getIdentifier("build_config_package", "string", context.getPackageName());
      String className;
      try {
        className = context.getString(resId);
      } catch (Resources.NotFoundException e) {
        className = getReactApplicationContext().getApplicationContext().getPackageName();
      }
      Class clazz = Class.forName(className + ".BuildConfig");

      Field xorKeyField;
      Field encodedKeysField;

      String xorKey = null;
      List<String> encodedKeys = new ArrayList<>();
      try {
        xorKeyField = clazz.getDeclaredField("XOR_KEY");
        xorKey = (String) xorKeyField.get(null);
        encodedKeysField = clazz.getDeclaredField("ENCODED_KEYS");
        encodedKeys = Arrays.asList((String[]) encodedKeysField.get(new String[1]));
      } catch(NoSuchFieldException | SecurityException | IllegalAccessException e) {
        Log.d("ReactNative", "ReactConfig: Could not access XOR_KEY or ENCODED_KEYS");
      }

      Field[] fields = clazz.getDeclaredFields();
      for(Field f: fields) {
        try {
          Object value = f.get(null);
          String name = f.getName();
          if (xorKey != null && encodedKeys.contains(name)) {
            value = decode(value, xorKey);
          }
          constants.put(name, value);
        }
        catch (IllegalAccessException e) {
          Log.d("ReactNative", "ReactConfig: Could not access BuildConfig field " + f.getName());
        }
      }
    }
    catch (ClassNotFoundException e) {
      Log.d("ReactNative", "ReactConfig: Could not find BuildConfig class");
    }

    return constants;
  }

  private String decode(Object encodedString, String key) {
    byte[] decodedBytes = Base64.decode((String) encodedString, Base64.DEFAULT);
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
