package com.lugg.ReactNativeConfig;

import android.content.Context;
import android.content.res.Resources;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

import java.lang.ClassNotFoundException;
import java.lang.IllegalAccessException;
import java.lang.reflect.Field;
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
      Field[] fields = clazz.getDeclaredFields();
      for(Field f: fields) {
        try {
          Object value = f.get(null);
          // Make sure that the value is supported by RN.
          Arguments.fromList(List.of(value));
          constants.put(f.getName(), value);
        }
        catch (IllegalAccessException e) {
          Log.d("ReactNative", "ReactConfig: Could not access BuildConfig field " + f.getName());
        }
        catch (IllegalArgumentException e) {
          Log.d("ReactNative", "ReactConfig: Unsupported BuildConfig field type " + f.getName());
        }
      }
    }
    catch (ClassNotFoundException e) {
      Log.d("ReactNative", "ReactConfig: Could not find BuildConfig class");
    }

    return constants;
  }
}
