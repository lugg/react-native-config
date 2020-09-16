#include "pch.h"
#include "ReactPackageProvider.h"
#include "ReactPackageProvider.g.cpp"

#include <ModuleRegistration.h>

#include "RNCConfig.h"

namespace winrt::RNCConfig::implementation
{
  void ReactPackageProvider::CreatePackage(IReactPackageBuilder const& packageBuilder) noexcept
  {
    AddAttributedModules(packageBuilder);
  }
}
