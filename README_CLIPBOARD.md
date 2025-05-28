# 📋 Funcionalidade de Clipboard - Island

## 🎯 Visão Geral

A funcionalidade de clipboard do Island permite copiar arquivos para a área de transferência do sistema, possibilitando o uso do **CMD+V** (ou **Ctrl+V**) para colar os arquivos em qualquer aplicação do macOS.

## ✨ Funcionalidades

### 🔄 Cópia Individual de Arquivos

- **Long Press**: Mantenha pressionado qualquer card de arquivo para copiá-lo para o clipboard
- **Feedback Visual**: O card fica verde durante o long press, indicando que será copiado
- **Feedback Háptico**: Vibração confirma a ação

### 📚 Cópia de Todos os Arquivos

- **Botão "Copiar Todos"**: Clique no botão verde na barra de ações
- **Atalho de Teclado**: Use **CMD+C** (ou **Ctrl+C**) quando a área estiver em foco
- **Notificação**: Mensagem de sucesso mostra quantos arquivos foram copiados

### 🗑️ Limpeza

- **Botão "Limpar"**: Remove todos os arquivos da lista
- **Limpeza Automática**: Arquivos temporários são automaticamente removidos

## 🛠️ Como Funciona

### Arquitetura (Princípios SOLID)

1. **Single Responsibility Principle (SRP)**:

   - `ClipboardService`: Responsável apenas por operações de clipboard
   - `FileManagerService`: Gerencia apenas arquivos em memória
   - `DroppedFile`: Representa apenas dados de arquivo

2. **Open/Closed Principle (OCP)**:

   - Fácil extensão para outras plataformas (Windows, Linux)
   - Novos tipos de arquivo podem ser adicionados sem modificar código existente

3. **Dependency Inversion Principle (DIP)**:
   - Uso de interfaces (`IClipboardService`, `IFileManagerService`)
   - Baixo acoplamento entre componentes

### Fluxo de Funcionamento

1. **Carregamento de Arquivos**:

   ```dart
   DroppedFile.fromPath(filePath) // Carrega bytes automaticamente
   ```

2. **Cópia para Clipboard**:

   ```dart
   // Cria arquivos temporários com os bytes em memória
   // Usa AppleScript para copiar para clipboard do sistema
   await clipboardService.copyFilesToClipboard(files);
   ```

3. **Uso do CMD+V**:
   - Os arquivos ficam disponíveis no clipboard do sistema
   - Podem ser colados em Finder, aplicações, etc.

## 🎮 Como Usar

### Passo a Passo

1. **Adicionar Arquivos**:

   - Arraste arquivos para a área de drop
   - Ou clique na área vazia para selecionar

2. **Copiar Arquivo Individual**:

   - Mantenha pressionado o card do arquivo
   - Aguarde o feedback visual (verde) e háptico
   - Use CMD+V onde desejar colar

3. **Copiar Todos os Arquivos**:

   - Clique no botão "Copiar Todos" (verde)
   - Ou use CMD+C com a área em foco
   - Use CMD+V onde desejar colar

4. **Verificar Status**:
   - Mensagens de sucesso/erro aparecem automaticamente
   - Contador mostra quantos arquivos estão carregados

## 🔧 Detalhes Técnicos

### Dependências Utilizadas

```yaml
dependencies:
  desktop_drop: ^0.4.4 # Drag & drop de arquivos
  cross_file: ^0.3.4+2 # Manipulação de arquivos multiplataforma
  path: ^1.9.0 # Manipulação de caminhos
```

### Compatibilidade

- ✅ **macOS**: Totalmente suportado com AppleScript
- ⏳ **Windows**: Preparado para implementação futura
- ⏳ **Linux**: Preparado para implementação futura

### Limitações Atuais

- Funciona apenas no macOS
- Arquivos são carregados completamente na memória
- Arquivos temporários são criados durante a cópia

## 🧪 Como Testar a Funcionalidade

### Teste Rápido com Script

1. **Execute o script de teste**:

   ```bash
   ./test_clipboard.sh
   ```

2. **Verifique se o AppleScript funcionou**:
   - Abra o Finder
   - Navegue para qualquer pasta
   - Pressione **CMD+V**
   - O arquivo `test_island_clipboard.txt` deve aparecer

### Teste no Aplicativo

1. **Adicione arquivos**:

   - Arraste alguns arquivos para a área de drop do Island
   - Ou clique na área vazia para selecionar arquivos

