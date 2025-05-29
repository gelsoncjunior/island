// ===== SWIFT NATIVE CODE =====
// macos/Runner/AppDelegate.swift
import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller: FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    
    // Registra o MethodChannel
    let systemMonitorChannel = FlutterMethodChannel(
      name: "com.example.system_monitor",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    systemMonitorChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getSystemInfo":
        self.getSystemInfo(result: result)
      case "getCpuUsage":
        self.getCpuUsage(result: result)
      case "getMemoryInfo":
        self.getMemoryInfo(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
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
}

// ===== SYSTEM MONITOR CLASS =====
// macos/Runner/SystemMonitor.swift
import Foundation
import Darwin

class SystemMonitor {
  
  // MARK: - CPU Usage
  
  static func getCpuUsage() -> Double {
    var cpuInfo: processor_info_array_t!
    var numCpuInfo: mach_msg_type_number_t = 0
    var numCpus: natural_t = 0
    
    let result = host_processor_info(
      mach_host_self(),
      PROCESSOR_CPU_LOAD_INFO,
      &numCpus,
      &cpuInfo,
      &numCpuInfo
    )
    
    guard result == KERN_SUCCESS else {
      print("Erro ao obter informações de CPU: \(result)")
      return 0.0
    }
    
    let cpuLoadInfo = cpuInfo.bindMemory(
      to: processor_cpu_load_info.self,
      capacity: Int(numCpus)
    )
    
    var totalUser: UInt32 = 0
    var totalSys: UInt32 = 0
    var totalIdle: UInt32 = 0
    var totalNice: UInt32 = 0
    
    for i in 0..<Int(numCpus) {
      totalUser += cpuLoadInfo[i].cpu_ticks.0  // CPU_STATE_USER
      totalSys += cpuLoadInfo[i].cpu_ticks.1   // CPU_STATE_SYSTEM
      totalIdle += cpuLoadInfo[i].cpu_ticks.2  // CPU_STATE_IDLE
      totalNice += cpuLoadInfo[i].cpu_ticks.3  // CPU_STATE_NICE (se disponível)
    }
    
    let totalTicks = totalUser + totalSys + totalIdle + totalNice
    let totalActive = totalUser + totalSys + totalNice
    
    // Libera memória alocada
    vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCpuInfo))
    
    guard totalTicks > 0 else { return 0.0 }
    
    let usage = Double(totalActive) / Double(totalTicks) * 100.0
    
    // Garante que o valor esteja entre 0 e 100
    return min(max(usage, 0.0), 100.0)
  }
  
  // MARK: - Memory Usage
  
  static func getMemoryInfo() -> [String: Double] {
    var vmStats = vm_statistics64()
    var infoCount = mach_msg_type_number_t(
      MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride
    )
    
    let result = withUnsafeMutablePointer(to: &vmStats) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(infoCount)) {
        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &infoCount)
      }
    }
    
    guard result == KERN_SUCCESS else {
      print("Erro ao obter estatísticas de memória: \(result)")
      return ["usage": 0.0, "totalGB": 0.0, "usedGB": 0.0]
    }
    
    // Obtém o tamanho da página do sistema
    var pageSize: vm_size_t = 0
    host_page_size(mach_host_self(), &pageSize)
    
    // Calcula as páginas de memória
    let freePages = UInt64(vmStats.free_count)
    let activePages = UInt64(vmStats.active_count)
    let inactivePages = UInt64(vmStats.inactive_count)
    let wiredPages = UInt64(vmStats.wire_count)
    let compressedPages = UInt64(vmStats.compressor_page_count)
    let speculativePages = UInt64(vmStats.speculative_count)
    
    // Memória total física do sistema
    let totalPhysicalMemory = ProcessInfo.processInfo.physicalMemory
    
    // Calcula memória usada (páginas ativas + inativas + wired + comprimidas)
    let usedPages = activePages + inactivePages + wiredPages + compressedPages
    let usedMemory = usedPages * UInt64(pageSize)
    
    // Calcula porcentagem de uso
    let memoryUsage = Double(usedMemory) / Double(totalPhysicalMemory) * 100.0
    
    // Converte para GB
    let totalMemoryGB = Double(totalPhysicalMemory) / (1024.0 * 1024.0 * 1024.0)
    let usedMemoryGB = Double(usedMemory) / (1024.0 * 1024.0 * 1024.0)
    
    return [
      "usage": min(max(memoryUsage, 0.0), 100.0),
      "totalGB": totalMemoryGB,
      "usedGB": usedMemoryGB,
      "freeGB": (Double(totalPhysicalMemory - usedMemory) / (1024.0 * 1024.0 * 1024.0))
    ]
  }
  
  // MARK: - System Information
  
  static func getSystemInfo() -> [String: Any] {
    let cpuUsage = getCpuUsage()
    let memoryInfo = getMemoryInfo()
    
    // Informações adicionais do sistema
    let processInfo = ProcessInfo.processInfo
    let operatingSystemVersion = processInfo.operatingSystemVersion
    
    return [
      "cpu": cpuUsage,
      "memory": memoryInfo,
      "osVersion": "\(operatingSystemVersion.majorVersion).\(operatingSystemVersion.minorVersion).\(operatingSystemVersion.patchVersion)",
      "processorCount": processInfo.processorCount,
      "activeProcessorCount": processInfo.activeProcessorCount,
      "physicalMemory": processInfo.physicalMemory,
      "systemUptime": processInfo.systemUptime
    ]
  }
  
  // MARK: - Utility Methods
  
  static func formatBytes(_ bytes: UInt64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useGB, .useMB, .useKB]
    formatter.countStyle = .memory
    return formatter.string(fromByteCount: Int64(bytes))
  }
}

// ===== EXTENSION FOR BETTER ERROR HANDLING =====
extension SystemMonitor {
  
  static func getCpuUsageWithRetry(maxRetries: Int = 3) -> Double {
    for attempt in 1...maxRetries {
      let usage = getCpuUsage()
      if usage > 0 || attempt == maxRetries {
        return usage
      }
      // Pequena pausa entre tentativas
      usleep(10000) // 10ms
    }
    return 0.0
  }
  
  static func getMemoryInfoWithRetry(maxRetries: Int = 3) -> [String: Double] {
    for attempt in 1...maxRetries {
      let memInfo = getMemoryInfo()
      if (memInfo["usage"] ?? 0.0) > 0 || attempt == maxRetries {
        return memInfo
      }
      usleep(10000) // 10ms
    }
    return ["usage": 0.0, "totalGB": 0.0, "usedGB": 0.0]
  }
}