import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../../constrains.dart';
import '../copy/widgets/dashed_border_painter.dart';

class CopyString extends StatefulWidget {
  final VoidCallback? onTap;
  const CopyString({super.key, this.onTap});

  @override
  State<CopyString> createState() => _CopyStringState();
}

class _CopyStringState extends State<CopyString> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.copy_rounded,
            color: Colors.deepOrange,
            size: 18,
          ),
          SizedBox(width: 5),
          Text(
            'Copy',
            style: TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
      ),
    );
  }
}

class CopyStringDisplay extends StatefulWidget {
  const CopyStringDisplay({super.key});

  @override
  State<CopyStringDisplay> createState() => _CopyStringDisplayState();
}

class _CopyStringDisplayState extends State<CopyStringDisplay> {
  static const platform = MethodChannel('com.example.island');
  final ScrollController _scrollController = ScrollController();

  // Constantes para configuração do histórico
  static const int _maxDisplayCharacters = 15;
  static const int _maxHistoryItems = 20;
  static const String _storageKey = 'copy_history';

  final List<String> _copiedContent = [];

  @override
  void initState() {
    super.initState();
    _loadCopyHistory();
    _setupKeyboardListener();
    _listenKeyboardEvents();
  }

  /// Carrega o histórico de cópias do armazenamento local
  /// Princípio SRP: responsabilidade única de carregar dados
  Future<void> _loadCopyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedHistory = prefs.getStringList(_storageKey);

      if (savedHistory != null) {
        setState(() {
          _copiedContent.clear();
          _copiedContent.addAll(savedHistory);
        });
      } else {}
    } catch (e) {
      debugPrint('❌ Erro ao carregar histórico: $e');
    }
  }

  /// Salva o histórico de cópias no armazenamento local
  /// Princípio SRP: responsabilidade única de salvar dados
  Future<void> _saveCopyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _copiedContent);
    } catch (e) {
      debugPrint('❌ Erro ao salvar histórico: $e');
    }
  }

  /// Adiciona nova cópia ao histórico respeitando o limite FIFO
  /// Princípio SRP: responsabilidade única de gerenciar adição com limite
  Future<void> _addCopyToHistory(String content) async {
    final trimmedContent = content.trim();

    // Evita duplicatas consecutivas
    if (_copiedContent.isNotEmpty && _copiedContent.last == trimmedContent) {
      return;
    }

    // Atualiza a lista diretamente primeiro (funciona mesmo quando app não está em foco)
    _copiedContent.add(trimmedContent);

    // Remove itens mais antigos se ultrapassar o limite (FIFO)
    while (_copiedContent.length > _maxHistoryItems) {
      _copiedContent.removeAt(0);
    }

    // Salva primeiro para garantir persistência
    await _saveCopyHistory();

    // Atualiza UI apenas se o widget ainda estiver montado
    if (mounted) {
      setState(() {
        // Lista já foi atualizada acima, apenas notifica a UI
      });
    }
  }

  /// Função helper para limitar string a um número máximo de caracteres
  /// seguindo o princípio SRP (Single Responsibility Principle)
  String _limitStringLength(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength);
  }

  /// Abre nova tela para exibir conteúdo completo
  /// Princípio SRP: responsabilidade única de gerenciar navegação para nova tela
  void _openContentWindow(String content) {
    // Navega para nova tela otimizada para desktop
    windowManager.setSize(Size(600, 600));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContentViewerWindow(content: content),
      ),
    );
  }

  void _setupKeyboardListener() {
    // Configurar listener para receber eventos do macOS
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onCmdC':
          await _handleCmdCEvent(call.arguments);
          break;
        case 'onCmdV':
          _handleCmdVEvent(call.arguments);
          break;
        default:
      }
    });
  }

  Future<void> _handleCmdCEvent(dynamic arguments) async {
    final content = arguments['content']?.toString() ?? '';
    if (content.isNotEmpty) {
      await _addCopyToHistory(content);
    }
  }

  void _handleCmdVEvent(dynamic arguments) {
    _onCmdVPressed();
  }

  void _onCmdVPressed() {}

  Future<void> _listenKeyboardEvents() async {
    try {
      final result = await platform.invokeMethod('listenKeyboardEvents');

      if (result != null && result['status'] == 'permission_required') {
        // Mostrar mensagem sobre permissões
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '⚠️ Permissões de acessibilidade necessárias para detectar eventos de teclado'),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erro ao configurar listener de teclado: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashedBorderContainer(
      child: Container(
        width: double.infinity,
        height: 100,
        padding: EdgeInsets.all(10),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
            scrollbars: true,
          ),
          child: Scrollbar(
            thumbVisibility: _copiedContent.length > 4,
            controller: _scrollController,
            child: ListView.separated(
              controller: _scrollController,
              separatorBuilder: (_, __) => SizedBox(width: 10),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _copiedContent.length,
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () =>
                      _openContentWindow(_copiedContent.reversed.toList()[i]),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_document,
                            size: 28, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          _limitStringLength(
                              _copiedContent.reversed.toList()[i].trim(),
                              _maxDisplayCharacters),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para exibir conteúdo completo em nova tela
/// Princípio SRP: responsabilidade única de exibir conteúdo detalhado
class ContentViewerWindow extends StatefulWidget {
  final String content;

  const ContentViewerWindow({super.key, required this.content});

  @override
  State<ContentViewerWindow> createState() => _ContentViewerWindowState();
}

class _ContentViewerWindowState extends State<ContentViewerWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () {
                      windowManager.setSize(Size(widthMax, heightMax));
                      Navigator.of(context).pop();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.white, size: 16),
                    onPressed: () => _copyToClipboard(),
                    tooltip: 'Copiar novamente',
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Caracteres: ${widget.content.length}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.text_fields, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Linhas: ${widget.content.split('\n').length}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Copia o conteúdo para a área de transferência
  /// Princípio SRP: responsabilidade única de copiar texto
  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.content));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Conteúdo copiado para área de transferência'),
            backgroundColor: Colors.green.shade700,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao copiar: $e'),
            backgroundColor: Colors.red.shade700,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
