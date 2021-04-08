#pragma once

#include "pch.h"

#include <functional>

#include "NativeModules.h"
#include "RNCConfigValues.h"
namespace RNCConfig
{
  REACT_MODULE(ReactNativeConfigModule);
  struct ReactNativeConfigModule
  {
#include "RNCConfigValuesModule.inc.g.h"
  };
}

