import Foundation
import OSAKit

/// Classe responsável por integrar com o Spotify no macOS
/// Utiliza AppleScript para comunicação com o aplicativo Spotify
class SpotifyHandler {
    
    private let spotifyBundleId = "com.spotify.client"
    
    /// Verifica se o Spotify está disponível e executando
    func isSpotifyAvailable() -> Bool {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        let isRunning = runningApps.contains { app in
            app.bundleIdentifier == spotifyBundleId
        }
        
        print("SpotifyHandler: Spotify está executando: \(isRunning)")
        return isRunning
    }
    
    /// Força a solicitação de permissões de automação
    func requestAutomationPermissions() -> Bool {
        print("SpotifyHandler: Solicitando permissões de automação...")
        
        // Script simples para forçar a solicitação de permissão
        let permissionScript = """
        tell application "Spotify"
            get name
        end tell
        """
        
        let result = executeAppleScript(permissionScript)
        print("SpotifyHandler: Resultado da solicitação de permissão: \(String(describing: result))")
        
        return result != nil
    }
    
    /// Testa conectividade básica com o Spotify
    func testSpotifyConnection() -> Bool {
        print("SpotifyHandler: Testando conexão com Spotify...")
        
        let simpleScript = """
        tell application "Spotify"
            get name
        end tell
        """
        
        let result = executeAppleScript(simpleScript)
        print("SpotifyHandler: Resultado do teste: \(String(describing: result))")
        return result != nil
    }
    
    /// Obtém o estado atual do player do Spotify
    func getCurrentState() -> [String: Any]? {
        print("SpotifyHandler: Verificando se Spotify está disponível...")
        guard isSpotifyAvailable() else {
            print("SpotifyHandler: Spotify não está disponível")
            return nil
        }
        
        // Primeiro, tenta solicitar permissões se necessário
        if !requestAutomationPermissions() {
            print("SpotifyHandler: Falha ao obter permissões de automação")
            return ["error": "Permissões de automação necessárias. Vá para System Preferences > Security & Privacy > Privacy > Automation e habilite o acesso ao Spotify para esta aplicação."]
        }
        
        print("SpotifyHandler: Spotify disponível, executando script...")
        let script = """
        tell application "Spotify"
            try
                set currentTrack to current track
                set trackName to name of currentTrack
                set trackArtist to artist of currentTrack
                set playerState to player state as string
                
                return {trackName:trackName, trackArtist:trackArtist, playerState:playerState}
            on error errorMsg
                return {error:errorMsg as string}
            end try
        end tell
        """
        
        let result = executeAppleScript(script)
        print("SpotifyHandler: Resultado do script: \(String(describing: result))")
        return result as? [String: Any]
    }
    
    /// Controles de reprodução
    func play() -> Bool {
        return executeSpotifyCommand("play")
    }
    
    func pause() -> Bool {
        return executeSpotifyCommand("pause")
    }
    
    func togglePlayPause() -> Bool {
        return executeSpotifyCommand("playpause")
    }
    
    func nextTrack() -> Bool {
        return executeSpotifyCommand("next track")
    }
    
    func previousTrack() -> Bool {
        return executeSpotifyCommand("previous track")
    }
    
    /// Controles de volume
    func setVolume(_ volume: Int) -> Bool {
        let script = """
        tell application "Spotify"
            set sound volume to \(volume)
        end tell
        """
        return executeAppleScript(script) != nil
    }
    
    func increaseVolume() -> Bool {
        let script = """
        tell application "Spotify"
            set currentVol to sound volume
            if currentVol < 100 then
                set sound volume to (currentVol + 10)
            end if
        end tell
        """
        return executeAppleScript(script) != nil
    }
    
    func decreaseVolume() -> Bool {
        let script = """
        tell application "Spotify"
            set currentVol to sound volume
            if currentVol > 0 then
                set sound volume to (currentVol - 10)
            end if
        end tell
        """
        return executeAppleScript(script) != nil
    }
    
    /// Controles de shuffle e repeat
    func toggleShuffle() -> Bool {
        let script = """
        tell application "Spotify"
            set shuffling to not shuffling
        end tell
        """
        return executeAppleScript(script) != nil
    }
    
    func toggleRepeat() -> Bool {
        let script = """
        tell application "Spotify"
            set repeating to not repeating
        end tell
        """
        return executeAppleScript(script) != nil
    }
    
    // MARK: - Helper Methods
    
    /// Executa um comando simples no Spotify
    private func executeSpotifyCommand(_ command: String) -> Bool {
        let script = """
        tell application "Spotify"
            \(command)
        end tell
        """
        return executeAppleScript(script) != nil
    }
    
    /// Executa um script AppleScript e retorna o resultado
    private func executeAppleScript(_ script: String) -> Any? {
        guard let language = OSALanguage(forName: "AppleScript") else {
            print("AppleScript Error: Failed to get AppleScript language")
            return nil
        }
        
        let appleScript = OSAScript(source: script, language: language)
        
        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript Error: \(error)")
            return nil
        }
        
        guard let descriptor = result else {
            return nil
        }
        
        // Simplificar - tentar extrair como string primeiro, depois como outros tipos
        if let stringValue = descriptor.stringValue {
            return stringValue
        }
        
        // Para valores numéricos
        if descriptor.descriptorType == typeSInt32 {
            return NSNumber(value: descriptor.int32Value)
        }
        
        if descriptor.descriptorType == typeIEEE64BitFloatingPoint {
            return NSNumber(value: descriptor.doubleValue)
        }
        
        if descriptor.descriptorType == typeBoolean {
            return NSNumber(value: descriptor.booleanValue)
        }
        
        // Se não conseguirmos converter, retornar nil
        return nil
    }
}

/// Extensão para converter dados do AppleScript para formato Flutter
extension SpotifyHandler {
    
    /// Converte o resultado do AppleScript para um dicionário compatível com Flutter
    func formatStateForFlutter(_ state: [String: Any]) -> [String: Any] {
        var formattedState: [String: Any] = [:]
        
        print("SpotifyHandler: Formatando estado para Flutter: \(state)")
        
        // Verificar se há erro
        if let error = state["error"] as? String {
            print("SpotifyHandler: Erro no script: \(error)")
            return ["error": error]
        }
        
        // Informações da track
        if let trackName = state["trackName"] as? String,
           let trackArtist = state["trackArtist"] as? String {
            
            let trackInfo: [String: Any] = [
                "id": "\(trackName)-\(trackArtist)", // ID sintético
                "name": trackName,
                "artist": trackArtist,
                "album": state["trackAlbum"] as? String ?? "Álbum Desconhecido",
                "duration": state["trackDuration"] ?? 180000, // 3 minutos default
                "position": state["trackPosition"] ?? 0
            ]
            
            formattedState["track"] = trackInfo
        }
        
        // Estado do player
        formattedState["playerState"] = state["playerState"] ?? "unknown"
        formattedState["shuffling"] = state["isShuffling"] ?? false
        formattedState["repeating"] = state["isRepeating"] ?? false
        formattedState["soundVolume"] = state["currentVolume"] ?? 50
        
        print("SpotifyHandler: Estado formatado: \(formattedState)")
        return formattedState
    }
} 