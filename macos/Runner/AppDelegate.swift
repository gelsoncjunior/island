import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  
  // Referência para o monitor de eventos globais
  private var globalEventMonitor: Any?
  private var keyboardChannel: FlutterMethodChannel?
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Aguardar um pouco para garantir que a janela esteja pronta
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.setupMethodChannels()
    }
  }
  
  // MARK: - Private Methods
  
  private func setupMethodChannels() {
    guard let mainFlutterWindow = NSApplication.shared.windows.first(where: { $0 is MainFlutterWindow }) as? MainFlutterWindow,
          let controller = mainFlutterWindow.contentViewController as? FlutterViewController else {
      print("❌ Erro: Não foi possível encontrar a janela Flutter")
      return
    }
    
    let systemMonitorChannel = FlutterMethodChannel(
      name: "com.example.island",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    // Manter referência do canal para eventos de teclado
    keyboardChannel = systemMonitorChannel
    
    systemMonitorChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handleMethodCall(call, result: result)
    }
    
    print("✅ Method channels configurados com sucesso")
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
    case "listenKeyboardEvents":
      listenKeyboardEvents(result: result)
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

  private func listenKeyboardEvents(result: @escaping FlutterResult) {
    print("🎹 Configurando listener de eventos de teclado...")
    
    // Verificar permissões de acessibilidade
    if !AXIsProcessTrusted() {
      print("⚠️ App não tem permissões de acessibilidade. Solicitando...")
      let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
      AXIsProcessTrustedWithOptions(options)
      result(["status": "permission_required", "message": "Permissões de acessibilidade necessárias"])
      return
    }
    
    // Remover monitor anterior se existir
    if let existingMonitor = globalEventMonitor {
      NSEvent.removeMonitor(existingMonitor)
      print("🔄 Monitor anterior removido")
    }
    
    // Configurar novo monitor global de eventos
    globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
      self?.handleGlobalKeyEvent(event)
    }
    
    // Também capturar eventos locais (dentro do app)
    NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
      self?.handleGlobalKeyEvent(event)
      return event // Retornar o evento para continuar o processamento normal
    }
    
    if globalEventMonitor != nil {
      print("✅ Monitor de eventos configurado com sucesso")
      result(["status": "success", "message": "Listener de teclado ativo"])
    } else {
      print("❌ Falha ao configurar monitor de eventos")
      result(["status": "error", "message": "Falha ao configurar listener"])
    }
  }
  
  private func handleGlobalKeyEvent(_ event: NSEvent) {
    // Cmd+C: keyCode 8 com modifier .command
    if event.modifierFlags.contains(.command) && event.keyCode == 8 {
      print("🎯 Cmd+C detectado!")
      
      // Aguardar um breve momento para garantir que o conteúdo seja copiado
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.handleCmdCWithClipboard()
      }
      return
    }
    
    // Cmd+V: keyCode 9 com modifier .command
    if event.modifierFlags.contains(.command) && event.keyCode == 9 {
      print("🎯 Cmd+V detectado!")
      notifyFlutterAboutKeyboardEvent("onCmdV", data: ["key": "cmd+v", "timestamp": Date().timeIntervalSince1970])
      return
    }
    
    // Log para debug (remover em produção)
    if event.modifierFlags.contains(.command) {
      print("🔍 Tecla detectada - KeyCode: \(event.keyCode), Modifiers: \(event.modifierFlags)")
    }
  }
  
  private func notifyFlutterAboutKeyboardEvent(_ eventName: String, data: [String: Any] = [:]) {
    guard let channel = keyboardChannel else {
      print("❌ Canal de teclado não disponível")
      return
    }
    
    print("📢 Enviando evento para Flutter: \(eventName)")
    channel.invokeMethod(eventName, arguments: data)
  }
  
  // MARK: - Clipboard Handling
  
  private func handleCmdCWithClipboard() {
    guard let clipboardContent = getClipboardStringContent() else {
      print("📋 Conteúdo da área de transferência não é uma string válida")
      notifyFlutterAboutKeyboardEvent("onCmdC", data: [
        "key": "cmd+c", 
        "timestamp": Date().timeIntervalSince1970,
        "hasValidString": false,
        "content": ""
      ])
      return
    }
    
    print("📋 Conteúdo copiado (string): \(clipboardContent.prefix(50))...")
    
    let eventData: [String: Any] = [
      "key": "cmd+c",
      "timestamp": Date().timeIntervalSince1970,
      "hasValidString": true,
      "content": clipboardContent,
      "contentLength": clipboardContent.count
    ]
    
    notifyFlutterAboutKeyboardEvent("onCmdC", data: eventData)
  }
  
  private func getClipboardStringContent() -> String? {
    let pasteboard = NSPasteboard.general
    
    // Verificar se existe conteúdo de string na área de transferência
    guard pasteboard.canReadItem(withDataConformingToTypes: [NSPasteboard.PasteboardType.string.rawValue]) else {
      print("📋 Área de transferência não contém string")
      return nil
    }
    
    // Tentar obter o conteúdo como string
    if let stringContent = pasteboard.string(forType: .string) {
      // Verificar se a string não está vazia e tem conteúdo válido
      let trimmedContent = stringContent.trimmingCharacters(in: .whitespacesAndNewlines)
      
      if !trimmedContent.isEmpty {
        return stringContent
      } else {
        print("📋 String da área de transferência está vazia")
        return nil
      }
    }
    
    print("📋 Falha ao obter string da área de transferência")
    return nil
  }
  
  // Cleanup quando o app terminar
  deinit {
    if let monitor = globalEventMonitor {
      NSEvent.removeMonitor(monitor)
    }
  }
}
