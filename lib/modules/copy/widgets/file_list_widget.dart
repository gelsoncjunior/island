import 'package:flutter/material.dart';
import '../models/dropped_file.dart';
import '../services/file_manager_service.dart';

/// Widget responsável por exibir a lista de arquivos
/// Segue o princípio SRP - responsável apenas por exibir a lista
class FileListWidget extends StatelessWidget {
  final IFileManagerService fileManager;

  const FileListWidget({
    super.key,
    required this.fileManager,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DroppedFile>>(
      stream: fileManager.filesStream,
      initialData: fileManager.files,
      builder: (context, snapshot) {
        final files = snapshot.data ?? [];

        if (files.isEmpty) {
          return const _EmptyStateWidget();
        }

        return Expanded(
          child: ListView.separated(
            itemCount: files.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final file = files[index];
              return _FileItemWidget(
                file: file,
                onDelete: () => fileManager.removeFile(file),
              );
            },
          ),
        );
      },
    );
  }
}

/// Widget para exibir estado vazio
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nenhum arquivo adicionado',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Widget para exibir um item de arquivo individual
class _FileItemWidget extends StatelessWidget {
  final DroppedFile file;
  final VoidCallback onDelete;

  const _FileItemWidget({
    required this.file,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[700]!, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FileIconWidget(extension: file.extension),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  file.fileType,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.close,
              color: Colors.white54,
              size: 14,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
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
      size: 16,
    );
  }
}
