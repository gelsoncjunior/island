import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:super_clipboard/super_clipboard.dart';
import '../models/dropped_file.dart';

/// Interface para o serviço de clipboard
/// Segue o princípio DIP - dependência de abstração
abstract class IClipboardService {
  Future<bool> copyFileToClipboard(DroppedFile file);
  Future<bool> copyFilesToClipboard(List<DroppedFile> files);
  Future<bool> pasteFilesToDirectory(String targetDirectory);
  bool get hasFilesInClipboard;
  List<DroppedFile> get clipboardFiles;
  void clearClipboard();
}

/// Implementação moderna do serviço de clipboard usando super_clipboard
/// Segue os princípios SOLID - SRP, OCP, DIP
class ModernClipboardService implements IClipboardService {
  static final ModernClipboardService _instance =
      ModernClipboardService._internal();
  factory ModernClipboardService() => _instance;
  ModernClipboardService._internal();

  final List<DroppedFile> _clipboardFiles = [];
  String? _tempDirPath;

  @override
  List<DroppedFile> get clipboardFiles => List.unmodifiable(_clipboardFiles);

  @override
  bool get hasFilesInClipboard => _clipboardFiles.isNotEmpty;

  @override
  Future<bool> copyFileToClipboard(DroppedFile file) async {
    return copyFilesToClipboard([file]);
  }

  @override
  Future<bool> copyFilesToClipboard(List<DroppedFile> files) async {
    try {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        debugPrint('❌ Clipboard não disponível nesta plataforma');
        return false;
      }

      // Limpa o clipboard atual
      _clipboardFiles.clear();
      await _cleanupTempFiles();

      // Cria arquivos temporários se necessário
      final tempFiles = <String>[];
      for (final file in files) {
        String filePath;

        if (file.isLoadedInMemory && file.fileBytes != null) {
          // Cria arquivo temporário para arquivos em memória
          final tempFile = await _createTempFile(file);
          if (tempFile != null) {
            filePath = tempFile.path;
            tempFiles.add(filePath);
          } else {
            continue;
          }
        } else {
          // Usa o arquivo original se existe
          filePath = file.fullPath;
          if (!await File(filePath).exists()) {
            debugPrint('❌ Arquivo não encontrado: $filePath');
            continue;
          }
        }

        // Adiciona ao clipboard interno
        _clipboardFiles.add(file);
      }

      if (_clipboardFiles.isEmpty) {
        return false;
      }

      // Copia usando super_clipboard
      final success = await _copyToSystemClipboardModern(_clipboardFiles);

      if (!success) {
        _clipboardFiles.clear();
        await _cleanupTempFiles();
        return false;
      }

      debugPrint(
          '✅ ${_clipboardFiles.length} arquivo(s) copiado(s) com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao copiar arquivos para clipboard: $e');
      _clipboardFiles.clear();
      await _cleanupTempFiles();
      return false;
    }
  }

  /// Copia arquivos para o clipboard usando super_clipboard
  Future<bool> _copyToSystemClipboardModern(List<DroppedFile> files) async {
    try {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) return false;

      final item = DataWriterItem();

      // Para cada arquivo, adiciona como fileUri
      for (final file in files) {
        String filePath;

        if (file.isLoadedInMemory && file.fileBytes != null) {
          final tempFile = await _createTempFile(file);
          if (tempFile == null) continue;
          filePath = tempFile.path;
        } else {
          filePath = file.fullPath;
        }

        // Converte para URI e adiciona ao clipboard
        final fileUri = Uri.file(filePath);
        item.add(Formats.fileUri(fileUri));

        debugPrint('📎 Adicionando arquivo ao clipboard: $filePath');
      }

      // Escreve no clipboard do sistema
      await clipboard.write([item]);

      debugPrint(
          '✅ Arquivos copiados para o clipboard do sistema usando super_clipboard');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao usar super_clipboard: $e');
      return false;
    }
  }

  /// Cria arquivo temporário para arquivos em memória
  Future<File?> _createTempFile(DroppedFile file) async {
    try {
      if (file.fileBytes == null) return null;

      final tempDir = await _getTempDirectory();
      final tempPath = path.join(tempDir.path, file.name);
      final tempFile = File(tempPath);

      await tempFile.writeAsBytes(file.fileBytes!);
      debugPrint('📁 Arquivo temporário criado: $tempPath');

      return tempFile;
    } catch (e) {
      debugPrint('❌ Erro ao criar arquivo temporário: $e');
      return null;
    }
  }

  /// Obtém o diretório temporário
  Future<Directory> _getTempDirectory() async {
    if (_tempDirPath == null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _tempDirPath =
          path.join(Directory.systemTemp.path, 'island_clipboard_$timestamp');
    }

    final tempDir = Directory(_tempDirPath!);
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }

    return tempDir;
  }

  @override
  Future<bool> pasteFilesToDirectory(String targetDirectory) async {
    if (!hasFilesInClipboard) {
      debugPrint('❌ Nenhum arquivo no clipboard para colar');
      return false;
    }

    try {
      final targetDir = Directory(targetDirectory);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      int successCount = 0;
      for (final file in _clipboardFiles) {
        try {
          if (file.isLoadedInMemory && file.fileBytes != null) {
            // Arquivo está em memória
            final targetPath =
                _generateUniqueFilePath(targetDirectory, file.name);
            await File(targetPath).writeAsBytes(file.fileBytes!);
            successCount++;
            debugPrint('✅ Arquivo colado: $targetPath');
          } else {
            // Arquivo existe no sistema de arquivos
            if (await File(file.fullPath).exists()) {
              final targetPath =
                  _generateUniqueFilePath(targetDirectory, file.name);
              await File(file.fullPath).copy(targetPath);
              successCount++;
              debugPrint('✅ Arquivo colado: $targetPath');
            }
          }
        } catch (e) {
          debugPrint('❌ Erro ao colar arquivo ${file.name}: $e');
        }
      }

      debugPrint(
          '✅ $successCount de ${_clipboardFiles.length} arquivos colados com sucesso');
      return successCount > 0;
    } catch (e) {
      debugPrint('❌ Erro ao colar arquivos: $e');
      return false;
    }
  }

  /// Gera um caminho único para o arquivo evitando conflitos
  String _generateUniqueFilePath(String directory, String fileName) {
    String targetPath = path.join(directory, fileName);

    if (!File(targetPath).existsSync()) {
      return targetPath;
    }

    final nameWithoutExt = path.basenameWithoutExtension(fileName);
    final extension = path.extension(fileName);

    int counter = 1;
    do {
      targetPath = path.join(directory, '${nameWithoutExt}_$counter$extension');
      counter++;
    } while (File(targetPath).existsSync());

    return targetPath;
  }

  @override
  void clearClipboard() {
    _clipboardFiles.clear();
    _cleanupTempFiles();
  }

  /// Limpa arquivos temporários
  Future<void> _cleanupTempFiles() async {
    try {
      if (_tempDirPath != null) {
        final tempDir = Directory(_tempDirPath!);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
        _tempDirPath = null;
      }

      // Limpa diretórios temporários antigos
      await _cleanupOldTempDirectories();
    } catch (e) {
      debugPrint('⚠️ Aviso: Falha na limpeza de arquivos temporários: $e');
    }
  }

  /// Limpa diretórios temporários antigos que possam ter ficado
  Future<void> _cleanupOldTempDirectories() async {
    try {
      final systemTempDir = Directory.systemTemp;
      final tempContents = await systemTempDir.list().toList();

      for (final entity in tempContents) {
        if (entity is Directory &&
            path.basename(entity.path).startsWith('island_clipboard_')) {
          try {
            // Remove diretórios mais antigos que 1 hora
            final stats = await entity.stat();
            final age = DateTime.now().difference(stats.modified);
            if (age.inHours > 1) {
              await entity.delete(recursive: true);
              debugPrint(
                  '🧹 Diretório temporário antigo removido: ${entity.path}');
            }
          } catch (e) {
            // Ignora erros de limpeza
          }
        }
      }
    } catch (e) {
      // Falha silenciosa na limpeza
    }
  }

  /// Método público para limpeza de arquivos temporários
  Future<void> cleanupTempFiles() async {
    await _cleanupTempFiles();
  }
}