2. **Teste cópia individual**:

   - Mantenha pressionado qualquer card de arquivo
   - Aguarde o feedback visual (verde) e háptico
   - Vá para uma pasta no Finder e pressione **CMD+V**

3. **Teste cópia múltipla**:
   - Clique no botão "Copiar Todos" (verde)
   - Ou pressione **CMD+C** com a área em foco
   - Vá para uma pasta no Finder e pressione **CMD+V**

### Verificação do Clipboard

Você pode verificar o conteúdo do clipboard com:

```bash
# Ver conteúdo textual do clipboard
pbpaste

# Ver tipos de dados no clipboard
osascript -e "clipboard info"
```

## 🐛 Solução de Problemas

### Problemas Comuns

1. **CMD+V não funciona**:

   - ✅ **Verifique se o arquivo foi copiado** (mensagem de sucesso deve aparecer)
   - ✅ **Execute o script de teste**: `./test_clipboard.sh`
   - ✅ **Verifique permissões do sistema**:
     - Sistema > Preferências > Segurança > Privacidade > Automação
     - Certifique-se de que o Terminal/Island tem permissão para controlar o Finder
   - ✅ **Tente reiniciar o aplicativo**

2. **Erro ao copiar arquivos grandes**:

   - ⚠️ Arquivos muito grandes podem causar problemas de memória
   - 💡 Tente copiar arquivos menores (< 100MB)
   - 🔄 Aguarde mais tempo para arquivos grandes

3. **AppleScript falha**:

   - 🔐 **Verifique permissões de automação no macOS**:
     - Sistema > Preferências > Segurança > Privacidade > Automação
     - Habilite permissões para o aplicativo controlar Finder e System Events
   - 🔄 **Tente executar o script de teste manualmente**
   - 🖥️ **Verifique se o Finder está respondendo**

4. **Mensagem "Nenhum conteúdo no clipboard"**:
   - 📋 **Verifique se a mensagem de sucesso apareceu**
   - 🔄 **Tente copiar novamente**
   - 🧪 **Execute o script de teste para verificar se o AppleScript funciona**
   - ⏱️ **Aguarde alguns segundos após a cópia antes de tentar colar**

### Logs de Debug

O sistema imprime logs úteis no console do Flutter:

```
✅ 3 arquivo(s) copiados para o clipboard do sistema via AppleScript
✅ Arquivo copiado com sucesso
❌ Falha no AppleScript: [erro detalhado]
❌ Método alternativo falhou: [erro]
```

Para ver os logs:

```bash
# Se executando via Flutter
flutter run --verbose

# Ou verifique o console do sistema
Console.app > Filtrar por "Island" ou "osascript"
```

### Permissões do macOS

Se o CMD+V não funcionar, verifique as permissões:

1. **Abra Preferências do Sistema**
2. **Vá para Segurança e Privacidade**
3. **Clique na aba Privacidade**
4. **Selecione "Automação" na lista lateral**
5. **Certifique-se de que seu aplicativo tem permissão para**:
   - ✅ Finder
   - ✅ System Events
6. **Se necessário, adicione manualmente o aplicativo**

### Teste Manual do AppleScript

Execute este comando no Terminal para testar manualmente:

```bash
# Cria arquivo de teste
echo "teste" > /tmp/teste.txt

# Testa AppleScript
osascript -e 'tell application "Finder" to set the clipboard to {POSIX file "/tmp/teste.txt" as alias}'

# Verifica se funcionou - vá para uma pasta e pressione CMD+V
```

## 🚀 Melhorias Futuras

- [ ] Suporte para Windows e Linux
- [ ] Cópia de arquivos grandes sem carregar na memória
- [ ] Preview de arquivos antes da cópia
- [ ] Histórico de arquivos copiados
- [ ] Cópia de pastas inteiras

## 📝 Exemplo de Uso

```dart
// Copiar arquivo individual
final fileManager = FileManagerService();
await fileManager.copyFileToClipboard(droppedFile);

// Copiar todos os arquivos
await fileManager.copyAllFilesToClipboard();

// Verificar se há arquivos no clipboard
if (fileManager.hasFilesInClipboard) {
  print('${fileManager.clipboardFiles.length} arquivos no clipboard');
}
```

---

**Desenvolvido seguindo os princípios de Clean Code e SOLID** 🏗️
