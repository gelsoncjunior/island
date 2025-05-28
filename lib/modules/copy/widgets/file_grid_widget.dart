import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../models/dropped_file.dart';
import '../services/file_manager_service.dart';

/// Widget responsável por exibir arquivos como cards em grid horizontal
/// Segue o princípio SRP - responsável apenas por exibir cards de arquivos
class FileGridWidget extends StatefulWidget {
  final IFileManagerService fileManager;

  const FileGridWidget({
    super.key,
    required this.fileManager,
  });

  @override
  State<FileGridWidget> createState() => _FileGridWidgetState();
}

class _FileGridWidgetState extends State<FileGridWidget> {
  final ScrollController _scrollController = ScrollController();
  int _previousFileCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DroppedFile>>(
      stream: widget.fileManager.filesStream,
      initialData: widget.fileManager.files,
      builder: (context, snapshot) {
        final files = snapshot.data ?? [];

        // Auto-scroll quando novos arquivos são adicionados
        if (files.length > _previousFileCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToEnd();
          });
        }
        _previousFileCount = files.length;

        if (files.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // Grid de arquivos
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                  scrollbars: true,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: files.length > 4,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        ...files.map((file) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FileCardWidget(
                                file: file,
                                onDelete: () =>
                                    widget.fileManager.removeFile(file),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget para exibir um card de arquivo individual
class _FileCardWidget extends StatefulWidget {
  final DroppedFile file;
  final VoidCallback onDelete;

  const _FileCardWidget({
    required this.file,
    required this.onDelete,
  });

  @override
  State<_FileCardWidget> createState() => _FileCardWidgetState();
}

class _FileCardWidgetState extends State<_FileCardWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () => _copyFileToClipboard(context),
      child: _buildCardContent(isPressed: _isPressed),
    );
  }

  /// Copia o arquivo para o clipboard do sistema
  Future<void> _copyFileToClipboard(BuildContext context) async {
    try {
      HapticFeedback.mediumImpact();

      final fileManager = FileManagerService();
      final success = await fileManager.copyFileToClipboard(widget.file);

      if (mounted && context.mounted) {
        if (success) {
          _showSuccessMessage(
              context, '✅ ${widget.file.name} copiado! Use CMD+V para colar.');
        } else {
          _showErrorMessage(context, '❌ Erro ao copiar: ${widget.file.name}');
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        _showErrorMessage(context, '❌ Erro ao copiar: ${widget.file.name}');
      }
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.file_copy,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildCardContent({required bool isPressed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isPressed ? Colors.blue[800] : Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPressed ? Colors.blue : Colors.grey[700]!,
          width: isPressed ? 2.0 : 0.5,
        ),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Conteúdo principal do card
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FileIconWidget(extension: widget.file.extension),
                const SizedBox(height: 4),
                Text(
                  widget.file.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Botão de deletar no canto superior direito
          if (!isPressed)
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),
          // Ícone de cópia quando está sendo pressionado
          if (isPressed)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.file_copy,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para exibir ícone do arquivo baseado na extensão
class _FileIconWidget extends StatelessWidget {
  final String extension;

  const _FileIconWidget({required this.extension});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case '.txt':
        iconData = Icons.text_snippet;
        iconColor = Colors.grey;
        break;
      case '.mp4':
      case '.avi':
      case '.mov':
        iconData = Icons.video_file;
        iconColor = Colors.purple;
        break;
      case '.mp3':
      case '.wav':
      case '.flac':
        iconData = Icons.audio_file;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.white54;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }
}
