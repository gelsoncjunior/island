# 🏝️ Island - Dynamic Island para MacBook

Uma implementação elegante e funcional do Dynamic Island do iPhone para MacBook, desenvolvida em Flutter com foco em produtividade e experiência do usuário.

## 📸 Demonstração

### Estado Compacto

![Island - Estado Compacto](assets/readme/compacto.png)

### Estado Expandido

![Island - Estado Expandido](assets/readme/expandido.png)

## ⭐ O que é o Island?

O **Island** é uma aplicação que traz a experiência do Dynamic Island do iPhone para o MacBook, oferecendo uma interface compacta e intuitiva que se adapta dinamicamente às suas necessidades. Ele permanece sempre visível na tela, proporcionando acesso rápido a informações e funcionalidades essenciais.

## 🚀 Funcionalidades

### 1. 📊 Monitor de Sistema

- **Memória RAM**: Exibição em tempo real do uso de memória
- **CPU**: Monitoramento do processamento atual
- **Interface visual**: Gráficos e percentuais intuitivos

### 2. 📋 Bandeja de Arquivos (Clipboard Avançado)

- **Drag & Drop**: Arraste arquivos do Finder para armazenar temporariamente
- **Cópia inteligente**:
  - Toque simples → copia o caminho do arquivo
  - Pressionar e segurar → copia o arquivo real
- **Gestão de arquivos**: Remova itens individualmente ou limpe tudo
- **Feedback visual**: Animações e confirmações visuais

### 3. 📷 Espelho (Mini Câmera)

- **Câmera integrada**: Visualização da câmera do MacBook
- **Interface compacta**: Como um pequeno espelho digital
- **Sempre disponível**: Acesso rápido quando necessário

### 4. 📅 Calendário

- **Data atual**: Exibição da data de hoje
- **Interface limpa**: Design minimalista e informativo
- **Atualização automática**: Sempre sincronizado

### 5. 🎵 Player de Música (Spotify)

- **Controles completos**:
  - ⏮️ Voltar para música anterior
  - ⏯️ Play/Pause
  - ⏭️ Avançar para próxima música
- **Integração nativa**: Funciona diretamente com o Spotify
- **Interface familiar**: Controles intuitivos e responsivos

## 🏗️ Arquitetura

O projeto foi desenvolvido seguindo os **princípios SOLID** e práticas de **Código Limpo**, garantindo:

### Princípios SOLID Aplicados

#### Single Responsibility Principle (SRP)

- Cada módulo tem uma responsabilidade específica
- Separação clara entre UI, lógica de negócio e serviços

#### Open/Closed Principle (OCP)

- Módulos extensíveis sem modificação do código existente
- Interfaces bem definidas para futuras implementações

#### Liskov Substitution Principle (LSP)

- Componentes substituíveis sem afetar o funcionamento
- Hierarquia de classes bem estruturada

#### Interface Segregation Principle (ISP)

- Interfaces específicas para cada funcionalidade
- Dependências mínimas e bem definidas

#### Dependency Inversion Principle (DIP)

- Dependência de abstrações, não de implementações
- Inversão de controle bem implementada

### Estrutura de Módulos

```
lib/modules/
├── dynamic/          # Comportamento dinâmico do Island
├── static_monitor/   # Monitor de sistema (CPU/RAM)
├── copy/            # Bandeja de arquivos e clipboard
├── camera/          # Funcionalidade de espelho/câmera
├── playing/         # Player de música (Spotify)
├── cmd/             # Comandos e utilitários
└── home/            # Tela principal e navegação
```

## 🛠️ Tecnologias Utilizadas

- **Flutter** `^3.6.0` - Framework principal
- **Dart** - Linguagem de programação
- **window_manager** `^0.4.3` - Gerenciamento de janela
- **desktop_drop** `^0.4.4` - Funcionalidade drag & drop
- **super_clipboard** `^0.8.24` - Operações avançadas de clipboard
- **camera_macos** `^0.0.9` - Acesso à câmera no macOS
- **http** `^1.2.0` - Requisições de rede

## 📋 Pré-requisitos

- **macOS** (otimizado para macOS)
- **Flutter** 3.6.0 ou superior
- **Dart SDK** 3.6.0 ou superior
- **Spotify** instalado (para funcionalidade de música)

## 🚀 Instalação e Execução

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/island.git
cd island
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Execute o aplicativo

```bash
flutter run -d macos
```

## 🎯 Como Usar

### Inicialização

1. Execute o aplicativo
2. O Island aparecerá como uma pequena ilha na parte superior da tela
3. Clique para expandir e acessar todas as funcionalidades

### Navegação entre Módulos

- **Clique simples**: Expande/contrai o Island
- **Navegação lateral**: Use as setas ou gestos para alternar entre módulos
- **Estado persistente**: O Island lembra seu último estado

### Funcionalidades Específicas

#### 📊 Monitor de Sistema

- Visualize automaticamente o uso de CPU e memória
- Dados atualizados em tempo real

#### 📋 Bandeja de Arquivos

1. Arraste arquivos do Finder para o Island
2. Toque para copiar o caminho
3. Pressione e segure para copiar o arquivo
4. Use os botões para gerenciar a lista

#### 🎵 Spotify Player

1. Tenha o Spotify rodando
2. Use os controles do Island para navegar nas músicas
3. Controle play/pause diretamente

## 🔮 Roadmap

### Versão Atual (1.0.0)

- ✅ Todos os 5 módulos principais implementados
- ✅ Interface Dynamic Island
- ✅ Integração com Spotify

### Próximas Versões

- [ ] Suporte para Apple Music
- [ ] Personalização de temas
- [ ] Configurações avançadas
- [ ] Suporte para múltiplos monitores
- [ ] Atalhos de teclado customizáveis
- [ ] Widget de clima
- [ ] Notificações integradas

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Diretrizes de Contribuição

- Siga os princípios SOLID
- Mantenha o código limpo e bem documentado
- Adicione testes para novas funcionalidades
- Respeite a arquitetura existente

## 📝 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## 👨‍💻 Autor

Desenvolvido com ❤️ para trazer a experiência do Dynamic Island para o MacBook.

---

**Island** - Transformando a produtividade no macOS, uma ilha de cada vez. 🏝️
