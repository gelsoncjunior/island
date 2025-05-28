import Cocoa
import FlutterMacOS
import window_manager

class MainFlutterWindow: NSPanel {

  private var isPositioned = false

  override func awakeFromNib() {
    super.awakeFromNib()
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    flutterViewController.backgroundColor = .clear

    self.setFrame(windowFrame, display: true)

    setupWindow()
    positionAtNotch()

    RegisterGeneratedPlugins(registry: flutterViewController)
    
  }

  private func setupWindow() {
        // Configurações básicas
        self.isOpaque = false
        self.hasShadow = true
        self.isMovableByWindowBackground = false
        
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
        self.isFloatingPanel = true

        // Level - usar o mais alto possível
        self.level = .popUpMenu + 1 //NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)) + 1)
        
        // Comportamentos críticos para manter na posição
        self.collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .fullScreenAuxiliary,
            .ignoresCycle,
            .fullScreenDisallowsTiling // Adicional para evitar reposicionamento
        ]
        
        // Configurações do NSPanel específicas
        self.hidesOnDeactivate = false
        self.becomesKeyOnlyIfNeeded = false
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

    }

  private func positionAtNotch() {
        guard let screen = NSScreen.main else { return }
        
        // Obter o frame da tela principal
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        
        // Calcular a posição do notch (centro superior da tela)
        let notchWidth: CGFloat = 200 // Ajuste conforme seu design
        let notchHeight: CGFloat = 32 // Ajuste conforme seu design
        
        let notchX = screenFrame.midX - (notchWidth / 2)
        let notchY = screenFrame.maxY - notchHeight
        
        let windowFrame = NSRect(x: notchX, y: notchY, width: notchWidth, height: notchHeight)
        
        self.setFrame(windowFrame, display: true)

        // Usar animator para posicionamento suave e mais confiável
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.0 // Sem animação
            self.animator().setFrame(windowFrame, display: true)
        })

        isPositioned = true
    }

    // Override para interceptar tentativas de reposicionamento
    override func setFrame(_ frameRect: NSRect, display displayFlag: Bool) {
        if isPositioned {
            // Se já foi posicionado, manter na posição do notch
            guard let screen = NSScreen.main else {
                super.setFrame(frameRect, display: displayFlag)
                return
            }
            
            let screenFrame = screen.frame
            let targetX = screenFrame.midX - (frameRect.width / 2)
            let targetY = screenFrame.maxY - frameRect.height + 10
            
            let correctedFrame = NSRect(x: targetX, y: targetY, width: frameRect.width, height: frameRect.height)
            super.setFrame(correctedFrame, display: displayFlag)
        } else {
            super.setFrame(frameRect, display: displayFlag)
        }
    }

    // Interceptar mudanças de origem
    override func setFrameOrigin(_ point: NSPoint) {
        if isPositioned {
            // Ignorar tentativas de mudar a origem se já está posicionado
            return
        }
        super.setFrameOrigin(point)
    }

    @objc private func screenDidChange() {
        // Reposicionar quando a tela mudar
        positionAtNotch()
    }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        if isPositioned {
            return frameRect // Não deixar o sistema alterar a posição
        }
        return super.constrainFrameRect(frameRect, to: screen)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


}

// Extensão para configurações adicionais se necessário
extension MainFlutterWindow {
    
    func lockPosition() {
        // Método para "travar" completamente a posição
        self.isMovable = false
        self.isMovableByWindowBackground = false
    }
    
    func forceRepositionToNotch() {
        // Método para forçar reposicionamento (útil para debug)
        isPositioned = false
        positionAtNotch()
    }
}