/// Implementação legada do clipboard (mantida para compatibilidade)
class MacOSClipboardService implements IClipboardService {
  static final MacOSClipboardService _instance =
      MacOSClipboardService._internal();
  factory MacOSClipboardService() => _instance;
  MacOSClipboardService._internal();

  final List<DroppedFile> _clipboardFiles = [];

  @override
  List<DroppedFile> get clipboardFiles => List.unmodifiable(_clipboardFiles);

  @override
  bool get hasFilesInClipboard => _clipboardFiles.isNotEmpty;

  @override
  Future<bool> copyFileToClipboard(DroppedFile file) async {
    // Redireciona para implementação moderna
    final modernService = ModernClipboardService();
    return modernService.copyFileToClipboard(file);
  }

  @override
  Future<bool> copyFilesToClipboard(List<DroppedFile> files) async {
    // Redireciona para implementação moderna
    final modernService = ModernClipboardService();
    return modernService.copyFilesToClipboard(files);
  }

  @override
  Future<bool> pasteFilesToDirectory(String targetDirectory) async {
    // Redireciona para implementação moderna
    final modernService = ModernClipboardService();
    return modernService.pasteFilesToDirectory(targetDirectory);
  }

  @override
  void clearClipboard() {
    _clipboardFiles.clear();
    final modernService = ModernClipboardService();
    modernService.clearClipboard();
  }

  Future<void> cleanupTempFiles() async {
    final modernService = ModernClipboardService();
    await modernService.cleanupTempFiles();
  }
}

/// Factory para criar o serviço de clipboard apropriado
/// Agora usa a implementação moderna por padrão
class ClipboardServiceFactory {
  static IClipboardService create() {
    if (Platform.isMacOS) {
      return ModernClipboardService(); // Usa implementação moderna
    }
    throw UnsupportedError('Plataforma não suportada para clipboard service');
  }
}
