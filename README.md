# Island - App Flutter com Drag & Drop

Um aplicativo Flutter para macOS que implementa funcionalidade completa de Drag & Drop para gerenciamento de arquivos.

## Funcionalidades

### 🎯 Drag & Drop de Arquivos

- **Arrastar para dentro**: Arraste arquivos do Finder para o app
- **Cards horizontais**: Visualização em cards lado a lado com scroll
- **Feedback visual**: Bordas picotadas e animações durante o drag
- **Suporte contínuo**: Adicione mais arquivos mesmo quando já há arquivos na lista

### 📋 Cópia de Arquivos

- **Toque simples**: Toque no card para copiar o **caminho** do arquivo
- **Pressionar e segurar**: Mantenha pressionado para copiar o **arquivo real** para área de transferência
- **Feedback visual**: Card fica verde durante o long press, confirmação via SnackBar
- **Feedback háptico**: Vibração ao iniciar e completar a cópia
- **Tooltip informativo**: Instruções de uso ao passar o mouse

### 🗂️ Gerenciamento

- **Lista sequencial**: Arquivos organizados por ordem de adição
- **Exclusão individual**: Botão X em cada card para remover
- **Limpar tudo**: Opção para remover todos os arquivos
- **Contador**: Mostra quantos arquivos foram adicionados

## Arquitetura

### Princípios SOLID Aplicados

#### Single Responsibility Principle (SRP)

- `DroppedFile`: Responsável apenas por representar dados do arquivo
- `FileManagerService`: Gerencia apenas operações com arquivos
- `FileGridWidget`: Exibe apenas a lista de cards
- `DashedBorderPainter`: Desenha apenas bordas picotadas

#### Open/Closed Principle (OCP)

- Interface `IFileManagerService` permite extensão sem modificação
- Widgets podem ser estendidos sem alterar código existente

#### Dependency Inversion Principle (DIP)

- `FileGridWidget` depende da abstração `IFileManagerService`
- Não há dependência direta de implementações concretas

### Estrutura de Arquivos

```
lib/modules/copy/
├── copy_display.dart           # Widget principal
├── models/
│   └── dropped_file.dart       # Modelo de dados (SRP)
├── services/
│   └── file_manager_service.dart # Gerenciamento de arquivos (SRP)
└── widgets/
    ├── file_grid_widget.dart   # Grid de cards (SRP)
    └── dashed_border_painter.dart # Bordas customizadas (SRP)
```

## Como Usar

### 1. Adicionar Arquivos

- Arraste arquivos do Finder para a área de drop
- Ou arraste para a área mesmo quando já há arquivos

### 2. Copiar Arquivos

- **Método 1 (Caminho)**: Toque no card do arquivo → copia o caminho
- **Método 2 (Arquivo Real)**: Mantenha pressionado o card → copia o arquivo

### 3. Usar Arquivos Copiados

- **Caminho copiado**: Cole em terminal, editor de texto, etc.
- **Arquivo copiado**: Use Cmd+V para colar o arquivo em qualquer pasta do Finder

### 4. Gerenciar Lista

- Clique no X vermelho para remover um arquivo
- Clique em "Limpar tudo" para remover todos

## Dependências

```yaml
dependencies:
  desktop_drop: ^0.4.4 # Drag & drop nativo
  path: ^1.9.0 # Manipulação de caminhos
```

## Limitações Conhecidas

1. **Drag-out nativo**: Não é possível arrastar cards diretamente para aplicações externas devido a limitações do `desktop_drop`
2. **Solução alternativa**: Use a funcionalidade de cópia (toque ou drag) e cole onde necessário
3. **Plataforma**: Atualmente otimizado para macOS

## Melhorias Futuras

- [ ] Suporte para Windows e Linux
- [ ] Drag-out nativo quando bibliotecas permitirem
- [ ] Preview de imagens nos cards
- [ ] Filtros por tipo de arquivo
- [ ] Histórico de arquivos

## Tecnologias

- **Flutter**: Framework principal
- **Dart**: Linguagem de programação
- **desktop_drop**: Plugin para drag & drop
- **Princípios SOLID**: Arquitetura limpa e mantível

# island
