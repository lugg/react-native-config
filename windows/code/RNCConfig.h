#pragma once

#include "pch.h"

#include <functional>

#include "NativeModules.h"
#include "RNCConfigValues.h"
namespace RNCConfig
{
  REACT_MODULE(RNCConfigModule);
  struct RNCConfigModule
  {
#if __has_include("RNCConfigValuesModule.inc.g.h")
#include "RNCConfigValuesModule.inc.g.h"
#else
// Generated constants will be included at build-time
#endif

  // TurboModule-friendly sync APIs
  REACT_SYNC_METHOD(getAll);
  Microsoft::ReactNative::JSValueObject getAll() noexcept;

  REACT_SYNC_METHOD(get);
  std::string get(std::string const& key) noexcept;

  // Keep constants available via the classic constants provider too
  REACT_CONSTANT_PROVIDER(ProvideConstants);
  void ProvideConstants(Microsoft::ReactNative::ReactConstantProvider& provider) noexcept;

  // Example Windows.UI.Composition usage exposed via a sync method
  REACT_SYNC_METHOD(compositionInfo);
  std::string compositionInfo() noexcept;
  };
}

