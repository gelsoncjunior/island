import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:typed_data';

/// Modelo que representa um arquivo arrastado para a área de drop
/// Segue o princípio SRP - responsável apenas por representar dados do arquivo
/// Agora inclui o conteúdo do arquivo em bytes para clipboard
class DroppedFile {
  final String name;
  final String fullPath;
  final String extension;
  final DateTime droppedAt;
  final int sizeInBytes;
  final Uint8List? fileBytes; // Conteúdo do arquivo em bytes
  final bool isLoadedInMemory; // Indica se os bytes foram carregados

  DroppedFile({
    required this.name,
    required this.fullPath,
    required this.extension,
    required this.droppedAt,
    required this.sizeInBytes,
    this.fileBytes,
    this.isLoadedInMemory = false,
  });

  /// Factory constructor para criar a partir de um caminho de arquivo
  /// Carrega automaticamente o conteúdo em bytes
  static Future<DroppedFile> fromPath(String filePath) async {
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(filePath);

    try {
      final file = File(filePath);
      final exists = await file.exists();

      if (!exists) {
        return DroppedFile(
          name: fileName,
          fullPath: filePath,
          extension: fileExtension,
          droppedAt: DateTime.now(),
          sizeInBytes: 0,
          isLoadedInMemory: false,
        );
      }

      final stat = await file.stat();
      final bytes = await file.readAsBytes();

      return DroppedFile(
        name: fileName,
        fullPath: filePath,
        extension: fileExtension,
        droppedAt: DateTime.now(),
        sizeInBytes: stat.size,
        fileBytes: bytes,
        isLoadedInMemory: true,
      );
    } catch (e) {
      // Em caso de erro, retorna sem os bytes
      return DroppedFile(
        name: fileName,
        fullPath: filePath,
        extension: fileExtension,
        droppedAt: DateTime.now(),
        sizeInBytes: 0,
        isLoadedInMemory: false,
      );
    }
  }

  /// Factory constructor síncrono para compatibilidade (sem bytes)
  factory DroppedFile.fromPathSync(String filePath) {
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(filePath);

    return DroppedFile(
      name: fileName,
      fullPath: filePath,
      extension: fileExtension,
      droppedAt: DateTime.now(),
      sizeInBytes: 0,
      isLoadedInMemory: false,
    );
  }

  /// Cria uma cópia do arquivo com bytes carregados
  Future<DroppedFile> loadBytes() async {
    if (isLoadedInMemory && fileBytes != null) {
      return this; // Já carregado
    }

    try {
      final file = File(fullPath);
      final exists = await file.exists();

      if (!exists) {
        return this; // Retorna sem modificar se arquivo não existe
      }

      final stat = await file.stat();
      final bytes = await file.readAsBytes();

      return DroppedFile(
        name: name,
        fullPath: fullPath,
        extension: extension,
        droppedAt: droppedAt,
        sizeInBytes: stat.size,
        fileBytes: bytes,
        isLoadedInMemory: true,
      );
    } catch (e) {
      return this; // Retorna sem modificar em caso de erro
    }
  }

  /// Retorna o tipo de arquivo baseado na extensão
  String get fileType {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
        return 'Imagem';
      case '.pdf':
        return 'PDF';
      case '.doc':
      case '.docx':
        return 'Documento';
      case '.txt':
        return 'Texto';
      case '.mp4':
      case '.avi':
      case '.mov':
        return 'Vídeo';
      case '.mp3':
      case '.wav':
      case '.flac':
        return 'Áudio';
      default:
        return 'Arquivo';
    }
  }

  /// Retorna o tamanho formatado
  String get formattedSize {
    final size =
        isLoadedInMemory && fileBytes != null ? fileBytes!.length : sizeInBytes;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Indica se o arquivo está disponível para cópia
  bool get isAvailableForCopy => isLoadedInMemory && fileBytes != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DroppedFile &&
          runtimeType == other.runtimeType &&
          fullPath == other.fullPath;

  @override
  int get hashCode => fullPath.hashCode;
}
