import Foundation
import Darwin
import Darwin.Mach

class SystemMonitor {
  
  // MARK: - CPU Usage
  
  static func getCpuUsage() -> Double {
    // Implementação usando host_processor_info com tipos mais seguros
    var cpuLoadInfo: host_cpu_load_info = host_cpu_load_info()
    var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride)
    
    let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
      }
    }
    
    guard result == KERN_SUCCESS else {
      print("Erro ao obter informações de CPU: \(result)")
      return 0.0
    }
    
    // Calcula o uso da CPU baseado nos ticks
    let userTicks = Double(cpuLoadInfo.cpu_ticks.0)  // USER
    let systemTicks = Double(cpuLoadInfo.cpu_ticks.1) // SYSTEM
    let idleTicks = Double(cpuLoadInfo.cpu_ticks.2)   // IDLE
    let niceTicks = Double(cpuLoadInfo.cpu_ticks.3)   // NICE
    
    let totalTicks = userTicks + systemTicks + idleTicks + niceTicks
    
    if totalTicks > 0 {
      let activeTicks = userTicks + systemTicks + niceTicks
      let cpuUsage = (activeTicks / totalTicks) * 100.0
      return min(max(cpuUsage, 0.0), 100.0)
    }
    
    return 0.0
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
    
    // Calcula as páginas de memória (removendo variáveis não utilizadas)
    let activePages = UInt64(vmStats.active_count)
    let inactivePages = UInt64(vmStats.inactive_count)
    let wiredPages = UInt64(vmStats.wire_count)
    let compressedPages = UInt64(vmStats.compressor_page_count)
    
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

// MARK: - Extensions for Better Error Handling
extension SystemMonitor {
  
  static func getCpuUsageWithRetry(maxRetries: Int = 3) -> Double {
    for attempt in 1...maxRetries {
      let usage = getCpuUsage()
      // Se obtivemos um valor válido (incluindo 0%), retornamos
      if usage >= 0.0 || attempt == maxRetries {
        return usage
      }
      // Pequena pausa entre tentativas apenas se houver erro
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