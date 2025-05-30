import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    setupMethodChannels()
  }
  
  // MARK: - Private Methods
  
  private func setupMethodChannels() {
    guard let mainFlutterWindow = NSApplication.shared.windows.first(where: { $0 is MainFlutterWindow }) as? MainFlutterWindow,
          let controller = mainFlutterWindow.contentViewController as? FlutterViewController else {
      return
    }
    
    let systemMonitorChannel = FlutterMethodChannel(
      name: "com.example.island",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    systemMonitorChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handleMethodCall(call, result: result)
    }
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSystemInfo":
      getSystemInfo(result: result)
    case "getCpuUsage":
      getCpuUsage(result: result)
    case "getMemoryInfo":
      getMemoryInfo(result: result)
    case "getDiskUsagePercentage":
      getDiskUsagePercentage(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - System Info Methods
  
  private func getSystemInfo(result: @escaping FlutterResult) {
    let cpuUsage = SystemMonitor.getCpuUsage()
    let memoryInfo = SystemMonitor.getMemoryInfo()
    
    let systemInfo: [String: Any] = [
      "cpu": cpuUsage,
      "memoryUsage": memoryInfo["usage"] ?? 0.0,
      "totalMemory": memoryInfo["totalGB"] ?? 0.0,
      "usedMemory": memoryInfo["usedGB"] ?? 0.0
    ]
    
    result(systemInfo)
  }
  
  private func getCpuUsage(result: @escaping FlutterResult) {
    let cpuUsage = SystemMonitor.getCpuUsage()
    result(cpuUsage)
  }
  
  private func getMemoryInfo(result: @escaping FlutterResult) {
    let memoryInfo = SystemMonitor.getMemoryInfo()
    result(memoryInfo)
  }

  private func getDiskUsagePercentage(result: @escaping FlutterResult) {
    do {
      let fileManager = FileManager.default
      let homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
      let attributes = try fileManager.attributesOfFileSystem(forPath: homeDirectory.path)
      
      guard let totalSize = attributes[.systemSize] as? NSNumber,
            let freeSize = attributes[.systemFreeSize] as? NSNumber else {
        result(0.0)
        return
      }

      let totalSpace = totalSize.doubleValue
      let freeSpace = freeSize.doubleValue
      let usedSpace = totalSpace - freeSpace
      let percentage = (usedSpace / totalSpace) * 100.0

      result(percentage)
    } catch {
      print("Erro ao obter espaço do disco: \(error)")
      result(0.0)
    }
  }
}
