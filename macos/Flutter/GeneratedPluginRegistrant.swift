//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import camera_macos
import desktop_drop
import device_info_plus
import irondash_engine_context
import screen_retriever_macos
import shared_preferences_foundation
import super_native_extensions
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  CameraMacosPlugin.register(with: registry.registrar(forPlugin: "CameraMacosPlugin"))
  DesktopDropPlugin.register(with: registry.registrar(forPlugin: "DesktopDropPlugin"))
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  IrondashEngineContextPlugin.register(with: registry.registrar(forPlugin: "IrondashEngineContextPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SuperNativeExtensionsPlugin.register(with: registry.registrar(forPlugin: "SuperNativeExtensionsPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
