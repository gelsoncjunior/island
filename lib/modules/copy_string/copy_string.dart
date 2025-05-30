import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_document, size: 28, color: Colors.white),
                    Text(
                      _limitStringLength(
                          _copiedContent[i].trim(), _maxDisplayCharacters),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
