 #include "pch.h"
#include "RNCConfig.h"
#if __has_include("RNCConfigValues.h")
#include "RNCConfigValues.h"
#endif
#include <JSValue.h>
using namespace Microsoft::ReactNative;

namespace RNCConfig
{
	JSValueObject RNCConfigModule::getAll() noexcept
	{
		JSValueObject obj{};
	#if __has_include("RNCConfigValuesObject.inc.g.h")
	#include "RNCConfigValuesObject.inc.g.h"
	#endif
		return obj;
	}

	std::string RNCConfigModule::get(std::string const& key) noexcept
	{
	#if __has_include("RNCConfigValuesGet.inc.g.h")
	#include "RNCConfigValuesGet.inc.g.h"
	#endif
		return std::string{};
	}

	void RNCConfigModule::ProvideConstants(ReactConstantProvider& provider) noexcept
	{
	#if __has_include("RNCConfigValuesConstants.inc.g.h")
	#include "RNCConfigValuesConstants.inc.g.h"
	#endif
	}

		std::string RNCConfigModule::compositionInfo() noexcept
		{
			// No-op informational string; placeholder to indicate Composition can be used in this module
			// In a real implementation, you'd create a Compositor and maybe return feature info.
			return std::string{"CompositionReady"};
		}
}
