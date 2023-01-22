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
#include "RNCConfigValuesModule.inc.g.h"
  };
}

