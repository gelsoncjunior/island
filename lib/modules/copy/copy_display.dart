import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'models/dropped_file.dart';
import 'services/file_manager_service.dart';
import 'widgets/file_grid_widget.dart';
import 'widgets/dashed_border_painter.dart';

class CopyDisplay extends StatelessWidget {
  final VoidCallback onTap;

  const CopyDisplay({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.inbox_rounded,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 5),
          Text(
            'Tray',
            style: TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
      ),
    );
  }
}

/// Widget principal para exibir a área de drag & drop e cards de arquivos
/// Segue os princípios SOLID - SRP, OCP, DIP
class CopyDisplayContent extends StatefulWidget {
  const CopyDisplayContent({super.key});

  @override
  State<CopyDisplayContent> createState() => _CopyDisplayContentState();
}

class _CopyDisplayContentState extends State<CopyDisplayContent> {
  final IFileManagerService _fileManager = FileManagerService();
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DroppedFile>>(
      stream: _fileManager.filesStream,
      initialData: _fileManager.files,
      builder: (context, snapshot) {
        final files = snapshot.data ?? [];
        final hasFiles = files.isNotEmpty;

        // Envolver toda a área com DropTarget para permitir drag contínuo
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DropTarget(
            onDragDone: _onDragDone,
            onDragEntered: _onDragEntered,
            onDragExited: _onDragExited,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: _isDragging
                    ? Border.all(color: Colors.grey, width: 2)
                    : null,
              ),
              child: hasFiles
                  ? SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: DashedBorderContainer(
                        borderColor: _isDragging ? Colors.grey : Colors.grey,
                        dashLength: 6.0,
                        gapLength: 4.0,
                        borderRadius: BorderRadius.circular(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            children: [
                              Expanded(
                                child:
                                    FileGridWidget(fileManager: _fileManager),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _buildEmptyDropArea(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDropArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DashedBorderContainer(
        borderColor: _isDragging ? Colors.grey : Colors.grey,
        dashLength: 6.0,
        gapLength: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: _buildDropAreaContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDropAreaContent() {
    if (_isDragging) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_download,
            color: Colors.grey,
            size: 32,
          ),
          Text(
            'Solte os arquivos aqui',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          color: Colors.white54,
          size: 32,
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            'Arraste arquivos aqui e clique em um arquivo para copiá-lo',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Não dispose do singleton, apenas limpe se necessário
    super.dispose();
  }

  void _onDragDone(DropDoneDetails details) {
    setState(() {
      _isDragging = false;
    });

    // Processa os arquivos de forma assíncrona
    _processDroppedFiles(details.files);
  }

  /// Processa arquivos arrastados de forma assíncrona
  Future<void> _processDroppedFiles(List<XFile> files) async {
    for (final file in files) {
      try {
        await _fileManager.addFileFromPath(file.path);
      } catch (e) {
        // Em caso de erro, tenta adicionar de forma síncrona como fallback
        final fallbackFile = DroppedFile.fromPathSync(file.path);
        await _fileManager.addFile(fallbackFile);
      }
    }
  }

  void _onDragEntered(DropEventDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragExited(DropEventDetails details) {
    setState(() {
      _isDragging = false;
    });
  }
}
