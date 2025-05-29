# Integração com Spotify para macOS

## Visão Geral

Esta implementação fornece uma integração completa com o Spotify no macOS, permitindo:

- ✅ Visualização da música atual (nome, artista, álbum)
- ✅ Exibição da capa do álbum (quando disponível)
- ✅ Controles de reprodução (play/pause, anterior/próximo)
- ✅ Controles de volume
- ✅ Controles de shuffle e repeat
- ✅ Barra de progresso da música
- ✅ Interface moderna e responsiva

## Arquitetura

A implementação segue os princípios SOLID e Clean Architecture:

### 1. Camada de Modelos (`models/`)

- `SpotifyTrack`: Representa uma faixa musical
- `SpotifyPlayerState`: Representa o estado completo do player

### 2. Camada de Serviços (`services/`)

- `SpotifyService`: Interface abstrata (Inversão de Dependência)
- `MacOSSpotifyService`: Implementação específica para macOS

### 3. Camada de Controle (`controllers/`)

- `SpotifyController`: Gerencia estado e lógica de negócio

### 4. Camada de Apresentação

- `PlayingDisplay`: Widget que exibe a interface do player

### 5. Camada Nativa (macOS)

- `SpotifyHandler.swift`: Integração com AppleScript
- `AppDelegate.swift`: MethodChannel Bridge

## Pré-requisitos

1. **macOS**: A integração funciona apenas no macOS
2. **Spotify Desktop**: O aplicativo Spotify deve estar instalado e executando
3. **Permissões**: O macOS pode solicitar permissões de acessibilidade

## Como Usar

### 1. Instalação das Dependências

```bash
flutter pub get
dart run build_runner build
```

### 2. Configuração no Código

```dart
import 'package:island/modules/playing/playing_display.dart';

// Use o widget em sua interface
PlayingDisplay()
```

### 3. Funcionamento

O widget `PlayingDisplay` automaticamente:

1. Verifica se o Spotify está disponível
2. Conecta-se ao Spotify via AppleScript
3. Monitora mudanças de estado a cada segundo
4. Atualiza a interface em tempo real

## Funcionalidades Disponíveis

### Informações Exibidas

- **Nome da música**
- **Artista**
- **Álbum**
- **Capa do álbum** (quando disponível)
- **Progresso da reprodução**
- **Duração total**

### Controles Disponíveis

- **Play/Pause**: Inicia ou pausa a reprodução
- **Anterior/Próximo**: Navega entre faixas
- **Shuffle**: Ativa/desativa reprodução aleatória
- **Repeat**: Ativa/desativa repetição
- **Volume**: Controle através de métodos programáticos

### Estados da Interface

#### 1. **Loading State**

Exibido durante a conexão inicial com o Spotify.

#### 2. **Error State**

Exibido quando:

- Spotify não está disponível
- Spotify não está executando
- Erro de comunicação

#### 3. **No Track State**

Exibido quando não há música tocando.

#### 4. **Player State**

Interface completa com música e controles.

## Tecnologias Utilizadas

### Flutter/Dart

- **MethodChannel**: Comunicação com código nativo
- **StreamBuilder**: Atualizações reativas da interface
- **ChangeNotifier**: Gerenciamento de estado

### macOS/Swift

- **AppleScript**: Integração com Spotify
- **OSAKit**: Execução de scripts AppleScript
- **NSWorkspace**: Verificação de aplicativos executando

### AppleScript Commands

```applescript
-- Obter estado atual
tell application "Spotify"
    set currentTrack to current track
    set trackName to name of currentTrack
    -- ... outros comandos
end tell

-- Controles básicos
tell application "Spotify"
    playpause
    next track
    previous track
end tell
```

## Tratamento de Erros

A implementação inclui tratamento robusto de erros:

1. **Verificação de disponibilidade** do Spotify
2. **Timeout handling** para comandos AppleScript
3. **Fallbacks** para dados indisponíveis
4. **Logging** para debug em modo desenvolvimento
5. **Interface de erro** amigável ao usuário

## Limitações Conhecidas

1. **Apenas macOS**: Funciona exclusivamente no macOS
2. **Spotify Desktop**: Requer o app desktop do Spotify
3. **Artwork**: URL da capa nem sempre está disponível
4. **Latência**: ~1 segundo de delay nas atualizações
5. **Permissões**: Pode requerer permissões de acessibilidade

## Extensibilidade

A arquitetura permite fácil extensão:

### Adicionar Nova Plataforma

```dart
class WindowsSpotifyService implements SpotifyService {
  // Implementação específica para Windows
}
```

### Adicionar Novos Controles

```dart
abstract class SpotifyService {
  Future<void> seekToPosition(Duration position);
  Future<void> setRepeatMode(RepeatMode mode);
}
```

### Personalizar Interface

```dart
class CustomPlayingDisplay extends StatelessWidget {
  // Interface personalizada usando SpotifyController
}
```

## Performance

- **Memory**: ~2MB adicional quando ativo
- **CPU**: Mínimo impacto (polling de 1Hz)
- **Battery**: Impacto negligível
- **Network**: Nenhum uso de rede

## Segurança

- **Sandbox**: Funciona dentro do sandbox do Flutter
- **Permissions**: Usa permissões padrão do macOS
- **Data Privacy**: Nenhum dado é enviado externamente
- **Local Only**: Toda comunicação é local

## Troubleshooting

### Spotify não detectado

1. Verifique se o Spotify está executando
2. Reinicie o aplicativo Spotify
3. Verifique permissões de acessibilidade

### Controles não funcionam

1. Atualize para versão mais recente do Spotify
2. Verifique se não há conflitos com outros apps
3. Reinicie a aplicação Flutter

### Interface não atualiza

1. Verifique conexão com o MethodChannel
2. Monitore logs de erro no console
3. Verifique se o polling está ativo

## Contribuição

Para contribuir com melhorias:

1. **Fork** do repositório
2. **Implemente** novas funcionalidades seguindo SOLID
3. **Teste** em diferentes versões do Spotify
4. **Documente** mudanças e limitações
5. **Submeta** Pull Request

## Licença

Esta implementação segue a licença do projeto principal.
